


-- дл€ расчета  (BSV) делаем »« »—“ќ–»» файл с текущими данными по BSV (запустить запрос в Access)
select t1.*, t2.BSV, 0 as BSVMini
into NtImport_6E2_Minute_5_id1_fromHistory
from ntImport_6E_Minute_5_id1_access as t1
left outer join ntPeriodsDataCCLOSE_42_2_5_1_1 as t2 on t2.cdate = t1.cdate and t2.TimeInMinutes = left(t1.ctime,2)*60+ right(t1.ctime,2)
order by t1.cdatetime
update NtImport_6E2_Minute_5_id1_fromHistory set BSV = 0 where nz(BSV,0) = 0



select * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E2_15_120_PA211%'
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 14
select * from ntAverageValuesResults where CalcCorrParamsId = '3-1-1-1'
-- update ntAverageValuesResults set ParamsIdentifyer = ParamsIdentifyer + '_3-1-1-1' where CalcCorrParamsId = '3-1-1-1'

select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 5
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 7
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 8
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 14

--update ntSettingsPeriodsParameters_cn set WeightCORR = 2 where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 5
--update ntSettingsPeriodsParameters_cn set WeightCORR = 0 where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 7
--update ntSettingsPeriodsParameters_cn set WeightCORR = 0 where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 8
--update ntSettingsPeriodsParameters_cn set WeightCORR = 1 where ParamsIdentifyer like '6E2_%' and FieldNumCurrent = 14

select * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E2_%'
--update ntSettingsFilesParameters_cn set CalcCorrParamsId = '2-0-0-1' where ParamsIdentifyer like '6E2_%'



------------------------------
 select cdate_last, count(*) from ntAverageValuesResults where ParamsIdentifyer like '6E2_%_PA211%' group by cdate_last order by cdate_last
select count(*) from ntAverageValuesResults where ParamsIdentifyer like '6E2_%_PA211%'




-- переносим данные на другой сервер дл€ расчета ќѕ

-- 1. скопировать на расчетный сервер нужное кол-во файлов .mdb
--	  задать в mdb-файлах в процедуре ProcStart3 нужные даты

-- 2. перекинуть на расчетный сервер таблицы:
--	ntSettingsFilesParameters_cn
--	ntSettingsPeriodsParameters_cn
	select *
	-- delete
	from [SERVER1].forex.dbo.ntSettingsFilesParameters_cn

	insert into [SERVER1].forex.dbo.ntSettingsFilesParameters_cn (ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade, cntSourceFiles)
	select ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade, cntSourceFiles
	from ntSettingsFilesParameters_cn

	select *
	-- delete
	from [SERVER1].forex.dbo.ntSettingsPeriodsParameters_cn

	insert into [SERVER1].forex.dbo.ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit)
	select ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit
	from ntSettingsPeriodsParameters_cn
-----
	select *
	-- delete
	from [MSSQLMAX3].forex.dbo.ntSettingsFilesParameters_cn

	insert into [MSSQLMAX3].forex.dbo.ntSettingsFilesParameters_cn (ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade, cntSourceFiles)
	select ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade, cntSourceFiles
	from ntSettingsFilesParameters_cn

	select *
	-- delete
	from [MSSQLMAX3].forex.dbo.ntSettingsPeriodsParameters_cn

	insert into [MSSQLMAX3].forex.dbo.ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit)
	select ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit
	from ntSettingsPeriodsParameters_cn

-- 3. очистить на расчетном сервере талицы:

	-- truncate table [SERVER1].forex.dbo.ntAverageValuesResults
	select * from [SERVER1].forex.dbo.ntAverageValuesResults
	
	-- truncate table [MSSQLMAX3].forex.dbo.ntAverageValuesResults
	select * from [MSSQLMAX3].forex.dbo.ntAverageValuesResults
	
	
-- 4. сделать в NT файл с исходными данными за нужный период и перекинуть его на расчетный сервер
select datediff(dd,'01.01.2015','11.08.2016')

----

