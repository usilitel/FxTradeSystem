



	
-- !!! ПРОВЕРИТЬ: в поле ntAverageValuesResults.ParamsIdentifyer заменить временные ParamsIdentifyer-ы (_v02,_v03) на постоянные
/*


	 select distinct --left(ParamsIdentifyer,len(ParamsIdentifyer)-4), replace(ParamsIdentifyer,'_v02',''), 
			ParamsIdentifyer 
	from ntAverageValuesResults 
	 where ParamsIdentifyer like '%_v%' 
	 order by ParamsIdentifyer

	 select ParamsIdentifyer,  left(ParamsIdentifyer,len(ParamsIdentifyer)-4), *
	-- update ntAverageValuesResults set ParamsIdentifyer = '6B_15_120_PA211_lp1530'
	from ntAverageValuesResults
	where ParamsIdentifyer like '6B%_v0%'

		
	select * from ntAverageValuesResults where ParamsIdentifyer is null
*/


/*
-- 	update ntAverageValuesResults set ParamsIdentifyer = null
	
	-- переопределяем ParamsIdentifyer в таблице ntAverageValuesResults
	-- (нужно делать если изменился список нужных ParamsIdentifyer-ов в таблице nt_st_parameters_ParamsIdentifyersSets)
	update r
	set r.ParamsIdentifyer = isnull(p2.ParamsIdentifyer,'')
	-- select isnull(p2.ParamsIdentifyer,''), *
	from ntAverageValuesResults r
	left outer join ntSettingsFilesParameters_cn p2 with (nolock) on -- совпадают параметры расчета общих показателей
		    p2.ctimefirst = r.ctime_first 
			and p2.cntCharts = r.cntCharts 
			and p2.StopLoss = r.StopLoss
			and p2.TakeProfit = r.TakeProfit
		and p2.OnePoint = r.OnePoint
		and p2.CurrencyId_current = r.CurrencyId_current
		and p2.CurrencyId_history = r.CurrencyId_history
		and p2.DataSourceId = r.DataSourceId
		and p2.PeriodMinutes = r.PeriodMinutes
			and p2.isCalcAverageValuesInPercents = r.isCalcAverageValuesInPercents
		and isnull(p2.CntBarsCalcCorr,0) = isnull(r.CntBarsCalcCorr,0)
			  and p2.CntBarsMinLimit = r.CntBarsMinLimit
			  and p2.DeltaCcloseRangeMaxLimit = r.DeltaCcloseRangeMaxLimit	  
			  and p2.DeltaCcloseRangeMinLimit = r.DeltaCcloseRangeMinLimit	  
			  and p2.IsCalcCorrOnlyForSameTime = r.IsCalcCorrOnlyForSameTime	  
			  and p2.DeltaMinutesCalcCorr = r.DeltaMinutesCalcCorr	  
		and p2.CalcCorrParamsId = r.CalcCorrParamsId
		--and p2.ctime_CalcAverageValuesWithNextDay = r.ctime_CalcAverageValuesWithNextDay
	left outer join nt_st_parameters_ParamsIdentifyersSets ps with (nolock) on -- берем только активные ParamsIdentifyer
		ps.ParamsIdentifyer = p2.ParamsIdentifyer
		--and ps.is_active = 1
	where --ps.is_active = 1 -- берем только активные ParamsIdentifyer
		ps.ParamsIdentifyersSetId in (12) -- берем только нужные ParamsIdentifyer
		and r.ParamsIdentifyer is null
*/


--select distinct ParamsIdentifyer from ntAverageValuesResults (nolock)
--select * from ntSettingsFilesParameters_cn where CalcCorrParamsId = '1-0-0' order by ThreadId, ParamsIdentifyer
--select * from nt_st_parameters_ParamsIdentifyersSets order by ParamsIdentifyersSetId, ParamsIdentifyer
-- select ParamsIdentifyer, count(*) from nt_st_parameters_ParamsIdentifyersSets group by ParamsIdentifyer order by count(*) -- проверяем повторяющиеся ParamsIdentifyer-ы









/*

-- задаем активные ParamsIdentifyer




--------------------------


--------------------------



select * from nt_st_parameters_ParamsIdentifyersSets where is_active = 1
select * 
-- update nt_st_parameters_ParamsIdentifyersSets set is_active = 1
from nt_st_parameters_ParamsIdentifyersSets where --ParamsIdentifyer in ('6B_15_120_PA211_lp2040') and
	 ParamsIdentifyersSetId = 11

-- update nt_st_parameters_ParamsIdentifyersSets set is_active = -1 where is_active = 1
-- update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where is_active = -1 and ParamsIdentifyersSetId = 3

select * from nt_st_parameters_ParamsIdentifyersSets where is_active = 1 -- ('6E_15_120','6E_15_30','6E_30_120','6E_30_30')
-- 6E_15_120_PA211 6E_15_30_PA211 6E_30_120_PA211 6E_30_30_PA211



select * from nt_st_parameters_ParamsIdentifyersSets where ParamsIdentifyer in ('6E_15_60_PA211_d2','6E_15_90_PA211_d2','6E_30_60_PA211_d2','6E_30_90_PA211_d2','6E_45_60_PA211_d2','6E_45_90_PA211_d2')
select * from nt_st_parameters_ParamsIdentifyersSets where ParamsIdentifyersSetId = 11



-- добавляем новый ParamsIdentifyersSetId
insert into nt_st_parameters_ParamsIdentifyersSets (ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active)
select 8 as ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active
from nt_st_parameters_ParamsIdentifyersSets 
where ParamsIdentifyersSetId = 3

update nt_st_parameters_ParamsIdentifyersSets set is_active = 0 where ParamsIdentifyersSetId = 1
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyersSetId = 11
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyersSetId = 13
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyer in ('6E_15_60_PA211_d2','6E_15_90_PA211_d2','6E_30_60_PA211_d2','6E_30_90_PA211_d2','6E_45_60_PA211_d2','6E_45_90_PA211_d2')
update nt_st_parameters_ParamsIdentifyersSets set is_active = -1 where is_active = 1
update nt_st_parameters_ParamsIdentifyersSets set is_active = 0 where is_active = 1

6E_15_120_PA211_cal
6E_15_30_PA211_cal
6E_30_120_PA211_cal
6E_30_60_PA211_cal
6E_45_120_PA211_cal
6E_45_90_PA211_cal

update nt_st_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.298, limit_TakeProfit_isOk_atOnce_up_down_AvgCnt_delta = 0.298 where ParamsIdentifyersSetId = 8
update nt_st_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.2 where ParamsIdentifyersSetId = 8
update nt_st_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.2, limit_TakeProfit_isOk_atOnce_up_down_AvgCnt_delta = 0.298 where ParamsIdentifyersSetId = 8
update nt_st_parameters_ParamsIdentifyersSets set limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.2, limit_TakeProfit_isOk_atOnce_up_down_AvgCnt_delta = 0.4 where ParamsIdentifyersSetId = 8






-- убираем активные ParamsIdentifyer
update nt_st_parameters_ParamsIdentifyersSets set is_active = 0 where is_active = 1
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyer in ('6E_15_120_PA211_cal','6E_15_30_PA211_cal','6E_30_120_PA211_cal','6E_30_60_PA211_cal','6E_45_120_PA211_cal','6E_45_90_PA211_cal')
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyer in ('6B_45_90_PA211','6B_30_30_PA211','6B_30_120_PA211','6B_45_120_PA211','6B_45_30_PA211','6B_15_90_PA211','6B_15_60_PA211')
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyer in ('6E_45_60_PA211_d2','6E_15_60_PA211_d2','6E_15_90_PA211_d2','6E_30_90_PA211_d2','6E_45_90_PA211_d2','6E_30_60_PA211_d2')




select * from nt_st_parameters_ParamsIdentifyersSets 
-- update nt_st_parameters_ParamsIdentifyersSets set is_active = 1, limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.6, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.6
-- update nt_st_parameters_ParamsIdentifyersSets set is_active = 1, limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.498, limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.498
-- update nt_st_parameters_ParamsIdentifyersSets set is_active = 1, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.298, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta = 0.298
--where ParamsIdentifyer in ('6E_30_120_PA211','6E_30_30_PA211','6E_30_60_PA211','6E_30_90_PA211','6E_45_120_PA211','6E_45_30_PA211','6E_45_60_PA211','6E_45_90_PA211')
--where ParamsIdentifyer in ('6E_15_120_PA211','6E_30_120_PA211')
--where ParamsIdentifyer in ('6E_15_120_PA110','6E_15_30_PA110','6E_30_120_PA110','6E_30_30_PA110')
--where ParamsIdentifyer in ('6E_15_120_PA211','6E_15_30_PA211','6E_30_120_PA211','6E_30_30_PA211')
--where ParamsIdentifyer in ('6E_45_120_PA211_r','6E_45_90_PA211_r','6E_30_120_PA211_r','6E_30_60_PA211_r','6E_15_30_PA211_r','6E_15_120_PA211_r')
where ParamsIdentifyer in ('6E_45_120_PA211','6E_45_90_PA211','6E_30_120_PA211','6E_30_60_PA211','6E_15_30_PA211','6E_15_120_PA211')
where ParamsIdentifyer in ('6E_45_120_PAV2111','6E_45_90_PAV2111','6E_30_120_PAV2111','6E_30_60_PAV2111','6E_15_30_PAV2111','6E_15_120_PAV2111')


where ParamsIdentifyersSetId = 3
where ParamsIdentifyer in ('6E_15_120_PAV2111','6E_15_30_PAV2111','6E_30_120_PAV2111','6E_30_30_PAV2111')
where ParamsIdentifyer in ('6E_15_120','6E_15_30','6E_30_120','6E_30_30')
where ParamsIdentifyer in ('6E_15_120_PA211','6E_15_30_PA211','6E_15_60_PA211','6E_15_90_PA211','6E_30_120_PA211','6E_30_30_PA211','6E_30_60_PA211','6E_30_90_PA211')
where ParamsIdentifyer in ('6E_15_120','6E_15_30','6E_30_120','6E_30_30')
where ParamsIdentifyer in ('6E_15_120_PA211','6E_15_30_PA211','6E_15_60_PA211','6E_15_90_PA211','6E_30_120_PA211','6E_30_30_PA211','6E_30_60_PA211','6E_30_90_PA211')
where ParamsIdentifyer in ('6E_15_120','6E_15_120_PA211')




select * 
from ntAverageValuesResults (nolock) 
where ParamsIdentifyer in ('6E_45_120_PA211','6E_45_90_PA211','6E_30_120_PA211','6E_30_60_PA211','6E_15_30_PA211','6E_15_120_PA211')
order by cdatetime_last desc, ParamsIdentifyer -- рассчитанные общие показатели (за все время)



-- update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyersSetId in (3)


select * from nt_st_parameters_ParamsIdentifyersSets where is_active = 1
update nt_st_parameters_ParamsIdentifyersSets set is_active = 0 where ParamsIdentifyersSetId in (11)
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyersSetId in (12)
update nt_st_parameters_ParamsIdentifyersSets set is_active = 0 where ParamsIdentifyersSetId in (8)

*/




