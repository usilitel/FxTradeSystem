
/*
exec ntpImportCurrentChartAverageValues --'2015.08.14 00:00', '2015.08.14 09:30', '2015.08.14 09:40', 15, 10, 20, 0.0001, 1, 1, 2, 5
	-- параметры расчета общих показателей
	@cDateTimeFirst = '2015.12.14 10:05', -- время начала расчета К
	@cDateTimeFirstCalc = '2015.12.14 10:30', -- время начала расчета общих показателей
	@cDateTimeLastCalc = '2015.12.14 22:00', -- время окончания расчета общих показателей
	@cntCharts = 15,
	@StopLoss = 100,
	@TakeProfit = 200,
	@OnePoint = 1,
	@CurrencyId_current = 6,
	@CurrencyId_history = 6,
	@DataSourceId = 3,
	@PeriodMinutes = 5,
	@isCalcAverageValuesInPercents = 1, -- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
	@pParamsIdentifyer = '1400_40_6_6_3_5_1_1_0_0',
	@pCntDaysPreviousShowABV = 100
*/
	
-- select * from ntImportCurrentChartAverageValues where ParamsIdentifyer = '1_5' order by idn desc

/*
exec ntpImportCurrentChartAverageValues --'2015.08.14 00:00', '2015.08.14 09:30', '2015.08.14 09:40', 15, 10, 20, 0.0001, 1, 1, 2, 5
	-- параметры расчета общих показателей
	@cDateTimeFirst = '2015.12.14 02:05', -- время начала расчета К
	@cDateTimeFirstCalc = '2015.12.14 03:10', -- время начала расчета общих показателей
	@cDateTimeLastCalc = '2015.12.14 22:00', -- время окончания расчета общих показателей
	@cntCharts = 15,
	@StopLoss = 10,
	@TakeProfit = 20,
	@OnePoint = 0.0001,
	@CurrencyId_current = 1,
	@CurrencyId_history = 1,
	@DataSourceId = 2,
	@PeriodMinutes = 5,
	@isCalcAverageValuesInPercents = 1, -- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
	@pParamsIdentifyer = '1400_40_1_1_2_5_1_1_0_0',
	@pCntDaysPreviousShowABV = 100
	*/

	
	

-- select * from ntImportCurrent
-- select * from ntAverageValuesResults
-- select * from ntAverageValuesResultsAgregated

/*
declare
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
	@PeriodMinutes int
	
select	
	-- параметры расчета общих показателей
	@cDateTimeFirst = '2015.08.04 00:00', -- время начала расчета К
	@cDateTimeFirstCalc = '2015.08.04 09:30', -- время начала расчета общих показателей
	@cDateTimeLastCalc = '2015.08.04 09:40', -- время окончания расчета общих показателей
	@cntCharts = 15,
	@StopLoss = 10,
	@TakeProfit = 20,
	@OnePoint = 0.0001,
	@CurrencyId_current = 1,
	@CurrencyId_history = 1,
	@DataSourceId = 2,
	@PeriodMinutes = 5
	*/
	
/*
select * from ntAverageValuesResults
-- delete from ntAverageValuesResults where idn > 67

select * from ntImportCurrent
select * from ntImportCurrentChartAverageValues
select * from ntImportCurrent_NoAverageValues
*/



-- select * from ntImportCurrentChartAverageValues



-- создаем процедуру для заполнения текущего графика общими показателями
-- drop PROCEDURE ntpImportCurrentChartAverageValues
alter PROCEDURE ntpImportCurrentChartAverageValues(
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
	@pCntDaysPreviousShowABV int, -- количество предыдущих дней, за которое показывать ABV на графике (1 - показывать только за текущий день)
	@pCntBarsCalcCorr int -- количество баров, по которым считать К (0 - задается начальная дата-время)

	
)
AS BEGIN 
-- процедура заполняет текущий график (таблицу ntImportCurrentChartAverageValues) общими показателями

-- условия для расчета: 
-- таблица ntImportCurrentChartAverageValues д.б. уже заполнена

