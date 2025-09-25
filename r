Multiple Failures (1 failure)
	java.lang.AssertionError: 
Expecting actual:
  []
to be equal to:
  [BasketRecord(type=type1, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=null, prolongationReason=null), record=UnifiedRecord(date=2024-01-01T01:01, name=name1, appId=appId1, inn=inn1, status=status1, id=id1, metadata=null, sla=null)),
    BasketRecord(type=type2, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=2024-01-01T01:02, prolongationReason=reason2), record=UnifiedRecord(date=2024-01-01T01:01, name=name2, appId=appId2, inn=inn2, status=status2, id=id2, metadata=null, sla=null))]
when recursively comparing field by field, but found the following difference:

Top level actual and expected objects differ:
- actual value  : []
- expected value: [BasketRecord(type=type1, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=null, prolongationReason=null), record=UnifiedRecord(date=2024-01-01T01:01, name=name1, appId=appId1, inn=inn1, status=status1, id=id1, metadata=null, sla=null)),
    BasketRecord(type=type2, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=2024-01-01T01:02, prolongationReason=reason2), record=UnifiedRecord(date=2024-01-01T01:01, name=name2, appId=appId2, inn=inn2, status=status2, id=id2, metadata=null, sla=null))]
actual and expected values are collections of different size, actual size=0 when expected size=2

The recursive comparison was performed with this configuration:
- no equals methods were used in the comparison EXCEPT for java JDK types since introspecting JDK types is forbidden in java 17+ (use withEqualsForType to register a specific way to compare a JDK type if you need it)
- these types were compared with the following comparators:
  - java.lang.Double -> DoubleComparator[precision=1.0E-15]
  - java.lang.Float -> FloatComparator[precision=1.0E-6]
  - java.nio.file.Path -> lexicographic comparator (Path natural order)
- actual and expected objects and their fields were compared field by field recursively even if they were not of the same type, this allows for example to compare a Person to a PersonDto (call strictTypeChecking(true) to change that behavior).
- the introspection strategy used was: DefaultRecursiveComparisonIntrospectionStrategy

org.opentest4j.MultipleFailuresError: Multiple Failures (1 failure)
	java.lang.AssertionError: 
Expecting actual:
  []
to be equal to:
  [BasketRecord(type=type1, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=null, prolongationReason=null), record=UnifiedRecord(date=2024-01-01T01:01, name=name1, appId=appId1, inn=inn1, status=status1, id=id1, metadata=null, sla=null)),
    BasketRecord(type=type2, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=2024-01-01T01:02, prolongationReason=reason2), record=UnifiedRecord(date=2024-01-01T01:01, name=name2, appId=appId2, inn=inn2, status=status2, id=id2, metadata=null, sla=null))]
when recursively comparing field by field, but found the following difference:

Top level actual and expected objects differ:
- actual value  : []
- expected value: [BasketRecord(type=type1, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=null, prolongationReason=null), record=UnifiedRecord(date=2024-01-01T01:01, name=name1, appId=appId1, inn=inn1, status=status1, id=id1, metadata=null, sla=null)),
    BasketRecord(type=type2, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=2024-01-01T01:02, prolongationReason=reason2), record=UnifiedRecord(date=2024-01-01T01:01, name=name2, appId=appId2, inn=inn2, status=status2, id=id2, metadata=null, sla=null))]
actual and expected values are collections of different size, actual size=0 when expected size=2

The recursive comparison was performed with this configuration:
- no equals methods were used in the comparison EXCEPT for java JDK types since introspecting JDK types is forbidden in java 17+ (use withEqualsForType to register a specific way to compare a JDK type if you need it)
- these types were compared with the following comparators:
  - java.lang.Double -> DoubleComparator[precision=1.0E-15]
  - java.lang.Float -> FloatComparator[precision=1.0E-6]
  - java.nio.file.Path -> lexicographic comparator (Path natural order)
