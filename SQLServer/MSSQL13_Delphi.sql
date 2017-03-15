


select distinct ParamsIdentifyer
from ntSettingsFilesParameters_cn

select * 
from ntSettingsFilesParameters_cn 
order by ParamsIdentifyer
where ParamsIdentifyer = '1_5'


select * 
from ntSettingsFilesParameters_cn 
where dbFileName <> 'forexAcc_' + ParamsIdentifyer + '.mdb'
order by ParamsIdentifyer



select * 
from ntSettingsPeriodsParameters_cn 
order by ParamsIdentifyer


-- exec ntpPrepareDataForCalc '1_5',1
---------------------------------
alter PROCEDURE dpPrepareDataForCalc (
	@ParamsIdentifyer VARCHAR(50),
	@ThreadId int -- номер ветки расчета
	)
AS BEGIN 
-- процедура готовит данные дл€ расчета

SET NOCOUNT ON

	-- в таблице ntSettingsFilesParameters_cn дл€ нужного ParamsIdentifyer мен€ем название Ѕƒ Access (которую нужно запускать дл€ расчета)
	update ntSettingsFilesParameters_cn
	set dbFileName = 'forexAcc_' + ParamsIdentifyer + '.mdb'
	where dbFileName = 'forexAcc_calc' + convert(varchar,@ThreadId) + '.mdb'

	update ntSettingsFilesParameters_cn
	set dbFileName = 'forexAcc_calc' + convert(varchar,@ThreadId) + '.mdb'
	where ParamsIdentifyer = @ParamsIdentifyer

END



alter PROCEDURE dpSelectNtSettingsFilesParameters_cn
AS BEGIN 
-- процедура выводит данные из таблицы ntSettingsFilesParameters_cn на лист settings
SET NOCOUNT ON
	Select * --top 3 * 
	From ntSettingsFilesParameters_cn 
	order by 
		case when ThreadId=0 then 10000 else ThreadId end,
		CalcCorrParamsId,
		ParamsIdentifyer
END


alter PROCEDURE dpSelectNtSettingsPeriodsParameters_cn (
	@ParamsIdentifyer VARCHAR(50)
	)
AS BEGIN 
-- процедура выводит данные из таблицы ntSettingsPeriodsParameters_cn на лист settings
SET NOCOUNT ON
	Select * 
	From ntSettingsPeriodsParameters_cn
	where ParamsIdentifyer = @ParamsIdentifyer
	order by idn
END

exec dpSelectNtSettingsPeriodsParameters_cn '1_5'







alter PROCEDURE dpCopyNtSettingsFilesPeriodsParameters (
	@ParamsIdentifyerOld VARCHAR(50),
	@ParamsIdentifyerNew VARCHAR(50),
	@cTimeFirstNew VARCHAR(5)
	)
AS BEGIN 
-- процедура делает копию параметров расчета из старого ParamsIdentifyer в новый ParamsIdentifyer

-- @ParamsIdentifyerOld - ParamsIdentifyer, который копируем
-- @ParamsIdentifyerNew - новый ParamsIdentifyer (в который копируем)
-- @cTimeFirstNew - TimeFirst у нового ParamsIdentifyer (null = оставить старый)
	
