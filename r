package ru.sber.poirot.grs.scheme.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.inlined
import ru.sber.poirot.engine.metamodel.*
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.INCORRECT_ROW_SIZE
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.grs.participant.dto.FlDebtDto
import ru.sber.poirot.grs.participant.dto.OrgInfoDto
import ru.sber.poirot.grs.participant.dto.ParticipantDto
import ru.sber.poirot.grs.participant.dto.UlDebtDto
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

@Repository
class ParticipantInfoFetcher {
    suspend fun fetchFraudStatuses(inns: List<String>, fioDobs: List<String>): Map<String, String> =
        (findAll(entity = fraud, batch = true) fetchFields {
            listOf(fraud.key, fraud.fraudStatus, fraud.dateTime)
        } where {
            (fraud.type `=` "ЮЛ:КлиентОрганизация" and (fraud.key `in` inns)) or
                    (fraud.type `=` "ЮЛ:ФИОДР" and (fraud.key `in` fioDobs))
        }).groupBy { it.key }
            .mapValues { (_, features) ->
                features.maxWith(
                    compareBy(
                        { it.fraudStatus?.priority() ?: Int.MAX_VALUE },
                        { it.dateTime ?: LocalDateTime.MIN }
                    )
                ).fraudStatus
            }
            .filterValues { it != null }

    suspend fun fetchOrgInfos(inns: List<String>): List<OrgInfoDto?> {
        val ulResults = fetchLEInfo(inns)
        val ipResults = fetchIPInfo(inns)
        return (ulResults + ipResults).filterNotNull()
    }

    suspend fun fetchFounders(ogrnList: List<String>): Map<String, List<ParticipantDto.FounderDto>> {
        val allFounders = findAll(
            entity = leFoundersEgrul,
            batch = true
        ) fetchFields {
            listOf(
                leFoundersEgrul.compOgrn,
                leFoundersEgrul.founderInn,
                leFoundersEgrul.founderName,
                leFoundersEgrul.dateActual
            )
        } where {
            leFoundersEgrul.compOgrn `in` ogrnList
        }

        // 2. Находим максимальные даты для каждого OGRN
        val maxDatesByOgrn = allFounders
            .groupBy { it.compOgrn }
            .mapValues { (_, founders) ->
                founders.maxOf { it.dateActual }
            }

        // 3. Фильтруем учредителей по максимальной дате
        return allFounders
            .groupBy { it.compOgrn }
            .mapValues { (ogrn, founders) ->
                founders
                    .filter { it.dateActual == maxDatesByOgrn[ogrn] }
                    .map { ParticipantDto.FounderDto(it.founderInn, it.founderName) }
            }
            .filterValues { it.isNotEmpty() }
    }

    suspend fun fetchUlDebts(inns: List<String>): List<UlDebtDto> =
        findAll(
            fields = listOf(
                arrearsClientUl.inn,
                arrearsAgreement.debtAmount,
                arrearsAgreement.curDebtOverAmount,
                arrearsAgreement.curPercOverAmount,
                arrearsAgreement.curDebtOverDate,
                arrearsAgreement.curPercOverDate
            ),
            batch = true
        ) join {
            arrearsRoleLink.customerId `=` arrearsClientUl.customerId
            arrearsAgreement.agreementId `=` arrearsRoleLink.agreementId
        } where {
            arrearsClientUl.inn `in` inns and
                    arrearsRoleLink.role `=` "Заемщик"
        } convertTo {
            UlDebtDto(
                clientInn = nextField(),
                totalCurrentDebt = nextField(),
                totalOverdueDebt = (nextField<Double>() + nextField<Double>()),
                prncpOverdueDays = daysBetweenToday(nextField()),
                intrstOverdueDays = daysBetweenToday(nextField())
            )
        }


    suspend fun fetchFlDebts(fioDobs: List<String>): List<FlDebtDto> {
        return fioDobs.flatMap { fioDob ->
            val parts = fioDob.split("|")
            when {
                parts.size !in 3..4 -> throw FrontException(INCORRECT_ROW_SIZE.description)
                else -> {
                    val lastName = parts[0]
                    val firstName = parts[1]
                    val middleName = parts.getOrNull(2)?.takeIf { it.isNotBlank() }
                    val birthDate = LocalDate.parse(
                        parts.last(),
                        DateTimeFormatter.ofPattern("dd.MM.yyyy")
                    )

                    val clients = findAll(entity = arrearsClientFl, batch = false) fetchFields {
                        listOf(arrearsClientFl.customerId)
                    } where {
                        arrearsClientFl.lastName `=` lastName.inlined and
                                arrearsClientFl.firstName `=` firstName.inlined and
                                arrearsClientFl.birthDate `=` birthDate.inlined and
                                (middleName?.let { arrearsClientFl.middleName `=` it.inlined }
                                    ?: arrearsClientFl.middleName.isNull())
                    }

                    clients.flatMap { client ->
                        findAll(
                            fields = listOf(
                                arrearsAgreement.agreementId,
                                arrearsAgreement.debtAmount,
                                arrearsAgreement.curDebtOverAmount,
                                arrearsAgreement.curPercOverAmount,
                                arrearsAgreement.curDebtOverDate,
                                arrearsAgreement.curPercOverDate
                            ), batch = false
                        ) join {
                            arrearsRoleLink.customerId `=` client.customerId.inlined and
                                    arrearsAgreement.agreementId `=` arrearsRoleLink.agreementId
                        } where {
                            arrearsRoleLink.role `=` "Заемщик".inlined
                        } convertTo {
                            FlDebtDto(
                                agreementId = nextField(),
                                clientFioDob = fioDob,
                                totalCurrentDebt = nextField(),
                                totalOverdueDebt = nextField<Double>() + nextField<Double>(),
                                prncpOverdueDays = daysBetweenToday(nextField()),
                                intrstOverdueDays = daysBetweenToday(nextField())
                            )
                        }
                    }
                }
            }
        }
    }