select top 100 * from ntAverageValuesResults order by idn desc
select top 100 * from [MSSQLMAX3].forex.dbo.ntAverageValuesResults order by idn desc
select count(*) from [MSSQLMAX3].forex.dbo.ntAverageValuesResults


----------------------


select * 
--into _nt_st_parameters_ParamsIdentifyersSets_copy1 
-- delete
from [SERVER1].forex.dbo.nt_st_parameters_ParamsIdentifyersSets

insert into [SERVER1].forex.dbo.nt_st_parameters_ParamsIdentifyersSets (ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active)
select ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active
from nt_st_parameters_ParamsIdentifyersSets


select *
--into _nt_st_chart_copy1 
-- delete
from [SERVER1].forex.dbo.nt_st_chart

insert into [SERVER1].forex.dbo.nt_st_chart (cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer)
select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer
from nt_st_chart
order by cdatetime

----------------------












---------------------------------
-- готовим данные дл€ прогона теста стратегии




--------------------------------

-- переносим данные с расчетных серверов
select count(*) from [SERVER1].forex.dbo.ntAverageValuesResults
select count(*) from [MSSQLMAX3].forex.dbo.ntAverageValuesResults


-- insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer
from [SERVER1].forex.dbo.ntAverageValuesResults
order by cdatetime_last

-- insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, null as ParamsIdentifyer
from [MSSQLMAX3].forex.dbo.ntAverageValuesResults
order by cdatetime_last






-- 0. в таблице ntAverageValuesResults мен€ем расчетные ParamsIdentifyer на основной (убрать _v02, _v03, ...)
select distinct ParamsIdentifyer from ntAverageValuesResults (nolock) order by ParamsIdentifyer
select distinct ParamsIdentifyer from ntAverageValuesResults (nolock) where ParamsIdentifyer like '%_v%'
-- update ntAverageValuesResults set ParamsIdentifyer = '6E2_15_120_PA211' where ParamsIdentifyer like '%_v%'

select * from ntAverageValuesResults (nolock) order by cdatetime_last desc

--1. готовим таблицы дл€ расчета ќѕ

--если в таблицах 
--	ntSettingsFilesParameters_cn
--	ntSettingsPeriodsParameters_cn
--	nt_st_parameters_ParamsIdentifyersSets
--отсутствуют нужные ParamsIdentifyer, то добавл€ем их


select * from nt_st_parameters_ParamsIdentifyersSets
select replace(ParamsIdentifyer,'_PA211_cal','_PA211_d2'), * from nt_st_parameters_ParamsIdentifyersSets where ParamsIdentifyersSetId = 9

insert into nt_st_parameters_ParamsIdentifyersSets (ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active)
select 13 as ParamsIdentifyersSetId, replace(ParamsIdentifyer,'6E_','6E2_') as ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active
from nt_st_parameters_ParamsIdentifyersSets where ParamsIdentifyersSetId = 8


6E_15_120_PA211_d2
6E_15_30_PA211_d2
6E_15_60_PA211_d2
6E_15_90_PA211_d2
6E_30_120_PA211_d2
6E_30_30_PA211_d2
6E_30_60_PA211_d2
6E_30_90_PA211_d2
6E_45_120_PA211_d2
6E_45_30_PA211_d2
6E_45_60_PA211_d2
6E_45_90_PA211_d2

---------------------------------
-- добавл€ем 211 range=0,7-1,5
insert into ntSettingsFilesParameters_cn (ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade)
select ThreadId, replace(ParamsIdentifyer,'_lp2040','_lp50100') as dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, replace(ParamsIdentifyer,'_lp2040','_lp50100') as ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade
--select * 
from ntSettingsFilesParameters_cn where ParamsIdentifyer in (
'6B_15_120_PA211_lp2040',
'6B_15_120_PA211_v02_lp2040',
'6B_15_120_PA211_v03_lp2040',
'6B_15_30_PA211_lp2040',
'6B_15_60_PA211_lp2040',
'6B_15_90_PA211_lp2040',
'6B_30_120_PA211_lp2040',
'6B_30_30_PA211_lp2040',
'6B_30_60_PA211_lp2040',
'6B_30_90_PA211_lp2040',
'6B_45_120_PA211_lp2040',
'6B_45_30_PA211_lp2040',
'6B_45_60_PA211_lp2040',
'6B_45_90_PA211_lp2040'
)