-- результат: 
-- 1) в таблицу ntImportCurrentChartAverageValues добавляются общие рассчитанные величины (из таблицы ntAverageValuesResults)

	SET NOCOUNT ON

 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 1

	
	declare
		@CntBarsMinLimit integer, -- минимальное количество баров, которое может быть в торговом дне
		@DeltaCcloseRangeMaxLimit real, -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@DeltaCcloseRangeMinLimit real, -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@IsCalcCorrOnlyForSameTime int, -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		@DeltaMinutesCalcCorr int, -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
		@CalcCorrParamsId varchar(20) -- идентификатор параметров расчета К	
		
		
	-- берем недостающие параметры расчета
	select
		@CntBarsMinLimit = CntBarsMinLimit, -- минимальное количество баров, которое может быть в торговом дне
		@DeltaCcloseRangeMaxLimit = DeltaCcloseRangeMaxLimit, -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@DeltaCcloseRangeMinLimit = DeltaCcloseRangeMinLimit, -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@IsCalcCorrOnlyForSameTime = IsCalcCorrOnlyForSameTime, -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		@DeltaMinutesCalcCorr = DeltaMinutesCalcCorr, -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
		@CalcCorrParamsId = CalcCorrParamsId -- идентификатор параметров расчета К	
	from ntSettingsFilesParameters_cn with (nolock)
	where ParamsIdentifyer = @pParamsIdentifyer
	
	

	-- select * from ntAverageValuesResultsAgregated
	If object_ID('tempdb..#ntAverageValuesResultsAgregated') Is not Null drop table #ntAverageValuesResultsAgregated
	If object_ID('tempdb..#ntAverageValuesResultsAgregatedMaxCntValues') Is not Null drop table #ntAverageValuesResultsAgregatedMaxCntValues
	If object_ID('tempdb..#ntAverageValuesResultsAgregatedMinCtimeFirst') Is not Null drop table #ntAverageValuesResultsAgregatedMinCtimeFirst



	If object_ID('tempdb..#ntImportCurrentChartAverageValues') Is not Null drop table #ntImportCurrentChartAverageValues

 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 2


	select *
	into #ntImportCurrentChartAverageValues
	from ntImportCurrentChartAverageValues with (nolock)
	where ParamsIdentifyer = @pParamsIdentifyer
	
 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 3


	-- добавляем общие показатели по дате расчета
	-- SELECT c.*, v.*
	update c
	set	c.CcorrMax = v.CcorrMax,
		c.CcorrAvg = v.CcorrAvg,
		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt = v.TakeProfit_isOk_Daily_up_AvgCnt, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
		c.TakeProfit_isOk_Daily_down_AvgCnt = v.TakeProfit_isOk_Daily_down_AvgCnt, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
		c.TakeProfit_isOk_Daily_up_PrcBars = v.TakeProfit_isOk_Daily_up_PrcBars, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		c.TakeProfit_isOk_Daily_down_PrcBars = v.TakeProfit_isOk_Daily_down_PrcBars, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt = v.TakeProfit_isOk_AtOnce_up_AvgCnt, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt = v.TakeProfit_isOk_AtOnce_down_AvgCnt, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
		-- (3)
		c.ChighMax_Daily_Avg = v.ChighMax_Daily_Avg, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		c.ClowMin_Daily_Avg = v.ClowMin_Daily_Avg, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		c.ChighMax_AtOnce_Avg = v.ChighMax_AtOnce_Avg, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		c.ClowMin_AtOnce_Avg = v.ClowMin_AtOnce_Avg, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt_nd = v.TakeProfit_isOk_Daily_up_AvgCnt_nd, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
		c.TakeProfit_isOk_Daily_down_AvgCnt_nd = v.TakeProfit_isOk_Daily_down_AvgCnt_nd, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
		c.TakeProfit_isOk_Daily_up_PrcBars_nd = v.TakeProfit_isOk_Daily_up_PrcBars_nd, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		c.TakeProfit_isOk_Daily_down_PrcBars_nd = v.TakeProfit_isOk_Daily_down_PrcBars_nd, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
		-- (3)
		c.ChighMax_Daily_Avg_nd = v.ChighMax_Daily_Avg_nd, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		c.ClowMin_Daily_Avg_nd = v.ClowMin_Daily_Avg_nd, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		c.ChighMax_AtOnce_Avg_nd = v.ChighMax_AtOnce_Avg_nd, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		c.ClowMin_AtOnce_Avg_nd = v.ClowMin_AtOnce_Avg_nd -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	from #ntImportCurrentChartAverageValues c
	left outer join ntImportCurrent cf with (nolock) on cf.ParamsIdentifyer = @pParamsIdentifyer and cf.cdate + ' ' + cf.ctime = @cDateTimeFirst -- строка с временем начала расчета К
	 -- строка с уже рассчитанными показателями по текущей дате
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = (case when @pCntBarsCalcCorr = 0 then @cDateTimeFirst else v.cdatetime_first end) -- совпадает время начала расчета К (не анализируем при @pCntBarsCalcCorr > 0)
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- совпадает время окончания расчета общих показателей
		-- совпадают цены в начале расчетного периода (не анализируем при @pCntBarsCalcCorr > 0)
		and v.copen_first = (case when @pCntBarsCalcCorr = 0 then cf.copen else v.copen_first end)
		and v.chigh_first = (case when @pCntBarsCalcCorr = 0 then cf.chigh else v.chigh_first end)
		and v.clow_first = (case when @pCntBarsCalcCorr = 0 then cf.clow else v.clow_first end)
		and v.cclose_first = (case when @pCntBarsCalcCorr = 0 then cf.cclose else v.cclose_first end)
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
		and v.cntBarsCalcCorr = @pCntBarsCalcCorr
		
		and v.CntBarsMinLimit = @CntBarsMinLimit
		and v.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit	  
		and v.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit	  
		and v.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime	  
		and v.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr	  
		and v.CalcCorrParamsId = @CalcCorrParamsId	  
				
	--where c.ParamsIdentifyer = @pParamsIdentifyer
	--where c.cdate + ' ' + c.ctime >= @cDateTimeFirstCalc
	--	and c.cdate + ' ' + c.ctime <= @cDateTimeLastCalc
	--	and v.idn is null -- общие показатели не рассчитаны



 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 4




	-- добавляем общие показатели по другим датам
	
	-- группируем уже рассчитанные показатели
	select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, isCalcAverageValuesInPercents,
		COUNT(*) as cntValues
	into #ntAverageValuesResultsAgregated
	from ntAverageValuesResults with (nolock)
	where cntCharts = @cntCharts 
	  and StopLoss = @StopLoss 
	  and TakeProfit = @TakeProfit 
	  and OnePoint = @OnePoint 
	  and CurrencyId_current = @CurrencyId_current 
	  and CurrencyId_history = @CurrencyId_history 
	  and DataSourceId = @DataSourceId 
	  and PeriodMinutes = @PeriodMinutes 
	  and isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents
	  and cntBarsCalcCorr = @pCntBarsCalcCorr
	  and cTime_First = right(@cDateTimeFirst,5) -- совпадает cTime_First
	  
	  and CntBarsMinLimit = @CntBarsMinLimit
	  and DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit	  
	  and DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit	  
	  and IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime	  
	  and DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr	  
	  and CalcCorrParamsId = @CalcCorrParamsId	  
	  
	group by cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, isCalcAverageValuesInPercents