-- тестер стратегий
-- запускаем тест стратегии с перебором параметров


/*

-- очищаем график цены (не надо очищать)
-- truncate table nt_st_chart
-- delete from nt_st_chart where cdate >= '2016.03.01'
select * from nt_st_chart order by idn
select * from nt_st_chart order by cdatetime desc
select * into _nt_st_chart_old2 from nt_st_chart order by cdatetime
select * into _nt_st_chart_old3 from nt_st_chart order by cdatetime
select * into _nt_st_chart_old4 from nt_st_chart order by cdatetime
select * into _nt_st_chart_old5 from nt_st_chart order by cdatetime
select * from nt_st_chart where cdate >= '2016.03.01' order by cdatetime
select * into nt_st_chart_EURUSD from nt_st_chart order by cdatetime
select * into nt_st_chart_GBPUSD from nt_st_chart order by cdatetime

select * from nt_st_chart where cdate >= '2016.02.01' and cdate <= '2016.08.03' order by cdatetime



insert into nt_st_chart (cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer)
select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer
from nt_st_chart_EURUSD order by cdatetime

insert into nt_st_chart (cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer)
select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer
from nt_st_chart_GBPUSD order by cdatetime

select * from _nt_st_chart_old4
select * from nt_st_chart

select datediff(dd,'01.01.2015','13.07.2016')


-- в Access запускаем следующий запрос (заполняем график) 
-- (перед запуском выгрузить исходный файл из NT И задать параметры)
-- после записи выстроить записи по порядку (см.следующий запрос)
insert into nt_st_chart (cdate , ctime , cdatetime , copen , chigh , clow , cclose , Volume , ABV , ABVMini , ABMmPosition0 , ABMmPosition1,
	CurrencyIdCurrent,
	CurrencyIdHistory,
	DataSourceId,
	PeriodMinutes,
	PeriodMultiplicatorMin,
	PeriodMultiplicatorMax,
	ParamsIdentifyer)
select cdate , ctime , cdatetime , copen , chigh , clow , cclose , Volume , ABV , ABVMini , ABMmPosition0 , ABMmPosition1,
	1 as CurrencyIdCurrent,
	1 as CurrencyIdHistory,
	2 as DataSourceId,
	5 as PeriodMinutes,
	1 as PeriodMultiplicatorMin,
	1 as PeriodMultiplicatorMax,
	'1_5_20150611' as ParamsIdentifyer
from ntImport_6E_Minute_5_id4
where cdate >= '2016.03.01'
  and cdate <= '2017.05.26'
order by cdatetime





*/


-- select * from ntAverageValuesResults_history where ParamsIdentifyer in ('6E_15_120_PA211','6E_15_30_PA211','6E_30_120_PA211','6E_30_60_PA211','6E_45_120_PA211','6E_45_90_PA211')
-- select * from nt_st_chart_1_5

-- SET NOCOUNT OFF



declare
	@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	-- прочие параметры стратегии
	@param_volume real
	
	-- update nt_st_chart set CurrencyIdCurrent = 1, CurrencyIdHistory = 1
	
select
	--@CurrencyIdCurrent = 42, @CurrencyIdHistory = 42, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',
	--@CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',
	@CurrencyIdCurrent = 4, @CurrencyIdHistory = 4, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, --@StopLoss = 30, @TakeProfit = 15, @OnePoint = 0.0001, --@ParamsIdentifyer = '1_5_20150611',
	--@cdatetime_first = '2015.01.01 05:00', @cdatetime_last = '2015.06.10 21:00'
	--@cdatetime_first = '2015.06.11 05:00', @cdatetime_last = '2016.02.05 21:00'
	--@cdatetime_first = '2015.01.01 05:00', @cdatetime_last = '2016.02.05 21:00'
	--@cdatetime_first = '2015.03.25 05:00', @cdatetime_last = '2015.06.11 21:00'
	--@cdatetime_first = '2014.01.01 05:00', @cdatetime_last = '2014.04.28 21:00'
	--@cdatetime_first = '2015.12.16 05:00', @cdatetime_last = '2016.02.05 21:00'
	--@cdatetime_first = '2015.04.01 05:00', @cdatetime_last = '2016.02.05 21:00'	
	--@cdatetime_first = '2015.11.01 05:00', @cdatetime_last = '2016.02.05 21:00'
	--@cdatetime_first = '2016.06.02 15:00', @cdatetime_last = '2016.06.06 21:00'	
	--@cdatetime_first = '2016.05.09 01:00', @cdatetime_last = '2016.06.06 21:00'	
	
	--@cdatetime_first = '2016.03.01 01:00', @cdatetime_last = '2016.06.06 21:00'	
	--@cdatetime_first = '2015.10.01 01:00', @cdatetime_last = '2015.12.31 21:00'
	--@cdatetime_first = '2015.03.01 01:00', @cdatetime_last = '2015.06.06 21:00'
	---@cdatetime_first = '2015.03.01 01:00', @cdatetime_last = '2015.12.31 21:00'
	
	--@cdatetime_first = '2015.03.01 01:00', @cdatetime_last = '2016.06.06 21:00'
	--@cdatetime_first = '2015.07.01 01:00', @cdatetime_last = '2015.12.14 21:00'
	--@cdatetime_first = '2014.11.01 01:00', @cdatetime_last = '2017.06.06 21:00'
	--@cdatetime_first = '2014.11.01 01:00', @cdatetime_last = '2015.02.28 21:00'
	--@cdatetime_first = '2015.02.01 01:00', @cdatetime_last = '2017.06.06 21:00'
	
	--@cdatetime_first = '2016.02.01 01:00', @cdatetime_last = '2016.08.03 21:00'
	--@cdatetime_first = '2015.12.01 01:00', @cdatetime_last = '2016.01.31 21:00'
	--@cdatetime_first = '2016.03.03 01:00', @cdatetime_last = '2016.03.03 21:00'
	--@cdatetime_first = '2016.06.20 01:00', @cdatetime_last = '2016.08.03 21:00'
	--@cdatetime_first = '2015.01.01 01:00', @cdatetime_last = '2017.01.31 21:00'
	@cdatetime_first = '2013.09.01 01:00', @cdatetime_last = '2017.07.31 21:00'
	
	-- 6B
	--@cdatetime_first = '2016.02.01 01:00', @cdatetime_last = '2017.06.06 21:00'
	





	If object_ID('tempdb..#nt_st_chart') Is not Null drop table #nt_st_chart
	If object_ID('tempdb..#nt_st_deals') Is not Null drop table #nt_st_deals
	If object_ID('tempdb..#ntAverageValuesResults') Is not Null drop table #ntAverageValuesResults
	