select * from ntSettingsFilesParameters_cn where ParamsIdentifyer in ('6B_15_120_PA211_lp2040','6B_15_120_PA211_v02_lp2040','6B_15_120_PA211_v03_lp2040','6B_15_30_PA211_lp2040','6B_15_60_PA211_lp2040','6B_15_90_PA211_lp2040','6B_30_120_PA211_lp2040','6B_30_30_PA211_lp2040','6B_30_60_PA211_lp2040','6B_30_90_PA211_lp2040','6B_45_120_PA211_lp2040','6B_45_30_PA211_lp2040','6B_45_60_PA211_lp2040','6B_45_90_PA211_lp2040')
-- select * from ntSettingsFilesParameters_cn
-- update ntSettingsFilesParameters_cn set 
	StopLoss = 20, 
	StopLoss_last = case when StopLoss_last is null then null else 20 end, 
	TakeProfit = 40, 
	TakeProfit_last = case when TakeProfit_last is null then null else 40 end
where ParamsIdentifyer in ('6B_15_120_PA211_lp2040','6B_15_120_PA211_v02_lp2040','6B_15_120_PA211_v03_lp2040','6B_15_30_PA211_lp2040','6B_15_60_PA211_lp2040','6B_15_90_PA211_lp2040','6B_30_120_PA211_lp2040','6B_30_30_PA211_lp2040','6B_30_60_PA211_lp2040','6B_30_90_PA211_lp2040','6B_45_120_PA211_lp2040','6B_45_30_PA211_lp2040','6B_45_60_PA211_lp2040','6B_45_90_PA211_lp2040')
update ntSettingsFilesParameters_cn set ParamsIdentifyer = replace(ParamsIdentifyer,'_lp2040','_lp2040')
where ParamsIdentifyer in ('6B_15_120_PA211_lp2040','6B_15_120_PA211_v02_lp2040','6B_15_120_PA211_v03_lp2040','6B_15_30_PA211_lp2040','6B_15_60_PA211_lp2040','6B_15_90_PA211_lp2040','6B_30_120_PA211_lp2040','6B_30_30_PA211_lp2040','6B_30_60_PA211_lp2040','6B_30_90_PA211_lp2040','6B_45_120_PA211_lp2040','6B_45_30_PA211_lp2040','6B_45_60_PA211_lp2040','6B_45_90_PA211_lp2040')

select * from ntSettingsFilesParameters_cn 
-- update ntSettingsFilesParameters_cn set 	StopLoss = 20, 	StopLoss_last = case when StopLoss_last is null then null else 20 end, 	TakeProfit = 50, 	TakeProfit_last = case when TakeProfit_last is null then null else 50 end
where ParamsIdentifyer in ('6B_15_120_PA211','6B_15_120_PA211_v02','6B_15_120_PA211_v03','6B_15_30_PA211','6B_15_60_PA211','6B_15_90_PA211','6B_30_120_PA211','6B_30_30_PA211','6B_30_60_PA211','6B_30_90_PA211','6B_45_120_PA211','6B_45_30_PA211','6B_45_60_PA211','6B_45_90_PA211')


insert into ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit)
select ParamsIdentifyer + '_lp2040' as ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, 
	--(case when FieldNumCurrent = 5 then 2 when FieldNumCurrent = 7 then 1 when FieldNumCurrent = 8 then 1 else 1 end) as 
	WeightCORR, 
	MAPeriod, 	
	--(case when FieldNumCurrent = 5 then 1.5 when FieldNumCurrent = 7 then DeltaCcloseRangeMaxLimit when FieldNumCurrent = 8 then DeltaCcloseRangeMaxLimit else 1 end) as 
	DeltaCcloseRangeMaxLimit, 
	--(case when FieldNumCurrent = 5 then 0.7 when FieldNumCurrent = 7 then DeltaCcloseRangeMinLimit when FieldNumCurrent = 8 then DeltaCcloseRangeMinLimit else 1 end) as 
	DeltaCcloseRangeMinLimit, 
	IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit
-- delete
from ntSettingsPeriodsParameters_cn where ParamsIdentifyer in (
'6B_15_120_PA211',
'6B_15_120_PA211_v02',
'6B_15_120_PA211_v03',
'6B_15_30_PA211',
'6B_15_60_PA211',
'6B_15_90_PA211',
'6B_30_120_PA211',
'6B_30_30_PA211',
'6B_30_60_PA211',
'6B_30_90_PA211',
'6B_45_120_PA211',
'6B_45_30_PA211',
'6B_45_60_PA211',
'6B_45_90_PA211'
)
update ntSettingsPeriodsParameters_cn set ParamsIdentifyer = replace(ParamsIdentifyer,'_lp2040','_lp2040')
where ParamsIdentifyer in ('6B_15_120_PA211_lp2040','6B_15_120_PA211_v02_lp2040','6B_15_120_PA211_v03_lp2040','6B_15_30_PA211_lp2040','6B_15_60_PA211_lp2040','6B_15_90_PA211_lp2040','6B_30_120_PA211_lp2040','6B_30_30_PA211_lp2040','6B_30_60_PA211_lp2040','6B_30_90_PA211_lp2040','6B_45_120_PA211_lp2040','6B_45_30_PA211_lp2040','6B_45_60_PA211_lp2040','6B_45_90_PA211_lp2040')


select distinct ParamsIdentifyer from nt_rt_parameters_ParamsIdentifyersSets where is_active = 1

select * from nt_st_parameters_ParamsIdentifyersSets
where ParamsIdentifyer in ('6E_15_120_PA211','6E_15_30_PA211','6E_30_120_PA211','6E_30_30_PA211','6E_15_60_PA211','6E_15_90_PA211','6E_30_60_PA211','6E_30_90_PA211','6E_45_30_PA211','6E_45_60_PA211','6E_45_90_PA211','6E_45_120_PA211','6E_15_120_PA211_v02','6E_15_120_PA211_v03')


insert into nt_st_parameters_ParamsIdentifyersSets (ParamsIdentifyersSetId, ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active)
--select 6 as ParamsIdentifyersSetId, replace(ParamsIdentifyer,'_PA211','_PA211_r') as ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, 0 as is_active
select 11 as ParamsIdentifyersSetId, ParamsIdentifyer + '_lp2040' as ParamsIdentifyer, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, is_active
-- select * 
from nt_st_parameters_ParamsIdentifyersSets 
where --ParamsIdentifyersSetId = 3
ParamsIdentifyer in (
'6B_15_120_PA211',
'6B_15_120_PA211_v02',
'6B_15_120_PA211_v03',
'6B_15_30_PA211',
'6B_15_60_PA211',
'6B_15_90_PA211',
'6B_30_120_PA211',
'6B_30_30_PA211',
'6B_30_60_PA211',
'6B_30_90_PA211',
'6B_45_120_PA211',
'6B_45_30_PA211',
'6B_45_60_PA211',
'6B_45_90_PA211'
)
update nt_st_parameters_ParamsIdentifyersSets set ParamsIdentifyer = replace(ParamsIdentifyer,'_lp2040','_lp2040')
where ParamsIdentifyer in ('6B_15_120_PA211_lp2040','6B_15_120_PA211_v02_lp2040','6B_15_120_PA211_v03_lp2040','6B_15_30_PA211_lp2040','6B_15_60_PA211_lp2040','6B_15_90_PA211_lp2040','6B_30_120_PA211_lp2040','6B_30_30_PA211_lp2040','6B_30_60_PA211_lp2040','6B_30_90_PA211_lp2040','6B_45_120_PA211_lp2040','6B_45_30_PA211_lp2040','6B_45_60_PA211_lp2040','6B_45_90_PA211_lp2040')