- actual and expected objects and their fields were compared field by field recursively even if they were not of the same type, this allows for example to compare a Person to a PersonDto (call strictTypeChecking(true) to change that behavior).
- the introspection strategy used was: DefaultRecursiveComparisonIntrospectionStrategy

	at org.junit.jupiter.api.AssertAll.assertAll(AssertAll.java:80)
	at org.junit.jupiter.api.AssertAll.assertAll(AssertAll.java:58)
	at org.junit.jupiter.api.Assertions.assertAll(Assertions.java:3012)
	at org.junit.jupiter.api.AssertionsKt.assertAll(Assertions.kt:53)
	at org.junit.jupiter.api.AssertionsKt.assertAll(Assertions.kt:86)
	at ru.sber.poirot.basket.api.impl.UnifiedBasketImplTest$load records$1.invokeSuspend(UnifiedBasketImplTest.kt:81)
	at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
	at kotlinx.coroutines.internal.ScopeCoroutine.afterResume(Scopes.kt:28)
	at kotlinx.coroutines.AbstractCoroutine.resumeWith(AbstractCoroutine.kt:99)
	at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:46)
	at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
	at kotlinx.coroutines.EventLoopImplBase.processNextEvent(EventLoop.common.kt:277)
	at kotlinx.coroutines.BlockingCoroutine.joinBlocking(Builders.kt:95)
	at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking(Builders.kt:69)
	at kotlinx.coroutines.BuildersKt.runBlocking(Unknown Source)
	at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking$default(Builders.kt:48)
	at kotlinx.coroutines.BuildersKt.runBlocking$default(Unknown Source)
	at ru.sber.poirot.basket.api.impl.UnifiedBasketImplTest.load records(UnifiedBasketImplTest.kt:71)
	at java.base/java.lang.reflect.Method.invoke(Method.java:569)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1511)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1511)
	Suppressed: java.lang.AssertionError: 
Expecting actual:
  []
to be equal to:
  [BasketRecord(type=type1, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=null, prolongationReason=null), record=UnifiedRecord(date=2024-01-01T01:01, name=name1, appId=appId1, inn=inn1, status=status1, id=id1, metadata=null, sla=null)),
    BasketRecord(type=type2, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=2024-01-01T01:02, prolongationReason=reason2), record=UnifiedRecord(date=2024-01-01T01:01, name=name2, appId=appId2, inn=inn2, status=status2, id=id2, metadata=null, sla=null))]
when recursively comparing field by field, but found the following difference:

Top level actual and expected objects differ:
- actual value  : []
- expected value: [BasketRecord(type=type1, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=null, prolongationReason=null), record=UnifiedRecord(date=2024-01-01T01:01, name=name1, appId=appId1, inn=inn1, status=status1, id=id1, metadata=null, sla=null)),
    BasketRecord(type=type2, sla=Sla(initialDeadline=2024-01-01T01:01, prolongedDeadline=2024-01-01T01:02, prolongationReason=reason2), record=UnifiedRecord(date=2024-01-01T01:01, name=name2, appId=appId2, inn=inn2, status=status2, id=id2, metadata=null, sla=null))]
actual and expected values are collections of different size, actual size=0 when expected size=2

The recursive comparison was performed with this configuration:
- no equals methods were used in the comparison EXCEPT for java JDK types since introspecting JDK types is forbidden in java 17+ (use withEqualsForType to register a specific way to compare a JDK type if you need it)
- these types were compared with the following comparators:
  - java.lang.Double -> DoubleComparator[precision=1.0E-15]
  - java.lang.Float -> FloatComparator[precision=1.0E-6]
  - java.nio.file.Path -> lexicographic comparator (Path natural order)
- actual and expected objects and their fields were compared field by field recursively even if they were not of the same type, this allows for example to compare a Person to a PersonDto (call strictTypeChecking(true) to change that behavior).
- the introspection strategy used was: DefaultRecursiveComparisonIntrospectionStrategy

		at ru.sber.poirot.basket.api.impl.UnifiedBasketImplTest$load records$1$1.invoke(UnifiedBasketImplTest.kt:82)
		at ru.sber.poirot.basket.api.impl.UnifiedBasketImplTest$load records$1$1.invoke(UnifiedBasketImplTest.kt:81)
		at org.junit.jupiter.api.AssertionsKt$convert$1.invoke$lambda$0(Assertions.kt:48)
		at org.junit.jupiter.api.AssertAll.lambda$assertAll$0(AssertAll.java:68)
		at java.base/java.util.stream.ReferencePipeline$3$1.accept(ReferencePipeline.java:197)
		at java.base/java.util.stream.ReferencePipeline$3$1.accept(ReferencePipeline.java:197)
		at java.base/java.util.ArrayList$ArrayListSpliterator.forEachRemaining(ArrayList.java:1625)
		at java.base/java.util.stream.AbstractPipeline.copyInto(AbstractPipeline.java:509)
		at java.base/java.util.stream.AbstractPipeline.wrapAndCopyInto(AbstractPipeline.java:499)
		at java.base/java.util.stream.ReduceOps$ReduceOp.evaluateSequential(ReduceOps.java:921)
		at java.base/java.util.stream.AbstractPipeline.evaluate(AbstractPipeline.java:234)
		at java.base/java.util.stream.ReferencePipeline.collect(ReferencePipeline.java:682)
		at org.junit.jupiter.api.AssertAll.assertAll(AssertAll.java:77)
		... 20 more