-- select * from ntAverageValuesResults

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 21


		
	select r.* --, space(20) as ParamsIdentifyer
	into #ntAverageValuesResults
	from ntAverageValuesResults	r with (nolock)
	left outer join nt_st_parameters_ParamsIdentifyersSets ps with (nolock) on 
		ps.ParamsIdentifyer = r.ParamsIdentifyer
	where   r.CurrencyId_Current = @CurrencyIdCurrent
		and r.CurrencyId_History = @CurrencyIdHistory
		and r.cdatetime_last >= @cdatetime_first
		and r.cdatetime_last <= @cdatetime_last
		and isnull(ps.is_active,0) <> 0

-- select * from #ntAverageValuesResults order by cdatetime_last

	
	--select * --, space(20) as ParamsIdentifyer
	--into #ntAverageValuesResults
	--from ntAverageValuesResults	with (nolock)
	--where   CurrencyId_Current = @CurrencyIdCurrent
	--	and CurrencyId_History = @CurrencyIdHistory
	--	and cdatetime_last >= @cdatetime_first
	--	and cdatetime_last <= @cdatetime_last


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 22
	
CREATE INDEX [index1] ON #ntAverageValuesResults 
(ParamsIdentifyer ASC, cdatetime_last ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 23



-- select * from nt_st_parameters_ParamsIdentifyersSets


	---- определяем ParamsIdentifyer в таблице ntAverageValuesResults
	--update r
	--set r.ParamsIdentifyer = isnull(p2.ParamsIdentifyer,'')
	--from #ntAverageValuesResults r
	--left outer join ntSettingsFilesParameters_cn p2 with (nolock) on -- совпадают параметры расчета общих показателей
	--	    p2.ctimefirst = r.ctime_first 
	--		and p2.cntCharts = r.cntCharts 
	--		and p2.StopLoss = r.StopLoss
	--		and p2.TakeProfit = r.TakeProfit
	--	and p2.OnePoint = r.OnePoint
	--	and p2.CurrencyId_current = r.CurrencyId_current
	--	and p2.CurrencyId_history = r.CurrencyId_history
	--	and p2.DataSourceId = r.DataSourceId
	--	and p2.PeriodMinutes = r.PeriodMinutes
	--		and p2.isCalcAverageValuesInPercents = r.isCalcAverageValuesInPercents
	--	and isnull(p2.CntBarsCalcCorr,0) = isnull(r.CntBarsCalcCorr,0)
	--		  and p2.CntBarsMinLimit = r.CntBarsMinLimit
	--		  and p2.DeltaCcloseRangeMaxLimit = r.DeltaCcloseRangeMaxLimit	  
	--		  and p2.DeltaCcloseRangeMinLimit = r.DeltaCcloseRangeMinLimit	  
	--		  and p2.IsCalcCorrOnlyForSameTime = r.IsCalcCorrOnlyForSameTime	  
	--		  and p2.DeltaMinutesCalcCorr = r.DeltaMinutesCalcCorr	  
	--	and p2.CalcCorrParamsId = r.CalcCorrParamsId
	--	--and p2.ctime_CalcAverageValuesWithNextDay = r.ctime_CalcAverageValuesWithNextDay
	--left outer join nt_st_parameters_ParamsIdentifyersSets ps with (nolock) on -- берем только активные ParamsIdentifyer
	--	ps.ParamsIdentifyer = p2.ParamsIdentifyer
	--	--and ps.is_active = 1
	--where ps.is_active = 1 -- берем только активные ParamsIdentifyer
			
	-- select * from #ntAverageValuesResults where ParamsIdentifyer = ''
	


	
	delete from #ntAverageValuesResults where isnull(ParamsIdentifyer,'') = ''
	

--	select * from #ntAverageValuesResults order by cdatetime_last,  ParamsIdentifyer
--	select distinct ParamsIdentifyer from #ntAverageValuesResults
	
	






	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 24

			
	select top 1 *, 
				 space(16) as cdatetime, -- бар открытия сделки
				 convert(int,null) as idn_chart_deal_cclose, -- idn_chart бара закрытия сделки
				 space(16) as cdatetime_deal_cclose, -- бар закрытия сделки
				 convert(int,null) as TimeInMinutes_deal_cclose, -- время закрытия сделки (минут с начала дня)
				 0 as CurrencyIdCurrent, 
				 0 as CurrencyIdHistory,
				 convert(float,0) as ABMmPosition0,
				 convert(float,0) as ABMmPosition1,
				 convert(int,null) as TimeInMinutes_deal_copen, -- время открытия сделки (минут с начала дня)
				 convert(real,null) as cclose_PreviousDay1, -- цена закрытия предыдущего торгового дня
				 convert(real,null) as cclose_PreviousDay2, -- цена закрытия пред-предыдущего торгового дня
				 convert(real,null) as chigh_PreviousDay1, -- максимальная цена предыдущего торгового дня
				 convert(real,null) as clow_PreviousDay1, -- минимальная цена предыдущего торгового дня
				 convert(real,null) as ABV_currDay_min, -- минимальный ABV за текущий торговый день
				 convert(real,null) as ABV_currDay_max, -- максимальный ABV за текущий торговый день
				 convert(real,null) as ABV_dealOpen, -- ABV на момент открытия сделки				 
				 convert(real,null) as K_ABV_ABVMini, -- К между ABV и ABVMini за текущий день (на момент заключения сделки)
				 convert(real,null) as K_cclose_ABV, -- К между cclose и ABV за текущий день (на момент заключения сделки)
				 convert(real,null) as K_cclose_ABVMini -- К между cclose и ABVMini за текущий день (на момент заключения сделки)				 
				 --space(16) as TimeInMinutes_deal_cclose -- время закрытия сделки (минут с начала дня)
	into #nt_st_deals
	from nt_st_deals

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 25


	-- select * from #nt_st_deals
	-- select * from #nt_st_chart order by cdatetime desc
	-- select * from nt_st_chart
	-- select * from #nt_st_chart
	

	
	truncate table #nt_st_deals

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 26

-- @CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',



	-- выбираем все цены и рассчитанные общие показатели
	-- если надо считать не за весь срок - то раскомментировать условия по датам
	SELECT  c.idn, c.copen, c.chigh, c.clow, c.cclose, c.Volume,
			c.cdatetime,
			c.ABV, c.ABVMini, CONVERT(int,LEFT(c.ctime,2))*60 + CONVERT(int,SUBSTRING(c.ctime,4,2)) as TimeInMinutes,
			--v.CcorrMax, v.CcorrAvg, v.TakeProfit_isOk_Daily_up_AvgCnt, v.TakeProfit_isOk_Daily_down_AvgCnt, v.TakeProfit_isOk_Daily_up_PrcBars, v.TakeProfit_isOk_Daily_down_PrcBars, v.TakeProfit_isOk_AtOnce_up_AvgCnt, v.TakeProfit_isOk_AtOnce_down_AvgCnt, v.ChighMax_Daily_Avg, v.ClowMin_Daily_Avg, v.ChighMax_AtOnce_Avg, v.ClowMin_AtOnce_Avg,
			--v.idn as idn_AverageValues
			-1 as cntBuySignals,
			-1 as cntSellSignals,
			c.CurrencyIdCurrent,
			c.CurrencyIdHistory,
			c.ABMmPosition0, 
			c.ABMmPosition1
	into #nt_st_chart
	from nt_st_chart c with (nolock)
	where
			c.CurrencyIdCurrent = @CurrencyIdCurrent
		and c.CurrencyIdHistory = @CurrencyIdHistory
		and c.DataSourceId = @DataSourceId
		and c.PeriodMinutes = @PeriodMinutes
		and c.PeriodMultiplicatorMin = @PeriodMultiplicatorMin
		and c.PeriodMultiplicatorMax = @PeriodMultiplicatorMax
		--and c.ParamsIdentifyer = @ParamsIdentifyer
		and c.cdatetime >= @cdatetime_first
		and c.cdatetime <= @cdatetime_last			
		--and v.cdatetime_last is not null -- на данное время рассчитаны общие показатели
		-- and CONVERT(int,LEFT(c.ctime,2))*60 + CONVERT(int,SUBSTRING(c.ctime,4,2)) >= @param_DealTimeInMinutesFirst -- не делать, т.к. будет неверно считаться закрытие сделки на следующий день
	order by c.cdatetime

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 27

-- select * from nt_st_chart
 -- select * from #nt_st_chart order by idn
 -- select * from #nt_st_deals order by idn

-- select * from #nt_st_chart
-- select * from #nt_st_chart  where idn = 63158
-- select * from nt_st_chart where idn = 63158

/*
-- задаем нужный ParamsIdentifyersSetId
update nt_st_parameters_ParamsIdentifyersSets set is_active = 0
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyersSetId = 2
*/

	--exec ntp_st_MakeDealsAllDays 
	exec ntp_st_MakeDealsAllDays_v04
		-- переменные для построения графика цены
		--@cntCharts = @cntCharts, 
		@StopLoss = 30, --45, -- 31
		@TakeProfit = 15, --20, -- 13
		@OnePoint = 0.0001, 
		--@ParamsIdentifyer = @ParamsIdentifyer,
		-- прочие параметры стратегии
		@param_cntSignalsBeforeDeal = 1,
		@param_volume = 10000,
		@param_IsOnlyOneActiveDeal = 0, -- 1 = только одна открытая позиция  в одну сторону (максимум один Buy и один Sell одновременно), 0 = неограниченное число открытых позиций (1 сигнал = 1 сделка)
		@param_IsOpenOppositeDeal = 0, -- 1 = если возникает противоположный сигнал - то закрываем все открытые позиции и открываем позицию по сигналу, 0 = закрываем позиции только по SL и TP

		--@ParamsIdentifyersSetId = 1,
		@param_cntBuySignalsLimit_Start = 2, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
		@param_cntSellSignalsLimit_Start = 2, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
		@param_cntBuySignalsLimit_Stop = 0, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
		@param_cntSellSignalsLimit_Stop = 0 -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПОКУПКУ
		
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 28

		 select * from #nt_st_deals order by cdatetime
		 select left(cdatetime,10) as cdate, count(*) as cndDeals from #nt_st_deals group by left(cdatetime,10) order by left(cdatetime,10)

		 -- select * from #nt_st_deals where deal_direction = 1 order by cdatetime
		 -- select * from #nt_st_deals where deal_direction = 2 order by cdatetime
		 -- select * from #nt_st_chart

		 

		 




		
-- select * from ntlog_ntCalendarIdnData order by cdatetime_log desc, idnDataEventdates desc
-- delete from ntlog_ntCalendarIdnData
		
/*
	select *, cp.idn, cl.idn, 
	case when isnull(cp.idn,100000000) < isnull(cl.idn,100000000) then deal_TakeProfit
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then deal_StopLoss
							 else 0 
						end as deal_cclose,
		--d.idn_chart_deal_cclose = -- idn_chart бара закрытия сделки
						case when isnull(cp.idn,100000000) < isnull(cl.idn,100000000) then isnull(cp.idn,100000000)
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then isnull(cl.idn,100000000)
							 else 0 
						end as idn_chart_deal_cclose
	from #nt_st_deals d
	left outer join #nt_st_chart cp on -- первый бар с TakeProfit
			cp.idn > d.idn_chart
		and cp.clow <= d.deal_TakeProfit
		and cp.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and clow <= d.deal_TakeProfit)
	left outer join #nt_st_chart cl on -- первый бар с StopLoss
			cl.idn > d.idn_chart
		and cl.chigh >= d.deal_StopLoss
		and cl.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and chigh >= d.deal_StopLoss)
	where d.deal_direction = 2
	*/
	
	
/*


	select * from #nt_st_deals
	select * from #nt_st_deals where deal_profit < 0
	select * from #nt_st_deals where deal_profit > 0

select * from #nt_st_deals
 select * from #nt_st_chart where cntBuySignals > 1
 select * from #nt_st_chart where cntSellSignals > 1
 
 

select * from #t_Signals order by cdatetime


*/

/*
 select * from #ntAverageValuesResults 
 where 1=1
	and cdate_last = '2015.12.07' 
	--and cdatetime_last = '2015.12.07 10:30' 
	and cntCharts = 15 
	and DeltaMinutesCalcCorr = 120 
 order by cdatetime_last

 select * from _ntAverageValuesResults_20151209 
 where 1=1
	and cdate_last = '2015.12.07' 
	--and cdatetime_last = '2015.12.07 10:30' 
	and cntCharts = 15 
--	and DeltaMinutesCalcCorr = 120 
	and isCalcAverageValuesInPercents = 1
	and CurrencyId_current = 1
 order by cdatetime_last
 */
 

-- select distinct ParamsIdentifyer from #ntAverageValuesResults
-- select distinct ParamsIdentifyer from ntAverageValuesResults


-- select * from #ntAverageValuesResults
-- select * from #nt_st_deals
-- select * from #nt_st_chart
-- select * from #t_SignalsParamsIdentifyer
-- ChighMax_Daily_Avg	ClowMin_Daily_Avg	ChighMax_AtOnce_Avg	ClowMin_AtOnce_Avg




	If object_ID('tempdb..#t_SignalsParamsIdentifyer') Is not Null drop table #t_SignalsParamsIdentifyer
	
-- анализируем прибыльность ParamsIdentifyer-ов

	-- вычисляем количество сигналов на покупку
	select  --c.idn, c.idn_chart, c.StopLoss, c.TakeProfit, c.OnePoint, c.param_StopLoss, c.param_TakeProfit, c.param_cntSignalsBeforeDeal, c.param_volume, c.deal_copen, c.deal_direction, c.deal_StopLoss, c.deal_TakeProfit, c.deal_volume, c.deal_cclose, c.deal_profit, c.deal_profit_total, c.cdatetime, c.idn_chart_deal_cclose, c.cdatetime_deal_cclose, c.TimeInMinutes_deal_cclose, c.CurrencyIdCurrent, c.CurrencyIdHistory, c.ABMmPosition0, c.ABMmPosition1, c.TimeInMinutes_deal_copen, c.cclose_PreviousDay1, c.cclose_PreviousDay2, c.chigh_PreviousDay1, c.clow_PreviousDay1, 
			--vb.TakeProfit_isOk_Daily_up_AvgCnt, vb.TakeProfit_isOk_Daily_down_AvgCnt, vb.TakeProfit_isOk_Daily_up_PrcBars, vb.TakeProfit_isOk_Daily_down_PrcBars, vb.TakeProfit_isOk_AtOnce_up_AvgCnt, vb.TakeProfit_isOk_AtOnce_down_AvgCnt, vb.ChighMax_Daily_Avg, vb.ClowMin_Daily_Avg, vb.ChighMax_AtOnce_Avg, vb.ClowMin_AtOnce_Avg
			c.*, 
			vb.ParamsIdentifyer as ParamsIdentifyer_signal,
			vb.CcorrMax, 
			vb.CcorrAvg
	into #t_SignalsParamsIdentifyer
	--from #nt_st_chart c
	from #nt_st_deals c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.is_active = 1 --ParamsIdentifyersSetId = 1
	left outer join #ntAverageValuesResults vb with (index=index1) on -- сигналы на покупку
			vb.ParamsIdentifyer = p.ParamsIdentifyer
		and vb.cdatetime_last = c.cdatetime
		and (
			 vb.TakeProfit_isOk_AtOnce_up_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			 --or
			 --v.TakeProfit_isOk_AtOnce_down_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_AtOnce_up_AvgCnt-vb.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vb.TakeProfit_isOk_Daily_up_AvgCnt >= p.limit_TakeProfit_isOk_Daily_up_AvgCnt
			 --or
			 --v.TakeProfit_isOk_Daily_down_AvgCnt >= p.limit_TakeProfit_isOk_Daily_down_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_Daily_up_AvgCnt-vb.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
	--group by c.idn
	where vb.ParamsIdentifyer is not null
	--order by c.idn, vb.ParamsIdentifyer
union all
	select  --c.idn, c.idn_chart, c.StopLoss, c.TakeProfit, c.OnePoint, c.param_StopLoss, c.param_TakeProfit, c.param_cntSignalsBeforeDeal, c.param_volume, c.deal_copen, c.deal_direction, c.deal_StopLoss, c.deal_TakeProfit, c.deal_volume, c.deal_cclose, c.deal_profit, c.deal_profit_total, c.cdatetime, c.idn_chart_deal_cclose, c.cdatetime_deal_cclose, c.TimeInMinutes_deal_cclose, c.CurrencyIdCurrent, c.CurrencyIdHistory, c.ABMmPosition0, c.ABMmPosition1, c.TimeInMinutes_deal_copen, c.cclose_PreviousDay1, c.cclose_PreviousDay2, c.chigh_PreviousDay1, c.clow_PreviousDay1,
			--vs.TakeProfit_isOk_Daily_up_AvgCnt, vs.TakeProfit_isOk_Daily_down_AvgCnt, vs.TakeProfit_isOk_Daily_up_PrcBars, vs.TakeProfit_isOk_Daily_down_PrcBars, vs.TakeProfit_isOk_AtOnce_up_AvgCnt, vs.TakeProfit_isOk_AtOnce_down_AvgCnt, vs.ChighMax_Daily_Avg, vs.ClowMin_Daily_Avg, vs.ChighMax_AtOnce_Avg, vs.ClowMin_AtOnce_Avg
			c.*, 
			vs.ParamsIdentifyer as ParamsIdentifyer_signal,
			vs.CcorrMax, 
			vs.CcorrAvg			
	--into #t_cntBuySignals
	--from #nt_st_chart c
	from #nt_st_deals c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.is_active = 1 --ParamsIdentifyersSetId = 1
	left outer join #ntAverageValuesResults vs with (index=index1) on -- сигналы на продажу
			vs.ParamsIdentifyer = p.ParamsIdentifyer
		and vs.cdatetime_last = c.cdatetime
		and (
			 --vb.TakeProfit_isOk_AtOnce_up_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			 --or
			 vs.TakeProfit_isOk_AtOnce_down_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_AtOnce_up_AvgCnt-vs.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 --vb.TakeProfit_isOk_Daily_up_AvgCnt >= p.limit_TakeProfit_isOk_Daily_up_AvgCnt
			 --or
			 vs.TakeProfit_isOk_Daily_down_AvgCnt >= p.limit_TakeProfit_isOk_Daily_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_Daily_up_AvgCnt-vs.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
	--group by c.idn
	where vs.ParamsIdentifyer is not null
	--order by c.idn, vs.ParamsIdentifyer

-- select * from #t_SignalsParamsIdentifyer order by idn_chart

If object_ID('tempdb..#t_SignalsParamsIdentifyer_Total') Is not Null drop table #t_SignalsParamsIdentifyer_Total

select  ParamsIdentifyer_signal, 
		sum(case when deal_profit < 0 then deal_profit else 0 end) as sum_loss,
		sum(case when deal_profit > 0 then deal_profit else 0 end) as sum_profit,
		sum(deal_profit) as sum_loss_profit,
		convert(float,0) as prc_loss,
		-- -sum(case when deal_profit < 0 then deal_profit else 0 end)/sum(case when deal_profit > 0 then deal_profit else 0 end) as prc_loss,
		count(*) as cnt_deals
into #t_SignalsParamsIdentifyer_Total
from #t_SignalsParamsIdentifyer
group by ParamsIdentifyer_signal
order by prc_loss

update #t_SignalsParamsIdentifyer_Total
set prc_loss =  -sum_loss*1.0/(-sum_loss + sum_profit)
				--case when sum_profit = 0
				--then 0
				--else -sum_loss*1.0/sum_profit end

select * from #t_SignalsParamsIdentifyer_Total order by prc_loss

-- CountCorr_cn -> CalcCorrelation -> PearsonCorrelationPrepare, PearsonCorrelationFirst, PearsonCorrelationAll


/*
select * from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit > 0 order by CcorrAvg
select * from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit < 0 order by CcorrAvg
select * from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit > 0 order by CcorrAvg
select * from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit < 0 order by CcorrAvg

select * from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit > 0 order by ChighMax_AtOnce_Avg
select * from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit < 0 order by ChighMax_AtOnce_Avg
select * from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit > 0 order by ChighMax_AtOnce_Avg
select * from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit < 0 order by ChighMax_AtOnce_Avg

select *, (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit > 0 order by (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg)
select *, (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit < 0 order by (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg)
select *, (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit > 0 order by (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg)
select *, (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit < 0 order by (ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg)

select *, (ChighMax_Daily_Avg - ClowMin_Daily_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit > 0 order by (ChighMax_Daily_Avg - ClowMin_Daily_Avg)
select *, (ChighMax_Daily_Avg - ClowMin_Daily_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 1 and deal_profit < 0 order by (ChighMax_Daily_Avg - ClowMin_Daily_Avg)
select *, (ChighMax_Daily_Avg - ClowMin_Daily_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit > 0 order by (ChighMax_Daily_Avg - ClowMin_Daily_Avg)
select *, (ChighMax_Daily_Avg - ClowMin_Daily_Avg) from #t_SignalsParamsIdentifyer where deal_direction = 2 and deal_profit < 0 order by (ChighMax_Daily_Avg - ClowMin_Daily_Avg)
*/






-- анализируем прибыльность/убыточность новостей
	If object_ID('tempdb..#t_SignalsCalendar') Is not Null drop table #t_SignalsCalendar
	
	/*
	select d.*, --c.* ,
			isnull(c.cName,'') as Calendar_cName, 
			isnull(c.cCountry,'') as Calendar_cCountry, 
			isnull(c.cVolatility,'') as Calendar_cVolatility,
			isnull(c.cdate,'') as Calendar_cdate, 
			isnull(c.ctime,'') as Calendar_ctime,
			isnull(c.TimeInMinutes,0) as Calendar_TimeInMinutes
	into #t_SignalsCalendar
	from #nt_st_deals d
	left outer join ntCalendarIdnData c on c.cdate = left(d.cdatetime,10)
		and c.cCountry in ('European Monetary Union','Germany','United States')
		and (c.cVolatility in ('2','3') or c.cName like '%speech%')
	order by d.cdatetime
*/


	select d.*, --c.* ,
			isnull(c.cName,'') as Calendar_cName, 
			isnull(c.cCountry,'') as Calendar_cCountry, 
			isnull(c.cVolatility,'') as Calendar_cVolatility,
			isnull(c.cdate,'') as Calendar_cdate, 
			isnull(c.ctime,'') as Calendar_ctime,
			isnull(c.TimeInMinutes,0) as Calendar_TimeInMinutes
	into #t_SignalsCalendar
	from #nt_st_deals d
	left outer join ntCalendarIdnData c on c.cdate = left(d.cdatetime,10)
--		and c.cCountry in ('European Monetary Union','Germany','United States')
		and (c.cVolatility in ('2','3') or c.cName like '%speech%')
	order by d.cdatetime

/*
	if @CurrencyIdCurrent = 1
		delete from #t_SignalsCalendar
		where Calendar_cCountry not in ('European Monetary Union','Germany','United States')
*/
	--if @CurrencyIdCurrent = 4
		delete from #t_SignalsCalendar
		where Calendar_cCountry not in ('European Monetary Union','Germany','United States','United Kingdom')


	-- select * from #t_SignalsCalendar where Calendar_cName = 'ECB Interest Rate Decision'

If object_ID('tempdb..#t_SignalsCalendar_Total') Is not Null drop table #t_SignalsCalendar_Total

select  Calendar_cName, Calendar_cCountry, Calendar_cVolatility,
		sum(case when deal_profit < 0 then deal_profit else 0 end) as sum_loss,
		sum(case when deal_profit > 0 then deal_profit else 0 end) as sum_profit,
		sum(deal_profit) as sum_loss_profit,
		convert(float,0) as prc_loss,
		-- -sum(case when deal_profit < 0 then deal_profit else 0 end)/sum(case when deal_profit > 0 then deal_profit else 0 end) as prc_loss,
		count(*) as cnt_deals,
		count(distinct Calendar_cdate) as cnt_dealDates
into #t_SignalsCalendar_Total
from #t_SignalsCalendar
group by Calendar_cName, Calendar_cCountry, Calendar_cVolatility
order by prc_loss

update #t_SignalsCalendar_Total
set prc_loss =  -sum_loss*1.0/(-sum_loss + sum_profit)
				--case when sum_profit = 0
				--then 0
				--else -sum_loss*1.0/sum_profit end

select * from #t_SignalsCalendar_Total order by prc_loss
select * from #t_SignalsCalendar_Total where Calendar_cVolatility = 3 order by prc_loss




-- select * from #nt_st_deals
-- select * from #t_SignalsCalendar where Calendar_cName like 'Initial Jobless Claims'
-- select * from #t_SignalsCalendar where Calendar_cdate = '2015.04.15'

--select * from #t_SignalsParamsIdentifyer where ParamsIdentifyer_signal in ('6E_45_60','6E_45_90','6E_45_30') order by cdatetime, ParamsIdentifyer_signal



-- select * from #t_SignalsCalendar_Total where Calendar_cCountry = 'European Monetary Union' order by prc_loss


-- select * from #nt_st_deals
-- select * from ntCalendarIdnData

-- select distinct idn_chart from #t_Signals order by idn_chart




-- insert into ntCalendarActive (CurrencyId, cName, cCountry, cVolatility, isActive)
select 4 as CurrencyId, cName, cCountry, cVolatility, isActive 
from ntCalendarActive
where CurrencyId = 1



/*
-- таблица для определения новостей, которые можно/нельзя использовать при торговле
select * from ntCalendarActive

insert into ntCalendarActive (CurrencyId, cName, cCountry, cVolatility, isActive)
select 1 as CurrencyId, 'ECB President Draghi_s Speech' as cName, 'European Monetary Union' as cCountry, 3 as cVolatility, 0 as isActive 


select 1 as CurrencyId, 'Fed Interest Rate Decision' as cName, 'United States' as cCountry, 3 as cVolatility, 0 as isActive union all 
select 1 as CurrencyId, 'Gross Domestic Product Annualized' as cName, 'United States' as cCountry, 3 as cVolatility, 0 as isActive union all 
select 1 as CurrencyId, 'ECB Monetary policy statement and press conference' as cName, 'European Monetary Union' as cCountry, 3 as cVolatility, 0 as isActive union all 
select 1 as CurrencyId, 'ECB Interest Rate Decision' as cName, 'European Monetary Union' as cCountry, 3 as cVolatility, 0 as isActive union all 
select 1 as CurrencyId, 'Gross Domestic Product Price Index' as cName, 'United States' as cCountry, 3 as cVolatility, 0 as isActive



*/




/*
If object_ID('tempdb..#t_cclosePosition') Is not Null drop table #t_cclosePosition

-- вычисляем copenPosition (положение цены открытия сделки в диапазоне дня на момент открытия сделки)
select  d.idn, 
		min(cb.clow) as clowMin,
		max(cb.chigh) as chighMax
into #t_cclosePosition
from #nt_st_deals d
left outer join #nt_st_chart cb on 
		left(cb.cdatetime,10) = left(d.cdatetime,10)
	and cb.cdatetime <= d.cdatetime
group by d.idn
order by d.idn


select 
	  (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin) as copenPosition, (d.deal_copen - cp.clowMin) as clowMin_delta, (cp.chighMax - d.deal_copen) as chighMax_delta, d.*	  
from #nt_st_deals d
left outer join #t_cclosePosition cp on cp.idn = d.idn
where deal_direction = 1
	and deal_profit > 0
order by (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin)
--order by (d.deal_copen - cp.clowMin)
--order by (cp.chighMax - d.deal_copen)

select 
	  (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin) as copenPosition, (d.deal_copen - cp.clowMin) as clowMin_delta, (cp.chighMax - d.deal_copen) as chighMax_delta, d.*	  
from #nt_st_deals d
left outer join #t_cclosePosition cp on cp.idn = d.idn
where deal_direction = 1
	and deal_profit < 0
order by (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin)

select 
	  (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin) as copenPosition, (d.deal_copen - cp.clowMin) as clowMin_delta, (cp.chighMax - d.deal_copen) as chighMax_delta, d.*	  
from #nt_st_deals d
left outer join #t_cclosePosition cp on cp.idn = d.idn
where deal_direction = 2
	and deal_profit > 0
order by (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin)

select 
	  (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin) as copenPosition, (d.deal_copen - cp.clowMin) as clowMin_delta, (cp.chighMax - d.deal_copen) as chighMax_delta, d.*	  
from #nt_st_deals d
left outer join #t_cclosePosition cp on cp.idn = d.idn
where deal_direction = 2
	and deal_profit < 0
order by (d.deal_copen - cp.clowMin)*1.0/(cp.chighMax - cp.clowMin)




select *, ABMmPosition0 + ABMmPosition1 from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by (ABMmPosition0 + ABMmPosition1)
select *, ABMmPosition0 + ABMmPosition1 from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by (ABMmPosition0 + ABMmPosition1)
select *, ABMmPosition0 + ABMmPosition1 from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by (ABMmPosition0 + ABMmPosition1)
select *, ABMmPosition0 + ABMmPosition1 from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by (ABMmPosition0 + ABMmPosition1)

select *, ABMmPosition0 + ABMmPosition1 from #nt_st_deals where deal_direction = 2 and deal_profit > 0 and (ABMmPosition0 + ABMmPosition1) < -200 order by cdatetime


select * from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by ABMmPosition1
select * from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by ABMmPosition1
select * from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by ABMmPosition1
select * from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by ABMmPosition1

select * from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by TimeInMinutes_deal_copen
select * from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by TimeInMinutes_deal_copen
select * from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by TimeInMinutes_deal_copen
select * from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by TimeInMinutes_deal_copen

select * from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by cdatetime
select * from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by cdatetime
select * from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by cdatetime
select * from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by cdatetime
*/


/*
select * from #t_SignalsParamsIdentifyer order by prc_loss
select * from #nt_st_deals
select * from #nt_st_chart


select * 
from #nt_st_deals d
left outer join #nt_st_chart cmin on 
		left(cmin.cdatetime,10) = left(d.cdatetime,10)
	and cmin.cdatetime <= d.cdatetime
	and cmin.clow = (select min(clow) from #nt_st_chart where left(cdatetime,10) = left(d.cdatetime,10) and cdatetime <= d.cdatetime)

select * from #nt_st_chart

*/


/*
-- вычисляем cclosePreviousDayPosition (положение цены открытия сделки относительно цены закрытия, chigh_max и clow_min предыдущего дня)


If object_ID('tempdb..#t_tradeDays') Is not Null drop table #t_tradeDays -- таблица с торговыми днями и их ценами закрытия

select  left(cdatetime,10) as cdate,
		max(cdatetime) as cdatetime_last, 
		convert(real,0) as cclose_last,
		max(chigh) as chigh_max,
		min(clow) as clow_min
into #t_tradeDays
from #nt_st_chart
group by left(cdatetime,10)
having count(*) >= 30
order by left(cdatetime,10)

alter table #t_tradeDays add idn int identity(1,1)

update d
set d.cclose_last = c.cclose
from #t_tradeDays d
left outer join #nt_st_chart c on c.cdatetime = d.cdatetime_last






update d
set d.cclose_PreviousDay1 = isnull(td1.cclose_last,d.deal_copen),
	d.cclose_PreviousDay2 = isnull(td2.cclose_last,d.deal_copen),
	d.chigh_PreviousDay1 = isnull(td1.chigh_max,d.deal_copen),
	d.clow_PreviousDay1 = isnull(td1.clow_min,d.deal_copen)
from #nt_st_deals d
left outer join #t_tradeDays td on td.cdate = left(d.cdatetime,10)
left outer join #t_tradeDays td1 on td1.idn = td.idn - 1 -- предыдущий торговый день
left outer join #t_tradeDays td2 on td2.idn = td.idn - 2 -- пред-предыдущий торговый день

select *, (deal_copen - cclose_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by ((deal_copen - cclose_PreviousDay1) * deal_volume)
select *, (deal_copen - cclose_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by ((deal_copen - cclose_PreviousDay1) * deal_volume)
select *, (deal_copen - cclose_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by ((deal_copen - cclose_PreviousDay1) * deal_volume)
select *, (deal_copen - cclose_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by ((deal_copen - cclose_PreviousDay1) * deal_volume)

select *, (deal_copen - cclose_PreviousDay2) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by ((deal_copen - cclose_PreviousDay2) * deal_volume)
select *, (deal_copen - cclose_PreviousDay2) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by ((deal_copen - cclose_PreviousDay2) * deal_volume)
select *, (deal_copen - cclose_PreviousDay2) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by ((deal_copen - cclose_PreviousDay2) * deal_volume)
select *, (deal_copen - cclose_PreviousDay2) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by ((deal_copen - cclose_PreviousDay2) * deal_volume)

select *, (deal_copen - chigh_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by ((deal_copen - chigh_PreviousDay1) * deal_volume)
select *, (deal_copen - chigh_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by ((deal_copen - chigh_PreviousDay1) * deal_volume)
select *, (deal_copen - chigh_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by ((deal_copen - chigh_PreviousDay1) * deal_volume)
select *, (deal_copen - chigh_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by ((deal_copen - chigh_PreviousDay1) * deal_volume)

select *, (deal_copen - clow_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by ((deal_copen - clow_PreviousDay1) * deal_volume)
select *, (deal_copen - clow_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by ((deal_copen - clow_PreviousDay1) * deal_volume)
select *, (deal_copen - clow_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by ((deal_copen - clow_PreviousDay1) * deal_volume)
select *, (deal_copen - clow_PreviousDay1) * deal_volume from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by ((deal_copen - clow_PreviousDay1) * deal_volume)





-- select * from #nt_st_chart
-- select * from #nt_st_deals



*/



/*
-- анализируем показатели по другим ParamsIdentifyer

If object_ID('tempdb..#ntAverageValuesResults2') Is not Null drop table #ntAverageValuesResults2

	select r.* --, space(20) as ParamsIdentifyer
	into #ntAverageValuesResults2
	from ntAverageValuesResults	r with (nolock)
	where   r.ParamsIdentifyer in ('6E_30_120')
	
--	select * from #ntAverageValuesResults2 order by cdatetime_last

	select d.*, r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt
	from #nt_st_deals d
	left outer join #ntAverageValuesResults2 r2 on r2.cdatetime_last = d.cdatetime
	where r2.cdatetime_last is not null
		and d.deal_direction = 1 and d.deal_profit > 0
	order by  (r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt)

	select d.*, r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt
	from #nt_st_deals d
	left outer join #ntAverageValuesResults2 r2 on r2.cdatetime_last = d.cdatetime
	where r2.cdatetime_last is not null
		and d.deal_direction = 1 and d.deal_profit < 0
	order by  (r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt)

	select d.*, r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt
	from #nt_st_deals d
	left outer join #ntAverageValuesResults2 r2 on r2.cdatetime_last = d.cdatetime
	where r2.cdatetime_last is not null
		and d.deal_direction = 2 and d.deal_profit > 0
	order by  (r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt)

	select d.*, r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt
	from #nt_st_deals d
	left outer join #ntAverageValuesResults2 r2 on r2.cdatetime_last = d.cdatetime
	where r2.cdatetime_last is not null
		and d.deal_direction = 2 and d.deal_profit < 0
	order by  (r2.TakeProfit_isOk_AtOnce_up_AvgCnt-r2.TakeProfit_isOk_AtOnce_down_AvgCnt)

*/




-- анализируем прибыльность сделок в зависимости от дневного диапазона ABV на момент заключения сделки

	If object_ID('tempdb..#t_ABV') Is not Null drop table #t_ABV

		
	select d.cdatetime, c.ABV as ABV_dealOpen, min(cd.ABV) as ABV_currDay_min, max(cd.ABV) as ABV_currDay_max
	into #t_ABV
	from #nt_st_deals d
	left outer join #nt_st_chart c on c.cdatetime = d.cdatetime
	left outer join #nt_st_chart cd on left(cd.cdatetime,10) = left(d.cdatetime,10)
		and cd.cdatetime <= d.cdatetime
	group by d.cdatetime, c.ABV
	
	update d
	set d.ABV_currDay_min = t.ABV_currDay_min,
		d.ABV_currDay_max = t.ABV_currDay_max,
		d.ABV_dealOpen = t.ABV_dealOpen
	from #nt_st_deals d
	left outer join #t_ABV t on t.cdatetime = d.cdatetime
	
	
	
	
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by ABV_currDay_max - ABV_currDay_min
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by ABV_currDay_max - ABV_currDay_min
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by ABV_currDay_max - ABV_currDay_min
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by ABV_currDay_max - ABV_currDay_min
	
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min)
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min)
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min)
	select ABV_currDay_max - ABV_currDay_min, (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min), * from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by (ABV_dealOpen - ABV_currDay_min)/(ABV_currDay_max - ABV_currDay_min)
	
	
	