update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyer in ('6E_15_120_PA211_cal','6E_15_30_PA211_cal','6E_30_120_PA211_cal','6E_30_60_PA211_cal','6E_45_120_PA211_cal','6E_45_90_PA211_cal')
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyer in ('6B_15_120_PA211_cal','6B_15_30_PA211_cal','6B_30_120_PA211_cal','6B_30_60_PA211_cal','6B_45_120_PA211_cal','6B_45_90_PA211_cal')
update nt_st_parameters_ParamsIdentifyersSets set is_active = 0 where ParamsIdentifyersSetId = 10
update nt_st_parameters_ParamsIdentifyersSets set is_active = 1 where ParamsIdentifyersSetId = 11

as 
------------------------------

-- мен€ем параметры расчета  
select *
-- update ntSettingsPeriodsParameters_cn set DeltaCcloseRangeMaxLimit = 2, DeltaCcloseRangeMinLimit = 0.5
-- update ntSettingsPeriodsParameters_cn set DeltaCcloseRangeMaxLimit = null, DeltaCcloseRangeMinLimit = null
from ntSettingsPeriodsParameters_cn 
where 1=1
	and ParamsIdentifyer like '%_r%'
	and FieldNumCurrent in (7,8)

------------------------------




-- если нужно делать расчет на другом сервере - то копируем на него таблицы ntSettingsFilesParameters_cn и ntSettingsPeriodsParameters_cn

update ntSettingsFilesParameters_cn set is_makeDeals_RealTrade = 0 where is_makeDeals_RealTrade is null

select 	* from [MSSQLMAX2].forex.dbo.ntSettingsFilesParameters_cn with (nolock) order by idn desc
select 	* from [MSSQLMAX2].forex.dbo.ntSettingsPeriodsParameters_cn with (nolock) order by idn desc
-- delete from [MSSQLMAX2].forex.dbo.ntSettingsFilesParameters_cn 
-- delete from [MSSQLMAX2].forex.dbo.ntSettingsPeriodsParameters_cn 


select 	* from ntSettingsFilesParameters_cn with (nolock) order by idn desc
select 	* from ntSettingsPeriodsParameters_cn with (nolock) order by idn desc



insert into [MSSQLMAX2].forex.dbo.ntSettingsFilesParameters_cn (ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade)
select ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade
from ntSettingsFilesParameters_cn

insert into [MSSQLMAX2].forex.dbo.ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit)
select ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit 
from ntSettingsPeriodsParameters_cn

select dateadd(dd,11,'24.04.2015')



select * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6B%'

61	2	6B_5_v01_PA2		2	4	4	5	0	6B_5_v01_PA2					02:10	23:55	10:30	15	30	15	120	30	-90	10	10	1	20	20	1	1	1	1	0	0	1	0	0	1	1	1	1	2-1-1	30	30	1	NULL	NULL	0,0001	0,298	0,498	8	30	100	0	Consumer Price Index*	United States*	1	0	0	0	0	20	1000	1400	5000	0	0	4	1	0	0	C:\Users\user1\Documents\NinjaTrader 7\	00:01	0
163	11	forexAcc_calc2.mdb	2	4	4	5	0	6B_15_120_PA211_v02	2016.06.20	02:10	23:55	10:30	15	45	15	120	30	-30	10	10	1	20	20	1	1	1	1	0	0	1	0	0	1	1	1	1	2-1-1	30	30	1	NULL	NULL	0,0001	0,298	0,498	8	30	100	0	Consumer Price Index*	United States*	1	0	0	0	0	20	1000	1400	5000	0	0	4	1	0	0	C:\Users\user1\Documents\NinjaTrader 7\	00:01	0




-- 2. в таблице ntSettingsFilesParameters_cn задаем ParamsIdentifyer-ы, по которым надо будет делать расчет ќѕ

select * from ntSettingsFilesParameters_cn order by dbFileName
select t.CalcCorrParamsId, * from ntSettingsFilesParameters_cn t where CurrencyId_current = 1 order by t.CalcCorrParamsId, ParamsIdentifyer