-- select 1, * from #ntAverageValuesResultsAgregated

	-- отбираем те записи, у которых в текущем графике есть совпадающая запись для начала расчета К
	update v set cntValues = 0
	-- select * 
	from #ntAverageValuesResultsAgregated v
	left outer join #ntImportCurrentChartAverageValues c with (nolock) on 
			--c.ParamsIdentifyer = @pParamsIdentifyer
			c.cdate = v.cdate_first
	where c.cdatetime is null

	delete from #ntAverageValuesResultsAgregated where cntValues = 0

-- select 2, * from #ntAverageValuesResultsAgregated

	-- определяем максимальное количество рассчитанных показателей по дням
	select cdate_first, MAX(cntValues) as MaxCntValues
	into #ntAverageValuesResultsAgregatedMaxCntValues
	from #ntAverageValuesResultsAgregated
	group by cdate_first

	-- select * from #ntAverageValuesResultsAgregatedMaxCntValues

	-- отбираем записи с максимальным количеством рассчитанных показателей
	update v set cntValues = 0
	--select * 
	from #ntAverageValuesResultsAgregated v
	left outer join #ntAverageValuesResultsAgregatedMaxCntValues m on 
		  m.cdate_first = v.cdate_first
	  and m.MaxCntValues = v.CntValues
	where m.MaxCntValues is null

	delete from #ntAverageValuesResultsAgregated where cntValues = 0