SET NOCOUNT ON

	
	if (
		(select count(*) from ntSettingsFilesParameters_cn where ParamsIdentifyer=@ParamsIdentifyerNew)>0   -- если уже существует @ParamsIdentifyerNew, то ничего не делаем
	 or (select count(*) from ntSettingsPeriodsParameters_cn where ParamsIdentifyer=@ParamsIdentifyerNew)>0 -- если уже существует @ParamsIdentifyerNew, то ничего не делаем
	 or (select count(*) from ntSettingsFilesParameters_cn where ParamsIdentifyer=@ParamsIdentifyerOld)=0   -- если не существует @ParamsIdentifyerOld, то ничего не делаем
	 --or (select count(*) from ntSettingsPeriodsParameters_cn where ParamsIdentifyer=@ParamsIdentifyerOld)=0
	 
	 )
		GOTO exit_proc
	else
	begin
		--insert into ntSettingsFilesParameters_cn (dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cTimeLastCalc, cntCharts, StopLoss, TakeProfit, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, isCalcAverageValuesInPercents, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, CntBarsMinLimit, ThreadId, cntBarsCalcCorr)
		--select ('forexAcc_' + @ParamsIdentifyerNew + '.mdb') as dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, @ParamsIdentifyerNew, cDateCalc, isnull(@cTimeFirstNew,cTimeFirst) as cTimeFirst, cTimeLast, cTimeFirstCalc, cTimeLastCalc, cntCharts, StopLoss, TakeProfit, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, isCalcAverageValuesInPercents, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, CntBarsMinLimit, ThreadId, cntBarsCalcCorr
		insert into ntSettingsFilesParameters_cn (ThreadId, dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, ParamsIdentifyer, cDateCalc, cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade, cntSourceFiles)
		select ThreadId, ('forexAcc_' + @ParamsIdentifyerNew + '.mdb') as dbFileName, DataSourceId, CurrencyId_current, CurrencyId_history, PeriodMinutes, IsCalcCalendar, @ParamsIdentifyerNew, cDateCalc, isnull(@cTimeFirstNew,cTimeFirst) as cTimeFirst, cTimeLast, cTimeFirstCalc, cntCharts, cntCharts_last, cntCharts_step, DeltaMinutesCalcCorr, DeltaMinutesCalcCorr_last, DeltaMinutesCalcCorr_step, StopLoss, StopLoss_last, StopLoss_step, TakeProfit, TakeProfit_last, TakeProfit_step, isCalcAverageValuesInPercents, isCalcAverageValuesInPercents_last, isCalcAverageValuesInPercents_step, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMaxLimit_last, DeltaCcloseRangeMaxLimit_step, DeltaCcloseRangeMinLimit, DeltaCcloseRangeMinLimit_last, DeltaCcloseRangeMinLimit_step, IsCalcCorrOnlyForSameTime, IsCalcCorrOnlyForSameTime_last, IsCalcCorrOnlyForSameTime_step, CalcCorrParamsId, CntBarsMinLimit, CntBarsMinLimit_last, CntBarsMinLimit_step, cTimeLastCalc, cntBarsCalcCorr, OnePoint, TakeProfit_isOk_AtOnce_AvgCnt_delta_alert, TakeProfit_isOk_AtOnce_AvgCnt_limit_alert, CPoints_AtOnce_Avg_delta_alert, CPoints_AtOnce_Avg_limit_alert, cntDaysPreviousShowABV, isLogTables, strCalendarNewsName, strCalendarCountryName, PeriodMultiplicatorForCalendar, IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, pCountCharts, pbarsBefore, pbarsTotal, cntRowsCorr, IsInverse, SortBack, pExcelWindowState, isSendEmailOnAlert, isSendSmsOnAlert, isCountAverageValuesWithNextDay, SourceFilePath, ctime_CalcAverageValuesWithNextDay, is_makeDeals_RealTrade, cntSourceFiles
		from ntSettingsFilesParameters_cn
		where ParamsIdentifyer = @ParamsIdentifyerOld
		
		insert into ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn)
		select @ParamsIdentifyerNew, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn
		from ntSettingsPeriodsParameters_cn
		where ParamsIdentifyer = @ParamsIdentifyerOld		
	end

exit_proc:
END


		insert into ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn)
		select ParamsIdentifyer, PeriodMinutes, FieldNumCurrent+10, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn
		from ntSettingsPeriodsParameters_cn
		where ParamsIdentifyer = '6B_15_120_PA211_v03_lp2040'	

		--insert into ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn)
		select ParamsIdentifyer, PeriodMinutes, FieldNumCurrent+10, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn
		from ntSettingsPeriodsParameters_cn
		where ParamsIdentifyer = '6E_15_120_PA211_4d' and FieldNumCurrent = 5			
		
		
		
-----------------------------------------------
-- сделать перед запуском
select CalcCorrParamsId, * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E%d2%'
-- update ntSettingsFilesParameters_cn set CalcCorrParamsId = '2-1-1_d2-0.5' where ParamsIdentifyer like '6E%d2%'
select WeightCORR, WeightCORR*0.5, * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E%d2%' and cntDaysAgoFirst = 1
-- update ntSettingsPeriodsParameters_cn set WeightCORR = WeightCORR*0.5 where ParamsIdentifyer like '6E%d2%' and cntDaysAgoFirst = 1