----------------------
-- анализируем вход на откате
/*

select d.idn_chart, d.idn_chart_deal_cclose, 
	-((select min(clow) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen) * 10000 as clow_min,
	d.*
from #nt_st_deals d
where d.deal_direction = 1
	and d.deal_profit > 0
order by -((select min(clow) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen)

select d.idn_chart, d.idn_chart_deal_cclose, 
	-((select min(clow) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen) * 10000 as clow_min,
	d.*
from #nt_st_deals d
where d.deal_direction = 1
	and d.deal_profit < 0
order by -((select min(clow) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen)



select d.idn_chart, d.idn_chart_deal_cclose, 
	((select max(chigh) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen) * 10000 as chigh_min,
	d.*
from #nt_st_deals d
where d.deal_direction = 2
	and d.deal_profit > 0
order by ((select max(chigh) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen)

select d.idn_chart, d.idn_chart_deal_cclose, 
	((select max(chigh) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen) * 10000 as chigh_min,
	d.*
from #nt_st_deals d
where d.deal_direction = 2
	and d.deal_profit < 0
order by ((select max(chigh) from #nt_st_chart where idn > d.idn_chart and idn <= d.idn_chart_deal_cclose) - d.deal_copen)

*/
----------------------



-- анализируем прибыльность сделок в зависимости от трендовости цены