-- обнул€ем dbFileName
update ntSettingsFilesParameters_cn set dbFileName = ParamsIdentifyer + '.mdb'

-- задаем ParamsIdentifyer-ы, по которым надо будет делать расчет ќѕ (брать ParamsIdentifyer, у которых заданы диапазоны параметров)
update ntSettingsFilesParameters_cn set dbFileName = 'forexAcc_calc1.mdb' where ParamsIdentifyer = '6E_15_120_PA211'
update ntSettingsFilesParameters_cn set dbFileName = 'forexAcc_calc2.mdb' where ParamsIdentifyer = '6B_15_120_PA211_v02'
update ntSettingsFilesParameters_cn set dbFileName = 'forexAcc_calc3.mdb' where ParamsIdentifyer = '6B_15_120_PA211_v03'


-- 3. определ€ем даты расчета
-- 3.1. (не об€зательно) проставл€ем поле ntAverageValuesResults.ParamsIdentifyer (см. запрос MSSQL12.2_strategy_tester_RunTestAllDays.sql)
-- 3.2. вычисл€ем даты, на которые ќѕ по нужным ParamsIdentifyer уже рассчитаны

select CalcCorrParamsId, cdate_last, count(*)
from ntAverageValuesResults (nolock) 
where CurrencyId_current = 4
	and CalcCorrParamsId = '2-1-1'
group by CalcCorrParamsId, cdate_last
order by CalcCorrParamsId, cdate_last



-- 4. создаем файл с текущими данными (C:\Users\user1\Documents\NinjaTrader 7\ntImport_6E_Minute_5_RealTime.txt)

-- 5. в access запускаем макрос ProcStart3 (предварительно задать первую дату расчета и количество дней расчета)
-- предварительно можно очистить таблицу ntImportCurrent_NoAverageValues
select * from ntImportCurrent_NoAverageValues (nolock) order by idn desc -- общие показатели, которые нужно рассчитать
-- delete from ntImportCurrent_NoAverageValues

-- 6. анализ прибыльности стратегии - см. запрос MSSQL12.2_strategy_tester_RunTestAllDays.sql
-- результаты расчета на другом сервере
select * from [MSSQLMAX].forex.dbo.ntAverageValuesResults



-------------- select * into _ntAverageValuesResults_v1_max from [MSSQLMAX2].forex.dbo._ntAverageValuesResults_v1 with (nolock)
-------------- select * into _ntAverageValuesResults_v2_max from [MSSQLMAX2].forex.dbo._ntAverageValuesResults_v2 with (nolock)
-------------- select * into _ntAverageValuesResults_v3_max from [MSSQLMAX2].forex.dbo._ntAverageValuesResults_v03 with (nolock)
-------------- select * into _ntAverageValuesResults_v4_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v5_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v6_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v7_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v8_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v9_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v10_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)

-------------- select * into _ntAverageValuesResults_v11_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)

-------------- select * into _ntAverageValuesResults_v12_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)
-------------- select * into _ntAverageValuesResults_v13_max from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock)




select * from [MSSQLMAX2].forex.dbo.ntAverageValuesResults with (nolock) order by cdatetime_calc desc





select * from _ntAverageValuesResults_v12_max order by cdatetime_calc desc
select *
-- delete
from _ntAverageValuesResults_v9_max where idn <= 969071

select cdate_last, count(*)
from _ntAverageValuesResults_v9_max (nolock) 
group by cdate_last
order by cdate_last

select cdate_last, count(*)
from ntAverageValuesResults (nolock) 
where CalcCorrParamsId = '2-1-1'
group by cdate_last
order by cdate_last

select cdate_last, count(*)
from _ntAverageValuesResults_v10_max (nolock) 
--where CalcCorrParamsId = '2-1-1'
group by cdate_last
order by cdate_last

insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, null as ParamsIdentifyer
from _ntAverageValuesResults_v13_max
order by cdatetime_calc

select * from ntAverageValuesResults order by idn desc
delete from ntAverageValuesResults where ParamsIdentifyer is null

------------------















