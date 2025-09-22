package ru.sber.poirot.focus.shared.contract.frauds

import ru.sber.poirot.engine.model.api.monitoring.MonitoringProcessFraudScheme
import ru.sber.poirot.engine.model.full.monitoring.MonitoringProcessFraudScheme as FullMonitoringProcessFraudScheme


data class MonitoringProcessFraudSchema(
    val fraudSchemeId: Int,
    val shortComment: String?,
    val fullComment: String?,
    override val affectedByDefault: Boolean?
) : Checked {
    override val blockName: String = "Фрод-схемы мониторинга"

    override val isEmpty: Boolean =
    override val confirmedChecks: Map<Boolean, String>
    override val notConfirmedChecks: Map<Boolean, String>

    fun toRecord(): FullMonitoringProcessFraudScheme=
        FullMonitoringProcessFraudScheme().apply {
            val self = this@MonitoringProcessFraudSchema

            fraudSchemeId = self.fraudSchemeId
            shortComment = self.shortComment
            fullComment = self.fullComment
        }

    companion object {
        fun MonitoringProcessFraudScheme.toMonitoringProcessFraudSchemeModel(): MonitoringProcessFraudSchema =
            MonitoringProcessFraudSchema(
                fraudSchemeId = fraudSchemeId,
                shortComment = shortComment,
                fullComment = fullComment,
            )
    }
}