package ru.sber.poirot.basket.api.impl

import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertAll
import ru.sber.poirot.allure.AllureAnnotation
import ru.sber.poirot.basket.api.impl.ProcessType.DER
import ru.sber.poirot.basket.api.impl.ProcessType.DEVIATION
import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.basket.common.BasketRecord
import ru.sber.poirot.basket.common.SourceResponse
import ru.sber.poirot.common.UnifiedRecord
import java.time.LocalDate
import java.time.LocalDateTime

@AllureAnnotation
internal class UnifiedBasketImplTest {
    private val errorMessage = "Error Message"
    private val records = listOf(
        BasketRecord(
            type = "type1",
            sla = BasketRecord.Sla(
                initialDeadline = LocalDateTime.of(2024, 1, 1, 1, 1),
                prolongedDeadline = null,
                prolongationReason = null,
            ),
            record = UnifiedRecord(
                date = LocalDateTime.of(2024, 1, 1, 1, 1),
                name = "name1",
                appId = "appId1",
                inn = "inn1",
                status = "status1",
                id = "id1",
            )
        ),
        BasketRecord(
            type = "type2",
            sla = BasketRecord.Sla(
                initialDeadline = LocalDateTime.of(2024, 1, 1, 1, 1),
                prolongedDeadline = LocalDateTime.of(2024, 1, 1, 1, 2),
                prolongationReason = "reason2",
            ),
            record = UnifiedRecord(
                date = LocalDateTime.of(2024, 1, 1, 1, 1),
                name = "name2",
                appId = "appId2",
                inn = "inn2",
                status = "status2",
                id = "id2",
            )
        ),
    )

    private val workingBasketLoader: BasketLoader = mockk {
        every { type } returns DER
        coEvery { getRecords(any()) } returns SourceResponse.success(records)
    }
    private val brokenBasketLoader: BasketLoader = mockk {
        every { type } returns DEVIATION
        coEvery { getRecords(any()) } returns SourceResponse.error(errorMessage)
    }
    private val unifiedBasketImpl = UnifiedBasketImpl(
        basketLoaders = listOf(workingBasketLoader, brokenBasketLoader),
    )

    @Test
    fun `load records`(): Unit = runBlocking {
        // given
        val request = RecordsRequest(
            fromDate = LocalDate.of(2024, 1, 1),
            toDate = LocalDate.of(2024, 1, 2),
            filters = listOf()
        )
        // when
        val response = unifiedBasketImpl.loadRecords(request)
        // then
        assertAll(
            { assertThat(response.records).usingRecursiveComparison().isEqualTo(records) },
            { assertThat(response.warningMessages).usingRecursiveComparison().isEqualTo(listOf(errorMessage)) },
        )
    }
}package ru.sber.poirot.basket.api.impl.loaders

import ru.sber.poirot.CurrentUser
import ru.sber.poirot.basket.BasketProviderRequest
import ru.sber.poirot.basket.api.impl.BasketLoader
import ru.sber.poirot.basket.api.impl.ProcessType
import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.basket.common.SourceResponse
import ru.sber.poirot.basket.common.sources.UnifiedSource
import ru.sber.poirot.common.UnifiedRole

class BasketLoaderImpl(
    private val currentUser: CurrentUser,
    private val roleMap: Map<String, UnifiedRole>,
    private val unifiedSource: UnifiedSource,
) : BasketLoader {
    override val type: ProcessType = unifiedSource.type

    override suspend fun getRecords(recordsRequest: RecordsRequest): SourceResponse {
        val request = recordsRequest.withUserInfo()
        return unifiedSource.fetch("/internal/basket/records", request)
    }

    private suspend fun RecordsRequest.withUserInfo(): BasketProviderRequest =
        BasketProviderRequest(
            fromDate = fromDate,
            toDate = toDate,
            roles = getRoles(),
            userName = currentUser.userName(),
        )

    private suspend fun getRoles(): List<UnifiedRole> =
        buildList {
            roleMap.forEach { (key, value) ->
                if (currentUser.hasPermission(key)) add(value)
            }
        }.distinct()
}