select CalcCorrParamsId, * from ntSettingsFilesParameters_cn where dbFileName like 'forexAcc_calc3.mdb'



exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211','6E_15_120_PA211_4d',null


exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211','qsSi_15_120_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211','6E_15_120_PA211_cclose',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_cclose','6E_15_120_PA211_cclose_2d',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211','6E_15_120_PA211_MA5',null


exec dpCopyNtSettingsFilesPeriodsParameters '6E2_15_120_PA211_v03','6E2_15_120_PA211_v04',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E2_15_120_PA211_v03','6E2_15_120_PA211_v05',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E2_15_120_PA211_v03','6E2_15_120_PA211_v06',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E2_15_120_PA211_v03','6E2_15_120_PA211_v07',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E2_15_120_PA211_v03','6E2_15_120_PA211_v08',null

exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_v2','6E_15_120_v6',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_v2','6E_15_120_v7',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_v2','6E_15_120_v8',null


exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_d2_v03','6E_15_120_PA211_d2_v04',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_d2_v03','6E_15_120_PA211_d2_v05',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_d2_v03','6E_15_120_PA211_d2_v06',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_d2_v03','6E_15_120_PA211_d2_v07',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_d2_v03','6E_15_120_PA211_d2_v08',null


exec dpCopyNtSettingsFilesPeriodsParameters '6B_15_120_PA211_v03_lp1530','6B_15_120_PA211_v04_lp1530',null
exec dpCopyNtSettingsFilesPeriodsParameters '6B_15_120_PA211_v03_lp1530','6B_15_120_PA211_v05_lp1530',null
exec dpCopyNtSettingsFilesPeriodsParameters '6B_15_120_PA211_v03_lp1530','6B_15_120_PA211_v06_lp1530',null
exec dpCopyNtSettingsFilesPeriodsParameters '6B_15_120_PA211_v03_lp1530','6B_15_120_PA211_v07_lp1530',null
exec dpCopyNtSettingsFilesPeriodsParameters '6B_15_120_PA211_v03_lp1530','6B_15_120_PA211_v08_lp1530',null



select CalcCorrParamsId, * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E2%' --and  CalcCorrParamsId = '2-1-1'
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2%' and FieldNumCurrent = 5
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2%' and FieldNumCurrent <> 5
-- update ntSettingsFilesParameters_cn set CalcCorrParamsId = '3-1-1-1' where ParamsIdentifyer like '6E2%'
-- update ntSettingsPeriodsParameters_cn set WeightCORR = 3 where ParamsIdentifyer like '6E2%' and FieldNumCurrent = 5


select * from ntSettingsFilesParameters_cn
select * from ntSettingsPeriodsParameters_cn

select replace(ParamsIdentifyer,'_PA211','_PA211_d2'), * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E%' and  CalcCorrParamsId = '2-1-1'

exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211','6E_15_120_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30_PA211','6E_15_30_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_120_PA211','6E_30_120_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_30_PA211','6E_30_30_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_60_PA211','6E_15_60_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_90_PA211','6E_15_90_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_60_PA211','6E_30_60_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_90_PA211','6E_30_90_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_30_PA211','6E_45_30_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_60_PA211','6E_45_60_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_90_PA211','6E_45_90_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_120_PA211','6E_45_120_PA211_d2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_v02','6E_15_120_PA211_d2_v02',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_v03','6E_15_120_PA211_d2_v03',null


select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer = '6E_15_120_PA211_d2'

-- добавл€ем расчет за предыдущий день
-- insert into ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit)
select ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, 1 as cntDaysAgoFirst, cTimeFirst, 1 as cntDaysAgoLast, cTimeLast, cntBarsCalcCorr_cn, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit
from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E%_d2%'

-- мен€ем CalcCorrParamsId
select CalcCorrParamsId, * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E%_d2%'
update ntSettingsFilesParameters_cn set CalcCorrParamsId = CalcCorrParamsId + '_d2' where ParamsIdentifyer like '6E%_d2%'


