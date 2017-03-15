
	


--/*
-- drop PROCEDURE ntpSearchAverageValues
alter PROCEDURE ntpSearchAverageValues (
	-- входные параметры (параметры расчета общих показателей)
	@cDateTimeFirst varchar(16), -- время начала расчета К
	@cDateTimeFirstCalc varchar(16), -- время начала расчета общих показателей
	@cDateTimeLastCalc varchar(16), -- время окончания расчета общих показателей
	
	@cntCharts int, -- количество похожих графиков, которые берем для анализа
	@StopLoss real, -- StopLoss в пунктах
	@TakeProfit real, -- TakeProfit в пунктах
	@OnePoint real, -- значение одного пункта в цене
	@CurrencyId_current	int, -- CurrencyId валюты текущих данных
	@CurrencyId_history	int, -- CurrencyId валюты исторических данных (с которыми сравниваем)
	@DataSourceId	int,
	@PeriodMinutes int,
	@isCalcAverageValuesInPercents int, -- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
	@pParamsIdentifyer VARCHAR(50),
	@pcntBarsCalcCorr int, -- количество баров, по которым считать К (0 - задается начальная дата-время)

	@DeltaCcloseRangeMaxLimit real, -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
	@DeltaCcloseRangeMinLimit real, -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
	@IsCalcCorrOnlyForSameTime int, -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
	@DeltaMinutesCalcCorr int, -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
	@CalcCorrParamsId varchar(20) -- идентификатор параметров расчета К	
	
)
AS BEGIN 
-- процедура:
-- 1) проверяет, есть ли уже рассчитанные средние показатели на даты из заданного диапазона (диапазон - в таблице ntImportCurrent, рассчитанные средние показатели - в таблице ntAverageValuesResults).
-- 2) записывает в таблицу ntImportCurrent_NoAverageValues те текущие даты, на которые общие показатели еще не рассчитаны.

-- условия: таблица ntImportCurrent (текущие данные) д.б. заполнена

SET NOCOUNT ON



	If object_ID('tempdb..#ntImportCurrent') Is not Null drop table #ntImportCurrent

	select *
	into #ntImportCurrent
	from ntImportCurrent
	where ParamsIdentifyer = @pParamsIdentifyer



	
	If object_ID('tempdb..#ntImportCurrent_NoAverageValues') Is not Null drop table #ntImportCurrent_NoAverageValues

	-- делаем копии таблиц (сначала заполним их, а потом разом перебросим в постоянные)
	select top 1 *
	into #ntImportCurrent_NoAverageValues
	from ntImportCurrent_NoAverageValues

	truncate table #ntImportCurrent_NoAverageValues
	
	



if @pcntBarsCalcCorr = 0
begin
	-- вычисляем текущие данные из таблицы ntImportCurrent, по которым не рассчитаны общие показатели (нет соответствующих записей в таблице ntAverageValuesResults)
	insert into #ntImportCurrent_NoAverageValues (idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer)
	SELECT c.idn, @cDateTimeFirst, c.cdate, c.ctime, c.copen, c.chigh, c.clow, c.cclose, @pParamsIdentifyer
	from #ntImportCurrent c
	left outer join #ntImportCurrent cf on --cf.ParamsIdentifyer = @pParamsIdentifyer and 
		cf.cdate + ' ' + cf.ctime = @cDateTimeFirst -- строка с временем начала расчета К
	 -- строка с уже рассчитанными показателями по текущей дате
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = @cDateTimeFirst -- совпадает время начала расчета К
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- совпадает время окончания расчета общих показателей
		-- совпадают цены в начале расчетного периода
		and v.copen_first = cf.copen
		and v.chigh_first = cf.chigh
		and v.clow_first = cf.clow
		and v.cclose_first = cf.cclose
		-- совпадают цены в конце расчетного периода
		and v.copen_last = c.copen
		and v.chigh_last = c.chigh
		and v.clow_last = c.clow
		and v.cclose_last = c.cclose
		-- совпадают параметры расчета общих показателей	
		and v.cntCharts = @cntCharts
		and v.StopLoss = @StopLoss
		and v.TakeProfit = @TakeProfit
		and v.OnePoint = @OnePoint
		and v.CurrencyId_current = @CurrencyId_current
		and v.CurrencyId_history = @CurrencyId_history
		and v.DataSourceId = @DataSourceId
		and v.PeriodMinutes = @PeriodMinutes
		and v.isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents
		and v.cntBarsCalcCorr = @pcntBarsCalcCorr		
		
		and v.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		and v.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		and v.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		and v.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
		and v.CalcCorrParamsId = @CalcCorrParamsId -- идентификатор параметров расчета К	
		
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			c.cdate + ' ' + c.ctime >= @cDateTimeFirstCalc
		and c.cdate + ' ' + c.ctime <= @cDateTimeLastCalc
		and v.idn is null -- общие показатели не рассчитаны
end


if @pcntBarsCalcCorr > 0
	-- вычисляем текущие данные из таблицы ntImportCurrent, по которым не рассчитаны общие показатели (нет соответствующих записей в таблице ntAverageValuesResults)
	insert into #ntImportCurrent_NoAverageValues (idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer)
	SELECT c.idn, cf.cdate + ' ' + cf.ctime, c.cdate, c.ctime, c.copen, c.chigh, c.clow, c.cclose, @pParamsIdentifyer
	from #ntImportCurrent c
	left outer join #ntImportCurrent cf on --cf.ParamsIdentifyer = @pParamsIdentifyer and 
		cf.idn = c.idn - @pcntBarsCalcCorr + 1 -- строка с временем начала расчета К
	 -- строка с уже рассчитанными показателями по текущей дате
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = cf.cdate + ' ' + cf.ctime -- совпадает время начала расчета К
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- совпадает время окончания расчета общих показателей
		-- совпадают цены в начале расчетного периода
		and v.copen_first = cf.copen
		and v.chigh_first = cf.chigh
		and v.clow_first = cf.clow
		and v.cclose_first = cf.cclose
		-- совпадают цены в конце расчетного периода
		and v.copen_last = c.copen
		and v.chigh_last = c.chigh
		and v.clow_last = c.clow
		and v.cclose_last = c.cclose
		-- совпадают параметры расчета общих показателей	
		and v.cntCharts = @cntCharts
		and v.StopLoss = @StopLoss
		and v.TakeProfit = @TakeProfit
		and v.OnePoint = @OnePoint
		and v.CurrencyId_current = @CurrencyId_current
		and v.CurrencyId_history = @CurrencyId_history
		and v.DataSourceId = @DataSourceId
		and v.PeriodMinutes = @PeriodMinutes
		and v.isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents
		and v.cntBarsCalcCorr = @pcntBarsCalcCorr

		and v.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		and v.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		and v.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		and v.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
		and v.CalcCorrParamsId = @CalcCorrParamsId -- идентификатор параметров расчета К	
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			c.cdate + ' ' + c.ctime >= @cDateTimeFirstCalc
		and c.cdate + ' ' + c.ctime <= @cDateTimeLastCalc
		and v.idn is null -- общие показатели не рассчитаны
		and cf.ctime is not null -- есть полное количество баров для расчета К
	order by cf.cdate + ' ' + cf.ctime 



-- truncate table ntImportCurrent_NoAverageValues
delete from ntImportCurrent_NoAverageValues where ParamsIdentifyer = @pParamsIdentifyer

insert into ntImportCurrent_NoAverageValues (idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer)
select idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer
from #ntImportCurrent_NoAverageValues
order by cdatetime_first, ctime_last




END



-- go
-- exec ntpSearchAverageValues '2016.05.13 01:05', '2016.05.13 10:30', '2016.05.13 23:55', 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5_v10_PAB100', 100
-- exec ntpSearchAverageValues '2016.05.13 02:45', '2016.05.13 10:30', '2016.05.13 10:40', 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5_v09_PAB64', 65


--SELECT * 	from ntImportCurrent where ParamsIdentifyer = '1_5_v09_PAB64'
	

----exec ntpSearchAverageValues '2016.05.02 01:05', '2016.05.02 11:00', '2016.05.02 23:55', 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5', 0
--exec ntpSearchAverageValues '2016.04.11 10:10', '2016.04.11 20:30', '2016.04.11 23:30', 15, 100, 200, 1, 6, 6, 3, 5, 1, '6_5', 0
--go
--select * from ntImportCurrent_NoAverageValues (nolock) order by idn desc -- общие показатели, которые нужно рассчитать


/*

exec ntpSearchAverageValues --'2015.08.14 00:00', '2015.08.14 09:30', '2015.08.14 09:40', 15, 10, 20, 0.0001, 1, 1, 2, 5
	-- параметры расчета общих показателей
	@cDateTimeFirst = '2015.08.14 00:00', -- время начала расчета К
	@cDateTimeFirstCalc = '2015.08.14 09:00', -- время начала расчета общих показателей
	@cDateTimeLastCalc = '2015.08.14 09:50', -- время окончания расчета общих показателей
	@cntCharts = 15,
	@StopLoss = 10,
	@TakeProfit = 20,
	@OnePoint = 0.0001,
	@CurrencyId_current = 1,
	@CurrencyId_history = 1,
	@DataSourceId = 2,
	@PeriodMinutes = 5,
	@isCalcAverageValuesInPercents = 1

*/