        suspend fun fetchRelatedSchemes(ids: List<Long>, currentSchemeId: Long): Map<Long, List<String>> =
            (findAll(
                fields = listOf(
                    fraudScheme.participantsMapping.participant.id,
                    fraudScheme.name
                ),
                batch = true
            ) where {
                fraudScheme.participantsMapping.participant.id `in` ids
                fraudScheme.id `!=` currentSchemeId.inlined
            } convertTo {
                val participantId = nextField<Long>()
                val schemeName = nextField<String>()
                participantId to schemeName
            }).groupBy(
                { it.first },  // participantId
                { it.second }  // schemeName
            )


    private suspend fun fetchLEInfo(inns: List<String>): List<OrgInfoDto?> =
        (findAll(fields = with(leRegInfoEgrul) {
            listOf(
                leRegInfoEgrul.inn,
                leRegInfoEgrul.ogrn,
                leRegInfoEgrul.dateReg,
                leRegInfoEgrul.region,
                leRegInfoEgrul.regionType,
                leRegInfoEgrul.briefOrganizationName,
                leRegInfoEgrul.fullOrganizationName
            )
        }, batch = false) where {
            leRegInfoEgrul.inn `in` inns and
                    (leRegInfoEgrul.leCode.isNull() or leRegInfoEgrul.leCode `not in` listOf(
                        "701",
                        "702",
                        "801"
                    ).inlined) and
                    (leRegInfoEgrul.leEndCode.isNull() or leRegInfoEgrul.leEndCode `not in` listOf(
                        "701",
                        "801"
                    ).inlined)

        } convertTo {
            OrgInfoDto(
                inn = nextField(),
                ogrn = nextField(),
                registrationDate = nextField(),
                region = buildRegionString(nextField(), nextField()),
                name = nextField() ?: nextField()
            )
        }).groupBy { it.inn }
            .map { (_, infos) -> infos.maxByOrNull { it.registrationDate!! } }

    private suspend fun fetchIPInfo(inns: List<String>): List<OrgInfoDto?> =
        (findAll(fields = with(ibRegInfoEgrul) {
            listOf(
                ibRegInfoEgrul.inn,
                ibRegInfoEgrul.ogrnip,
                ibRegInfoEgrul.egripRecDate,
                ibRegInfoEgrul.regionName,
                ibRegInfoEgrul.regionType,
                ibRegInfoEgrul.lastName,
                ibRegInfoEgrul.firstName,
                ibRegInfoEgrul.secondName
            )
        }, batch = false) where {
            ibRegInfoEgrul.inn `in` inns and
                    (ibRegInfoEgrul.ipStatusCode.isNull() or ibRegInfoEgrul.ipStatusCode `=` "")
        } convertTo {
            val inn = nextField<String>()
            val ogrn = nextField<String?>()
            val regDate = nextField<LocalDate?>()
            val region = buildRegionString(nextField(), nextField())
            val lastName = nextField<String?>()
            val firstName = nextField<String?>()
            val secondName = nextField<String?>()

            val name = when {
                !lastName.isNullOrBlank() && !firstName.isNullOrBlank() -> {
                    "ИП $lastName $firstName${secondName?.let { " $it" }.orEmpty()}"
                }
                else -> "Отсутствуют данные"
            }

            OrgInfoDto(
                inn = inn,
                ogrn = ogrn,
                registrationDate = regDate,
                region = region,
                name = name
            )
        }).groupBy { it.inn }
            .map { (_, infos) -> infos.maxByOrNull { it.registrationDate!! } }

    private fun daysBetweenToday(date: LocalDate?): Int =
        date?.let { ChronoUnit.DAYS.between(it, LocalDate.now()).toInt() } ?: 0

    private fun buildRegionString(regionPart1: String?, regionPart2: String?): String? =
        when {
            regionPart1 != null && regionPart2 != null -> "$regionPart1 $regionPart2"
            regionPart1 != null -> regionPart1
            regionPart2 != null -> regionPart2
            else -> null
        }

    private fun String.priority(): Int = when (this) {
        "fraud" -> 1
        "suspicion" -> 2
        "in_work" -> 3
        "risk_digital_footprint" -> 4
        "risk_grey_zone" -> 5
        "risk" -> 6
        "remove_mon" -> 7
        "remove" -> 8
        "clear" -> 9
        else -> 10
    }

}