-- select * from #nt_st_deals
-- select * from #nt_st_chart

If object_ID('tempdb..#t_Sumdelta') Is not Null drop table #t_Sumdelta

select d.idn, d.cdatetime, --case when c1.cclose < c2.cclose 
	sum(abs(c1.cclose - c2.cclose)) as SumABSdelta,
	sum((c1.cclose - c2.cclose)) as Sumdelta
into #t_Sumdelta
from #nt_st_deals d
left outer join #nt_st_chart c1 on 
		left(c1.cdatetime,10) = left(d.cdatetime,10) 
	and c1.cdatetime <= d.cdatetime
	and right(c1.cdatetime,5) >= '09:00'
left outer join #nt_st_chart c2 on c2.idn = c1.idn-1
--where d.cdatetime = '2015.01.05 17:35'
group by d.idn, d.cdatetime

-- select *, (Sumdelta / SumABSdelta) from #t_Sumdelta order by (Sumdelta / SumABSdelta)


select (t.Sumdelta / t.SumABSdelta), *
from #nt_st_deals d
left outer join #t_Sumdelta t on t.idn = d.idn
where d.deal_direction = 1 and d.deal_profit > 0
order by (t.Sumdelta / t.SumABSdelta)

select (t.Sumdelta / t.SumABSdelta), *
from #nt_st_deals d
left outer join #t_Sumdelta t on t.idn = d.idn
where d.deal_direction = 1 and d.deal_profit < 0
order by (t.Sumdelta / t.SumABSdelta)