update ntSettingsFilesParameters_cn set CurrencyId_current = 42, CurrencyId_history = 1 where ParamsIdentifyer like '6E%' and  CalcCorrParamsId = '2-1-1'
update ntSettingsFilesParameters_cn set CurrencyId_current = 1, CurrencyId_history = 1 where ParamsIdentifyer like '6E%' and  CalcCorrParamsId = '2-1-1'


		-- insert into ntSettingsPeriodsParameters_cn (ParamsIdentifyer, PeriodMinutes, FieldNumCurrent, FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn)
		select ParamsIdentifyer, PeriodMinutes, 14 as FieldNumCurrent, 7 as FieldNumHistory, idAlgorithmCalcCorr, cntDaysAgoFirst, cTimeFirst, cntDaysAgoLast, cTimeLast, WeightCORR, MAPeriod, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, IsCalcCclosePosition, vCclosePositionDelta, CntBarsMinLimit, cntBarsCalcCorr_cn
		from ntSettingsPeriodsParameters_cn
		where ParamsIdentifyer like '6E2%'	 and FieldNumCurrent = 8



select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '6E2%' and FieldNumCurrent = 8
update ntSettingsPeriodsParameters_cn set FieldNumCurrent = 14, FieldNumHistory = 7 where ParamsIdentifyer like '6E2%' and FieldNumCurrent = 8
update ntSettingsPeriodsParameters_cn set FieldNumCurrent = 8, FieldNumHistory = 3 where ParamsIdentifyer like '6E2%' and FieldNumCurrent = 14


select * from ntSettingsFilesParameters_cn where ParamsIdentifyer like '6E2%'
update ntSettingsFilesParameters_cn set CalcCorrParamsId = '2-1-1-1' where ParamsIdentifyer like '6E2%'



go
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211','6E2_15_120_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30_PA211','6E2_15_30_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_120_PA211','6E2_30_120_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_30_PA211','6E2_30_30_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_60_PA211','6E2_15_60_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_90_PA211','6E2_15_90_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_60_PA211','6E2_30_60_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_90_PA211','6E2_30_90_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_30_PA211','6E2_45_30_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_60_PA211','6E2_45_60_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_90_PA211','6E2_45_90_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_45_120_PA211','6E2_45_120_PA211',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_v02','6E2_15_120_PA211_v02',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120_PA211_v03','6E2_15_120_PA211_v03',null


exec dpCopyNtSettingsFilesPeriodsParameters '1_5','1_5_v04','02:15'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03','1_5_v05','02:20'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03','1_5_v06','02:30'


exec dpCopyNtSettingsFilesPeriodsParameters '1_5','6C_5_v01_PA2','02:10'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03','6C_5_v02_PA10','02:15'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v04','6C_5_v03_P2','02:20'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v05','6C_5_v04_P10','02:25'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v06','6C_5_v05_PA9','02:30'


exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v07_test','1_5_v07_PA2','02:35'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03','1_5_v08_PA10','02:40'

exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03','1_5_v09_PAB64','02:45'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v09_PAB64','1_5_v10_PAB100','02:50'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03','1_5_v11_PA10','02:45'
exec dpCopyNtSettingsFilesPeriodsParameters '1_5','1_5_v11_PA10','02:15'

exec dpCopyNtSettingsFilesPeriodsParameters '6C_5_v01_PA2','6C_5_v06_PA2','02:15'
exec dpCopyNtSettingsFilesPeriodsParameters '6C_5_v02_PA10','6C_5_v07_PA10','10:05'

exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v01_PA2','1_5_v21_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03_PA10','1_5_v22_PA10',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v11_PA2','1_5_v23_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v12_PA10','1_5_v24_PA10',null

exec dpCopyNtSettingsFilesPeriodsParameters '6C_5_v01_PA2','6C_5_v21_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6C_5_v02_PA10','6C_5_v22_PA10',null
exec dpCopyNtSettingsFilesPeriodsParameters '6C_5_v06_PA2','6C_5_v23_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6C_5_v07_PA10','6C_5_v24_PA10',null


exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v01_PA2','4_5_v01_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v03_PA10','4_5_v02_PA10',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v12_PA10','4_5_v03_PA10',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v11_PA2','4_5_v04_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v21_PA2','4_5_v21_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v22_PA10','4_5_v22_PA10',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v23_PA2','4_5_v23_PA2',null
exec dpCopyNtSettingsFilesPeriodsParameters '1_5_v24_PA10','4_5_v24_PA10',null


exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30','6E_15_60',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30','6E_15_90',null

exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_30','6E_30_60',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_30_30','6E_30_90',null

exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30','6E_45_30',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30','6E_45_60',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30','6E_45_90',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_30','6E_45_120',null

exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120','6E_15_120_v2',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120','6E_15_120_v3',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120','6E_15_120_v4',null
exec dpCopyNtSettingsFilesPeriodsParameters '6E_15_120','6E_15_120_v5',null





alter PROCEDURE dpSelectCurrencyIdByParamsIdentifyer (
	@ParamsIdentifyer VARCHAR(50)
	)
AS BEGIN 
SET NOCOUNT ON
		select fp.CurrencyId_current, isnull(c.NTName,c.CurrencyName) as CurrencyName_current,
			   isnull(fp.cTimeFirst,'') as cTimeFirst, 
			   isnull(fp.cntCharts,'') as cntCharts, 
			   isnull(fp.DeltaMinutesCalcCorr,'') as DeltaMinutesCalcCorr, 
			   isnull(fp.StopLoss,'') as StopLoss, 
			   isnull(fp.TakeProfit,'') as TakeProfit, 
			   isnull(fp.isCalcAverageValuesInPercents,'') as isCalcAverageValuesInPercents, 
			   isnull(fp.DeltaCcloseRangeMaxLimit,'') as DeltaCcloseRangeMaxLimit, 
			   isnull(fp.DeltaCcloseRangeMinLimit,'') as DeltaCcloseRangeMinLimit, 
			   isnull(fp.IsCalcCorrOnlyForSameTime,'') as IsCalcCorrOnlyForSameTime, 
			   isnull(fp.CalcCorrParamsId,'') as CalcCorrParamsId, 
			   isnull(fp.CntBarsMinLimit,'') as CntBarsMinLimit, 
			   isnull(fp.cntBarsCalcCorr,'') as cntBarsCalcCorr
			   --, fp.cntBarsCalcCorr
		from ntSettingsFilesParameters_cn fp
		left outer join ntcurrency c on c.idn = fp.CurrencyId_current
		where fp.ParamsIdentifyer = @ParamsIdentifyer
END

go
exec dpSelectCurrencyIdByParamsIdentifyer '6E_5_v01_PA2'








select * 
from ntcurrency

select * 
from ntSettingsFilesParameters_cn
where Threadid = 1
  and ParamsIdentifyer like '4%'


update ntSettingsFilesParameters_cn
set cDateCalc = '2016.06.03'


-- update ntSettingsFilesParameters_cn
-- set cTimeLast = '15:30', cTimeFirstCalc = '13:30'
-- set cTimeLast = '23:55', cTimeFirstCalc = '10:30'
set CurrencyId_current = 4, CurrencyId_history = 4, Threadid = 3
where Threadid = 1
  and ParamsIdentifyer like '4%'

select * from ntSettingsFilesParameters_cn
select * from ntSettingsPeriodsParameters_cn

select * from ntSettingsFilesParameters_cn where Threadid in (1)




select * from ntSettingsFilesParameters_cn where Threadid in (1,2,3)
select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer like '1_5_v%'

update ntSettingsFilesParameters_cn set cTimeFirstCalc = '10:30' where Threadid in (1)
update ntSettingsFilesParameters_cn set cTimeFirstCalc = '07:30' where Threadid in (1)
update ntSettingsFilesParameters_cn set cDateCalc = '' where Threadid in (1,2,3)
update ntSettingsFilesParameters_cn set cDateCalc = '2016.06.06' where Threadid in (1) --,2,3)
update ntSettingsFilesParameters_cn set cTimeLast = '07:30' where Threadid in (1)
update ntSettingsFilesParameters_cn set cTimeLast = '23:55' where Threadid in (1)

update ntSettingsPeriodsParameters_cn set ParamsIdentifyer = replace(ParamsIdentifyer,'1_5_v','6E_5_v') where ParamsIdentifyer like '1_5_v%' -- Threadid = 3