-- select 3, * from #ntAverageValuesResultsAgregated

	-- отбираем записи с минимальным временем начала расчета К
	select cdate_first, min(ctime_first) as MinCtimeFirst
	into #ntAverageValuesResultsAgregatedMinCtimeFirst
	from #ntAverageValuesResultsAgregated
	group by cdate_first

	update v set cntValues = 0
	--select * 
	from #ntAverageValuesResultsAgregated v
	left outer join #ntAverageValuesResultsAgregatedMinCtimeFirst m on 
		  m.cdate_first = v.cdate_first
	  and m.MinCtimeFirst = v.ctime_first
	where m.MinCtimeFirst is null

	delete from #ntAverageValuesResultsAgregated where cntValues = 0

-- select 4, * from #ntAverageValuesResultsAgregated

 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 5


	-- добавляем общие показатели по другим датам
	 --SELECT * --c.*, v.*
	update c
	set	c.CcorrMax = v.CcorrMax,
		c.CcorrAvg = v.CcorrAvg,
		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt = v.TakeProfit_isOk_Daily_up_AvgCnt, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
		c.TakeProfit_isOk_Daily_down_AvgCnt = v.TakeProfit_isOk_Daily_down_AvgCnt, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
		c.TakeProfit_isOk_Daily_up_PrcBars = v.TakeProfit_isOk_Daily_up_PrcBars, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		c.TakeProfit_isOk_Daily_down_PrcBars = v.TakeProfit_isOk_Daily_down_PrcBars, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt = v.TakeProfit_isOk_AtOnce_up_AvgCnt, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt = v.TakeProfit_isOk_AtOnce_down_AvgCnt, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
		-- (3)
		c.ChighMax_Daily_Avg = v.ChighMax_Daily_Avg, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		c.ClowMin_Daily_Avg = v.ClowMin_Daily_Avg, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		c.ChighMax_AtOnce_Avg = v.ChighMax_AtOnce_Avg, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		c.ClowMin_AtOnce_Avg = v.ClowMin_AtOnce_Avg, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt_nd = v.TakeProfit_isOk_Daily_up_AvgCnt_nd, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
		c.TakeProfit_isOk_Daily_down_AvgCnt_nd = v.TakeProfit_isOk_Daily_down_AvgCnt_nd, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
		c.TakeProfit_isOk_Daily_up_PrcBars_nd = v.TakeProfit_isOk_Daily_up_PrcBars_nd, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		c.TakeProfit_isOk_Daily_down_PrcBars_nd = v.TakeProfit_isOk_Daily_down_PrcBars_nd, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
		-- (3)
		c.ChighMax_Daily_Avg_nd = v.ChighMax_Daily_Avg_nd, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		c.ClowMin_Daily_Avg_nd = v.ClowMin_Daily_Avg_nd, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		c.ChighMax_AtOnce_Avg_nd = v.ChighMax_AtOnce_Avg_nd, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		c.ClowMin_AtOnce_Avg_nd = v.ClowMin_AtOnce_Avg_nd -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	from #ntImportCurrentChartAverageValues c
	left outer join #ntAverageValuesResultsAgregated a on a.cdate_first = c.cdate -- определяем cdate_first, для которого будем выводить рассчитанные показатели по дням
	 -- строка с уже рассчитанными показателями по текущей дате
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = a.cdatetime_first -- совпадает время начала расчета К
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- совпадает время окончания расчета общих показателей
		-- совпадают цены в начале расчетного периода
		and v.copen_first = a.copen_first
		and v.chigh_first = a.chigh_first
		and v.clow_first = a.clow_first
		and v.cclose_first = a.cclose_first
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
		
		and v.CntBarsMinLimit = @CntBarsMinLimit
		and v.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit	  
		and v.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit	  
		and v.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime	  
		and v.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr	  
		and v.CalcCorrParamsId = @CalcCorrParamsId	  
		
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			c.CcorrMax is NULL -- общие показатели не рассчитаны
	    and c.cdate <> left(@cDateTimeFirst,10) -- другие даты
	
 --select 5, * from ntImportCurrentChartAverageValues where ParamsIdentifyer = @pParamsIdentifyer
 
 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 6

	-- оставляем ABV только за нужные дни
	If object_ID('tempdb..#CntDaysPreviousShowABV') Is not Null drop table #CntDaysPreviousShowABV
	CREATE TABLE #CntDaysPreviousShowABV(
		[idn] int identity(1,1),
		[cdate] [varchar](10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL
	) ON [PRIMARY]
	CREATE UNIQUE CLUSTERED INDEX [idn0index] ON #CntDaysPreviousShowABV 
	([idn] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

	insert into #CntDaysPreviousShowABV(cdate)
	select distinct cdate
	from #ntImportCurrentChartAverageValues
	--where ParamsIdentifyer = @pParamsIdentifyer 
	order by cdate desc
	
	update c 
	set c.ABV = null, c.ABVMini = null, ccntOpenPos = null
	from #ntImportCurrentChartAverageValues c
	left outer join #CntDaysPreviousShowABV d on d.cdate = c.cdate
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			d.idn > @pCntDaysPreviousShowABV

	update c 
	set ccntOpenPos = null
	from #ntImportCurrentChartAverageValues c
	left outer join #CntDaysPreviousShowABV d on d.cdate = c.cdate
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			d.idn <= @pCntDaysPreviousShowABV
		and c.ccntOpenPos = 0


 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 7
	
	--select * 
	update c
	set	c.CcorrMax = v.CcorrMax,
		c.CcorrAvg = v.CcorrAvg,
		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt = v.TakeProfit_isOk_Daily_up_AvgCnt, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
		c.TakeProfit_isOk_Daily_down_AvgCnt = v.TakeProfit_isOk_Daily_down_AvgCnt, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
		c.TakeProfit_isOk_Daily_up_PrcBars = v.TakeProfit_isOk_Daily_up_PrcBars, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		c.TakeProfit_isOk_Daily_down_PrcBars = v.TakeProfit_isOk_Daily_down_PrcBars, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt = v.TakeProfit_isOk_AtOnce_up_AvgCnt, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt = v.TakeProfit_isOk_AtOnce_down_AvgCnt, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
		-- (3)
		c.ChighMax_Daily_Avg = v.ChighMax_Daily_Avg, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		c.ClowMin_Daily_Avg = v.ClowMin_Daily_Avg, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		c.ChighMax_AtOnce_Avg = v.ChighMax_AtOnce_Avg, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		c.ClowMin_AtOnce_Avg = v.ClowMin_AtOnce_Avg, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt_nd = v.TakeProfit_isOk_Daily_up_AvgCnt_nd, -- кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
		c.TakeProfit_isOk_Daily_down_AvgCnt_nd = v.TakeProfit_isOk_Daily_down_AvgCnt_nd, -- кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
		c.TakeProfit_isOk_Daily_up_PrcBars_nd = v.TakeProfit_isOk_Daily_up_PrcBars_nd, -- (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		c.TakeProfit_isOk_Daily_down_PrcBars_nd = v.TakeProfit_isOk_Daily_down_PrcBars_nd, -- (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
		-- (3)
		c.ChighMax_Daily_Avg_nd = v.ChighMax_Daily_Avg_nd, -- среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		c.ClowMin_Daily_Avg_nd = v.ClowMin_Daily_Avg_nd, -- среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		c.ChighMax_AtOnce_Avg_nd = v.ChighMax_AtOnce_Avg_nd, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		c.ClowMin_AtOnce_Avg_nd = v.ClowMin_AtOnce_Avg_nd -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
			
	from ntImportCurrentChartAverageValues c
	inner join #ntImportCurrentChartAverageValues v on v.idn = c.idn
	where v.idn is not null

 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 8
	    
END

--go
--exec ntpImportCurrentChartAverageValues '2016.05.26 02:10', '2016.05.26 10:30', '2016.05.26 23:55', 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '6E_5_v11_PA2', 100, 0

--exec ntpImportCurrentChartAverageValues '2016.05.02 01:05', '2016.05.02 11:00', '2016.05.02 23:55', 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5', 100, 0
--go
 --select * from ntImportCurrentChartAverageValues where ParamsIdentifyer = '6E_5_v11_PA2' order by idn 
 --select * from ntImportCurrent cf where cf.ParamsIdentifyer = '6E_5_v11_PA2' and cf.cdate + ' ' + cf.ctime = '2016.05.26 02:10' -- строка с временем начала расчета К

	