select (t.Sumdelta / t.SumABSdelta), *
from #nt_st_deals d
left outer join #t_Sumdelta t on t.idn = d.idn
where d.deal_direction = 2 and d.deal_profit > 0
order by (t.Sumdelta / t.SumABSdelta)

select (t.Sumdelta / t.SumABSdelta), *
from #nt_st_deals d
left outer join #t_Sumdelta t on t.idn = d.idn
where d.deal_direction = 2 and d.deal_profit < 0
order by (t.Sumdelta / t.SumABSdelta)

	
----------------------------------

-- анализируем прибыльность сделок в зависимости от К между ABV, ABVMini и ценой

DECLARE @cdatetime varchar(16), @resultCorr float
If object_ID('tempdb..#t_Corr') Is not Null drop table #t_Corr
create table #t_Corr (idn int identity(1,1), X FLOAT, Y FLOAT)

-- select * from #nt_st_chart

DECLARE cDeals CURSOR FOR
SELECT cdatetime
FROM #nt_st_deals
order by cdatetime

OPEN cDeals

FETCH NEXT FROM cDeals 
INTO @cdatetime
WHILE @@FETCH_STATUS = 0
BEGIN

	-- 1. считаем К(ABV, ABVMini)
	truncate table #t_Corr
	
	insert into #t_Corr (X, Y)
	select ABV, ABVMini 
	-- cclose	ABV	ABVMini
	from #nt_st_chart
	where left(cdatetime,10) = left(@cdatetime,10)
		and cdatetime <= @cdatetime
		--and idn >= (select idn-36 from #nt_st_chart where cdatetime = @cdatetime) -- данные только за 3 часа до сделки
	order by cdatetime
	
	-- считаем МА
	update t1
	set t1.X = (select avg(X) from #t_Corr where idn >= (t1.idn-4) and idn <= t1.idn)
	from #t_Corr t1

	update t1
	set t1.Y = (select avg(Y) from #t_Corr where idn >= (t1.idn-4) and idn <= t1.idn)
	from #t_Corr t1

	
	exec ntp_calcCorr @resultCorr output
	
	update #nt_st_deals set K_ABV_ABVMini = @resultCorr where cdatetime = @cdatetime


	-- 2. считаем К(cclose, ABV)
	truncate table #t_Corr
	
	insert into #t_Corr (X, Y)
	select cclose, ABV
	from #nt_st_chart
	where left(cdatetime,10) = left(@cdatetime,10)
		and cdatetime <= @cdatetime
		--and idn >= (select idn-36 from #nt_st_chart where cdatetime = @cdatetime) -- данные только за 3 часа до сделки
	order by cdatetime
	
	-- считаем МА
	update t1
	set t1.Y = (select avg(Y) from #t_Corr where idn >= (t1.idn-4) and idn <= t1.idn)
	from #t_Corr t1
	
	exec ntp_calcCorr @resultCorr output
	
	update #nt_st_deals set K_cclose_ABV = @resultCorr where cdatetime = @cdatetime



	-- 3. считаем К(cclose, ABVMini)
	truncate table #t_Corr
	
	insert into #t_Corr (X, Y)
	select cclose, ABVMini
	from #nt_st_chart
	where left(cdatetime,10) = left(@cdatetime,10)
		and cdatetime <= @cdatetime
		--and idn >= (select idn-36 from #nt_st_chart where cdatetime = @cdatetime) -- данные только за 3 часа до сделки
	order by cdatetime
	
	-- считаем МА
	update t1
	set t1.Y = (select avg(Y) from #t_Corr where idn >= (t1.idn-4) and idn <= t1.idn)
	from #t_Corr t1
	
	exec ntp_calcCorr @resultCorr output
	
	update #nt_st_deals set K_cclose_ABVMini = @resultCorr where cdatetime = @cdatetime
	
    FETCH NEXT FROM cDeals 
    INTO @cdatetime
END 

exit_cursor:
CLOSE cDeals;
DEALLOCATE cDeals;

-- теперь в таблице #nt_st_deals в столбцах (K_ABV_ABVMini, K_cclose_ABV, K_cclose_ABVMini) содержатся рассчиканные К

-- количество прибыльных/убыточных сделок в зависимости от К
select K_ABV_ABVMini from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by K_ABV_ABVMini
select K_ABV_ABVMini from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by K_ABV_ABVMini
select K_ABV_ABVMini from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by K_ABV_ABVMini
select K_ABV_ABVMini from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by K_ABV_ABVMini

select K_cclose_ABV from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by K_cclose_ABV
select K_cclose_ABV from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by K_cclose_ABV
select K_cclose_ABV from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by K_cclose_ABV
select K_cclose_ABV from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by K_cclose_ABV

select K_cclose_ABVMini from #nt_st_deals where deal_direction = 1 and deal_profit > 0 order by K_cclose_ABVMini
select K_cclose_ABVMini from #nt_st_deals where deal_direction = 1 and deal_profit < 0 order by K_cclose_ABVMini
select K_cclose_ABVMini from #nt_st_deals where deal_direction = 2 and deal_profit > 0 order by K_cclose_ABVMini
select K_cclose_ABVMini from #nt_st_deals where deal_direction = 2 and deal_profit < 0 order by K_cclose_ABVMini



-- считаем чистую прибыль в зависимости от К
If object_ID('tempdb..#t_scale') Is not Null drop table #t_scale
create table #t_scale (idn int identity(1,1), NumX FLOAT)

DECLARE @cnt FLOAT = -1;

-- заполняем таблицу со шкалой К
WHILE @cnt <= 1.01
BEGIN
   --select @cnt
   insert into #t_scale(NumX) select @cnt
   SET @cnt = @cnt + 0.01;
END;

-- выводим чистую прибыль в зависимости от К
select s.*, 
		(select isnull(sum(deal_profit),0) from #nt_st_deals where deal_direction = 1 and K_ABV_ABVMini <= s.NumX),
		(select isnull(sum(deal_profit),0) from #nt_st_deals where deal_direction = 2 and K_ABV_ABVMini <= s.NumX),
		(select isnull(sum(deal_profit),0) from #nt_st_deals where deal_direction = 1 and K_cclose_ABV <= s.NumX),
		(select isnull(sum(deal_profit),0) from #nt_st_deals where deal_direction = 2 and K_cclose_ABV <= s.NumX),
		(select isnull(sum(deal_profit),0) from #nt_st_deals where deal_direction = 1 and K_cclose_ABVMini <= s.NumX),
		(select isnull(sum(deal_profit),0) from #nt_st_deals where deal_direction = 2 and K_cclose_ABVMini <= s.NumX)
--		(select isnull(avg(K_cclose_ABV),0) from #nt_st_deals where deal_direction = 1 and K_ABV_ABVMini <= s.NumX and K_ABV_ABVMini >= (s.NumX-0.01)),
--		(select isnull(avg(K_cclose_ABV),0) from #nt_st_deals where deal_direction = 2 and K_ABV_ABVMini <= s.NumX and K_ABV_ABVMini >= (s.NumX-0.01))
from #t_scale s
order by s.idn

select *
from #nt_st_deals
where deal_direction = 2 and K_ABV_ABVMini >= -0.5 and K_ABV_ABVMini <= 0
order by cdatetime

----------------------------------