-- мен€ем значени€ настраиваемых параметров
select  
-- update p1
set
	p1.cntCharts = p2.cntCharts, p1.cntCharts_last = p2.cntCharts_last, p1.cntCharts_step = p2.cntCharts_step, 
	p1.DeltaMinutesCalcCorr = p2.DeltaMinutesCalcCorr, p1.DeltaMinutesCalcCorr_last = p2.DeltaMinutesCalcCorr_last, p1.DeltaMinutesCalcCorr_step = p2.DeltaMinutesCalcCorr_step, 
	p1.StopLoss = p2.StopLoss, p1.StopLoss_last = p2.StopLoss_last, p1.StopLoss_step = p2.StopLoss_step, 
	p1.TakeProfit = p2.TakeProfit, p1.TakeProfit_last = p2.TakeProfit_last, p1.TakeProfit_step = p2.TakeProfit_step, 
	p1.isCalcAverageValuesInPercents = p2.isCalcAverageValuesInPercents, p1.isCalcAverageValuesInPercents_last = p2.isCalcAverageValuesInPercents_last, p1.isCalcAverageValuesInPercents_step = p2.isCalcAverageValuesInPercents_step, 
	p1.DeltaCcloseRangeMaxLimit = p2.DeltaCcloseRangeMaxLimit, p1.DeltaCcloseRangeMaxLimit_last = p2.DeltaCcloseRangeMaxLimit_last, p1.DeltaCcloseRangeMaxLimit_step = p2.DeltaCcloseRangeMaxLimit_step, 
	p1.DeltaCcloseRangeMinLimit = p2.DeltaCcloseRangeMinLimit, p1.DeltaCcloseRangeMinLimit_last = p2.DeltaCcloseRangeMinLimit_last, p1.DeltaCcloseRangeMinLimit_step = p2.DeltaCcloseRangeMinLimit_step, 
	p1.IsCalcCorrOnlyForSameTime = p2.IsCalcCorrOnlyForSameTime, p1.IsCalcCorrOnlyForSameTime_last = p2.IsCalcCorrOnlyForSameTime_last, p1.IsCalcCorrOnlyForSameTime_step = p2.IsCalcCorrOnlyForSameTime_step, 
	p1.CalcCorrParamsId = p2.CalcCorrParamsId, 
	p1.CntBarsMinLimit = p2.CntBarsMinLimit, p1.CntBarsMinLimit_last = p2.CntBarsMinLimit_last, p1.CntBarsMinLimit_step = p2.CntBarsMinLimit_step
from ntSettingsFilesParameters_cn p1
left outer join ntSettingsFilesParameters_cn p2 on p2.ParamsIdentifyer = '6E_5_v01_PA2' -- Ќј „“ќ мен€ем
where p1.ParamsIdentifyer = '6C_5_v01_PA2' -- „“ќ мен€ем

-- мен€ем ntSettingsPeriodsParameters_cn
select *
 update ntSettingsPeriodsParameters_cn
 set DeltaCcloseRangeMaxLimit = null, DeltaCcloseRangeMinLimit = null, IsCalcCorrOnlyForSameTime = null, DeltaMinutesCalcCorr = null, CntBarsMinLimit = null
from ntSettingsPeriodsParameters_cn 
where ParamsIdentifyer like '6E_5_v%PA%'
 
 




cDateCalc
2016.05.13

delete from ntSettingsFilesParameters_cn where Threadid not in (1,2,3)

select * 
-- delete pp
from ntSettingsPeriodsParameters_cn pp
left outer join ntSettingsFilesParameters_cn fp on fp.ParamsIdentifyer = pp.ParamsIdentifyer
where fp.ParamsIdentifyer is null




update ntSettingsFilesParameters_cn set dbFileName = ParamsIdentifyer + '.mdb'




 select * from ntSettingsFilesParameters_cn where ParamsIdentifyer = '6E_5_v22_PA10'
 select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer = '1_5_v09_PAB100'
 
-- delete from ntSettingsPeriodsParameters_cn where idn in (53,54)
update ntSettingsFilesParameters_cn set cTimeFirst = '02:30' where ParamsIdentifyer = '1_5_v04'

