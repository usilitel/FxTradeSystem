
select     IsExportToExcelCurrent, IsOpenExcelCurrent, IsExportToExcelHistory, IsOpenExcelHistory, cTimeLast, cTimeFirstCalc, cTimeLastCalc, * 
-- update ntSettingsFilesParameters_cn set cTimeLast = '20:00', IsExportToExcelCurrent=0, IsOpenExcelCurrent=0, IsExportToExcelHistory=0, IsOpenExcelHistory=0
from ntSettingsFilesParameters_cn where ThreadId = 2

-- insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer
-- delete
from ntAverageValuesResults_history
where CurrencyId_current = 1 and CalcCorrParamsId = '2-1-1' and cdate_last <= '2016.06.18'
order by cdatetime_calc




select CalcCorrParamsId, cdate_last, count(*)
from ntAverageValuesResults_history (nolock) 
--where CurrencyId_current = 1 and CalcCorrParamsId = '2-1-1'
where CurrencyId_current = 1 and CalcCorrParamsId = '2-1-1' and cdate_last <= '2016.06.18'
group by CalcCorrParamsId, cdate_last
--having count(*) <> 1944
order by CalcCorrParamsId, cdate_last




select count(*) from ntAverageValuesResults (nolock) where CurrencyId_current = 4 and StopLoss = 15

select CalcCorrParamsId, cdate_last, count(*)
from ntAverageValuesResults (nolock) 
where CurrencyId_current = 1 -- and StopLoss = 15
group by CalcCorrParamsId, cdate_last
--having count(*) <> 1944
order by CalcCorrParamsId, cdate_last


----------------------

SELECT CONVERT(varchar, GETDATE(), 111)  -- 'yyyy/mm/dd'

select case when @currentDate >=

select case datediff(hh,getutcdate(), getdate()) when 3 then 'summer' when 2 then 'winter' end
select getutcdate()



----------------------

select * from ntSettingsPeriodsParameters_cn where ParamsIdentifyer = '6E_5_v21_PA10' and WeightCORR <> 0 order by idn

select * from ntAverageValuesResults (nolock) where ParamsIdentifyer like '6E_%_PA211_d2' order by cdatetime_last desc

sp_configure 'query wait (s)'



cdate	ctime
2016.11.17	16:15



select * 
-- delete
from ntAverageValuesResults where cdate_last = '2016.11.28' and ctime_last = '10:20' order by idn desc -- рассчитанные общие показатели (за все время)

insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, '10:25' as ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer
from ntAverageValuesResults where cdate_last = '2016.11.28' and ctime_last = '10:20' order by idn desc -- рассчитанные общие показатели (за все время)




select top 300 * from ntAverageValuesResults (nolock) order by idn desc -- рассчитанные общие показатели (за все время)
select * from ntAverageValuesResults (nolock) order by idn desc -- рассчитанные общие показатели (за все время)
select TakeProfit_isOk_Daily_up_AvgCnt - TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, * from ntAverageValuesResults (nolock) where ParamsIdentifyer in ('6E_15_120_PA211','6E_15_30_PA211','6E_30_120_PA211','6E_30_60_PA211','6E_45_120_PA211','6E_45_90_PA211') order by idn desc -- рассчитанные общие показатели (за все время)
select * from ntAverageValuesResults (nolock) where cdate_last = '2015.12.07' order by idn desc -- рассчитанные общие показатели (за все время)
-- delete from ntAverageValuesResults where idn = 1759145 and CurrencyId_current = 6 -- если нужно пересчитать общие показатели за период, то удаляем уже рассчитанные
-- delete from ntAverageValuesResults where idn >= 1805691 and idn <= 1805702
-- delete from ntAverageValuesResults where ParamsIdentifyer = '6E_15_120_PA211_4d'
select * 
-- delete
from ntAverageValuesResults where 1=1 and cntBarsCalcCorr = 0
	and cdate_last = '2016.11.03'  and ctime_first = '02:10' 
	--and ctime_last = '15:30' --and ctime_last <= '15:20' 
	--and ctime_last = '23:15'
	and cntCharts = 15
	and DeltaMinutesCalcCorr = 120
	--and DeltaCcloseRangeMaxLimit is not null
order by cntCharts, DeltaCcloseRangeMaxLimit, ctime_last --cdatetime_calc
--select * from ntAverageValuesResults where idn in (64727,64729,64730)




select * from ntImportCurrentChartAverageValues -- таблица для текущего графика с рассчитанными общими показателями
select * from ntImportCurrent_NoAverageValues (nolock) order by idn desc -- общие показатели, которые нужно рассчитать


-- delete from ntImportCurrent_NoAverageValues

------------------------------------------------------
-- select * from ntCorrResultsReport
-- select * from ntImportCurrent

	select * from ntSettingsFilesParameters_cn WITH(NOLOCK)
	where ParamsIdentifyer = '6B_15_120_PA211_lp1530'
	
select * 
-- update ntSettingsFilesParameters_cn set StopLoss = 15, TakeProfit = 30 
-- update ntSettingsFilesParameters_cn set StopLoss_last = 15, TakeProfit_last = 30
-- update ntSettingsFilesParameters_cn set ThreadId = 2
from ntSettingsFilesParameters_cn where CurrencyId_current = 4 and StopLoss = 15
 and StopLoss_last = 20





20	20	1	40




ParamsIdentifyer = '6B_15_120_PA211_lp1530'
		
select * 
-- delete
-- update ntAverageValuesResults set ctime_first = '00:01', cdatetime_first = '2015.12.17 00:01'
from ntAverageValuesResults 
where cntBarsCalcCorr = 0 and 
 cdatetime_last like '2016.01.04 %' 
 and ctime_first = '02:10'
 and PeriodMinutes = 5
 and CurrencyId_current = 1
 and ctime_last <= '22:00'
order by ctime_last desc
 
select * from ntAverageValuesResults where ctime_last = '22:00' order by cdatetime_last desc
select * 
-- delete
from ntAverageValuesResults where cdatetime_last = '2015.08.04 07:25' order by idn desc

select * 
--into _ntAverageValuesResults_copy
-- delete
from ntAverageValuesResults where cdate_first <= '2015.10.30' order by idn desc

-- удаляем кривые записи (для пересчета менять ntSettingsFilesParameters.cDateTimeLast, cDateTimeFirstCalc, cDateTimeLastCalc)
select * --distinct cdate_first
--into _ntAverageValuesResults_copy
-- delete
from ntAverageValuesResults where CurrencyId_current is NULL order by idn desc -- (1)
from ntAverageValuesResults where cdate_first <> cdate_last order by idn desc  -- (2)

SET DATEFORMAT ymd
select datediff(dd,'2015.10.02','2015.06.11')
select datediff(dd,'15.07.2016','04.01.2009')
select datediff(dd,'01.01.2009','20.12.2013')

select TakeProfit_isOk_AtOnce_up_AvgCnt, count(*) from ntAverageValuesResults group by TakeProfit_isOk_AtOnce_up_AvgCnt order by TakeProfit_isOk_AtOnce_up_AvgCnt
select TakeProfit_isOk_AtOnce_down_AvgCnt, count(*) from ntAverageValuesResults group by TakeProfit_isOk_AtOnce_down_AvgCnt order by TakeProfit_isOk_AtOnce_down_AvgCnt
select distinct round(abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt),5) from ntAverageValuesResults order by round(abs(TakeProfit_isOk_AtOnce_up_AvgCnt - TakeProfit_isOk_AtOnce_down_AvgCnt),5)

select * from ntAverageValuesResults order by ChighMax_AtOnce_Avg
select * from ntAverageValuesResults order by ClowMin_AtOnce_Avg
select abs(ChighMax_AtOnce_Avg-ClowMin_AtOnce_Avg), * from ntAverageValuesResults order by abs(ChighMax_AtOnce_Avg-ClowMin_AtOnce_Avg)


select * from ntAverageValuesResults where cdatetime_last = '2016.02.01 11:00'



-----------------
-- сделать после расчета за 2014 год:
-- select * into ntAverageValuesResults_20140101_20160205_DeltaMinutesCalcCorr_30min from ntAverageValuesResults (nolock) order by cdatetime_first
-----------------

-- truncate table ntAverageValuesResults


select cdate, count(*) as cnt
into #t1
from ntPeriodsData d2
where 				d2.CurrencyId = 1
			and d2.DataSourceId = 2
			and d2.PeriodMinutes = 5
			--and d2.cdate = d1.cdate
			--and d2.idn >= d1.idn
			and d2.PeriodMultiplicator = 1
group by cdate

-- СПИСОК ПРОЦЕДУР И ТАБЛИЦ --

-- ntpSearchAverageValues
-- процедура записывает в таблицу ntImportCurrent_NoAverageValues те текущие даты, на которые общие показатели еще не рассчитаны.

-- ntpCorrResultsReport -- exec ntpCorrResultsReport 120, '1_5'
-- процедура ищет информацию по записям, находящимся в таблице ntCorrResults и заполняет таблицу ntCorrResultsReport (общие показатели по первым 15 графикам)

-- ntpCorrResultsPeriodsData
-- процедура для заполнения таблицы ntCorrResultsPeriodsData (графики) данными

-- ntpCorrResultsAverageValues
-- результат: 
-- 1) в таблицу ntCorrResultsReport добавляются рассчитанные величины
-- 2) в таблицу ntAverageValuesResults записываются общие рассчитанные величины

-- ntpImportCurrentChartAverageValues
-- условия для расчета: 
-- таблица ntImportCurrentChartAverageValues д.б. уже заполнена
-- результат: 
-- 1) в таблицу ntImportCurrentChartAverageValues (текущий график) добавляются общие рассчитанные величины (из таблицы ntAverageValuesResults)

-- delete from ntCorrResultsReport
select * from ntCorrResults (nolock) where ParamsIdentifyer = '6E_15_120_PA211' order by ccorr desc
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211' 
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211' 
select * from ntAverageValuesResults where ParamsIdentifyer = 'qsSi_15_120_PA211' 
select * from ntCorrResultsPeriodsData 
select * from ntCorrResultsPeriodsData_DataChart where ParamsIdentifyer = '6E_15_120_PA211' order by idn
select * from ntCorrResultsPeriodsData_DataTotal where ParamsIdentifyer = '6E_15_120_PA211'

select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA211' 
select * from ntImportCurrent where ParamsIdentifyer = '6E_15_120_PA211' 

-- 1) таблица ntCorrResultsReport д.б. уже заполнена
-- 2) таблица ntImportCurrent д.б. заполнена (нужны только 1-я и последняя записи)



select * from ntCorrResults (nolock)
select distinct ParamsIdentifyer from ntCorrResults (nolock) where ParamsIdentifyer not in ('6B_15_120_PA211','6B_15_120_PA211_lp2040','6B_15_120_PA211_v02','6B_15_120_PA211_v02_lp2040','6B_15_120_PA211_v03','6B_15_120_PA211_v03_lp2040','6E_15_120_PA211','6E_15_120_PA211_v02','6E_15_120_PA211_v03') order by ParamsIdentifyer
select * from ntImportCurrentChartAverageValues where ParamsIdentifyer = '1_5' order by idn desc
select * from ntImportCurrent (nolock) where ParamsIdentifyer = '6E_5_v01_PA2' order by idn desc
select * from ntCorrResults where ParamsIdentifyer = '1_5' order by ccorr desc
select * from ntCorrResultsPeriodsData_DataChart where ParamsIdentifyer = '1_5'
exec ntpSearchAverageValues '2016.04.29 00:00', '2016.04.29 23:30', '2016.04.29 23:55', 15, 10, 20, 9.99999974737875E-05, 1, 1, 2, 5, 1, '1_5', 0
select * from ntAverageValuesResults where cdatetime_last = '2016.04.29 23:35'
select * from ntCorrResultsReport (nolock) where ParamsIdentifyer = '1_5' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '4_5' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '29_5' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '1_5_v08_PA10' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v01_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '1_5_v03' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '1_5_v10_PAB100' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '1_5_v09_PAB64' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '1_5_v11_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v01_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v24_PA10' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v23_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v01_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v11_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v21_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v23_PA2' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v03_PA10' -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA110' order by cdate desc -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_15_120_PA110' order by deltaMinutes desc -- (общие показатели по первым 15 графикам)
select * from ntCorrResultsReport (nolock) where ParamsIdentifyer = '6E_15_120_PA211' -- (общие показатели по первым 15 графикам)



select * from ntCorrResults where ParamsIdentifyer = '6E_5_v01_PA2' order by ccorr desc
select * from ntImportCurrentChartAverageValues where ParamsIdentifyer = '6E_5_v11_PA2' order by idn desc
select * from ntImportCurrentChartAverageValues where ParamsIdentifyer = '6E_5_v11_PA2' order by idn
select * from ntAverageValuesResults where ParamsIdentifyer = '6E_5_v11_PA2' order by idn



select * from ntAverageValuesResults (nolock) where cdatetime_last = '2016.03.01 17:05' order by idn desc -- рассчитанные общие показатели (за все время)
select * from _ntAverageValuesResults_old (nolock) where cdatetime_last = '2016.03.01 17:05' order by idn desc -- рассчитанные общие показатели (за все время)
select * from ntAverageValuesResults (nolock) where cdatetime_last = '2015.10.01 22:00' order by idn desc -- рассчитанные общие показатели (за все время)
select * from ntAverageValuesResults (nolock) where cdatetime_last = '2015.12.01 22:00' order by idn desc -- рассчитанные общие показатели (за все время)


select * 
from ntAverageValuesResults v (nolock)
left outer join _ntAverageValuesResults_old v2 (nolock) on 
		v2.cdatetime_last = v.cdatetime_last
	and v2.cntCharts = v.cntCharts
	and v2.DeltaMinutesCalcCorr = v.DeltaMinutesCalcCorr
	and v2.cdatetime_first = v.cdatetime_first
where   1=1
	--and v.cdate_last = '2016.04.04'
	--and v.cdatetime_last = '2016.03.01 17:05'
	and v2.cdatetime_last is not null
	and (v.CcorrMax <> v2.CcorrMax or 	 v.CcorrAvg <> v2.CcorrAvg or 	 v.TakeProfit_isOk_Daily_up_AvgCnt <> v2.TakeProfit_isOk_Daily_up_AvgCnt or 	 v.TakeProfit_isOk_Daily_down_AvgCnt <> v2.TakeProfit_isOk_Daily_down_AvgCnt or 	 v.TakeProfit_isOk_Daily_up_PrcBars <> v2.TakeProfit_isOk_Daily_up_PrcBars or 	 v.TakeProfit_isOk_Daily_down_PrcBars <> v2.TakeProfit_isOk_Daily_down_PrcBars or 	 v.TakeProfit_isOk_AtOnce_up_AvgCnt <> v2.TakeProfit_isOk_AtOnce_up_AvgCnt or 	 v.TakeProfit_isOk_AtOnce_down_AvgCnt <> v2.TakeProfit_isOk_AtOnce_down_AvgCnt or 	 v.ChighMax_Daily_Avg <> v2.ChighMax_Daily_Avg or 	 v.ClowMin_Daily_Avg <> v2.ClowMin_Daily_Avg or 	 v.ChighMax_AtOnce_Avg <> v2.ChighMax_AtOnce_Avg or 	 v.ClowMin_AtOnce_Avg <> v2.ClowMin_AtOnce_Avg or 	 v.TakeProfit_isOk_Daily_up_AvgCnt_nd <> v2.TakeProfit_isOk_Daily_up_AvgCnt_nd or 	 v.TakeProfit_isOk_Daily_down_AvgCnt_nd <> v2.TakeProfit_isOk_Daily_down_AvgCnt_nd or 	 v.TakeProfit_isOk_Daily_up_PrcBars_nd <> v2.TakeProfit_isOk_Daily_up_PrcBars_nd or 	 v.TakeProfit_isOk_Daily_down_PrcBars_nd <> v2.TakeProfit_isOk_Daily_down_PrcBars_nd or 	 v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd <> v2.TakeProfit_isOk_AtOnce_up_AvgCnt_nd or 	 v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd <> v2.TakeProfit_isOk_AtOnce_down_AvgCnt_nd or 	 v.ChighMax_Daily_Avg_nd <> v2.ChighMax_Daily_Avg_nd or 	 v.ClowMin_Daily_Avg_nd <> v2.ClowMin_Daily_Avg_nd or 	 v.ChighMax_AtOnce_Avg_nd <> v2.ChighMax_AtOnce_Avg_nd or 	 v.ClowMin_AtOnce_Avg_nd <> v2.ClowMin_AtOnce_Avg_nd )
order by v.cdatetime_last, v.idn -- рассчитанные общие показатели (за все время)


CcorrMax	CcorrAvg	TakeProfit_isOk_Daily_up_AvgCnt	TakeProfit_isOk_Daily_down_AvgCnt	TakeProfit_isOk_Daily_up_PrcBars	TakeProfit_isOk_Daily_down_PrcBars	TakeProfit_isOk_AtOnce_up_AvgCnt	TakeProfit_isOk_AtOnce_down_AvgCnt	ChighMax_Daily_Avg	ClowMin_Daily_Avg	ChighMax_AtOnce_Avg	ClowMin_AtOnce_Avg
TakeProfit_isOk_Daily_up_AvgCnt_nd	TakeProfit_isOk_Daily_down_AvgCnt_nd	TakeProfit_isOk_Daily_up_PrcBars_nd	TakeProfit_isOk_Daily_down_PrcBars_nd	TakeProfit_isOk_AtOnce_up_AvgCnt_nd	TakeProfit_isOk_AtOnce_down_AvgCnt_nd	ChighMax_Daily_Avg_nd	ClowMin_Daily_Avg_nd	ChighMax_AtOnce_Avg_nd	ClowMin_AtOnce_Avg_nd





select *
-- delete
from ntAverageValuesResults --(nolock) 
where   cdate_last in ('2015.11.02','2016.03.01')
	--and cdatetime_calc >= '14.06.2016'
order by cdatetime_calc





select cdatetime_last, cntCharts, StopLoss, TakeProfit, CurrencyId_current, CurrencyId_history, isCalcAverageValuesInPercents, cntBarsCalcCorr, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, 
		count(*)
from ntAverageValuesResults (nolock) 
group by cdatetime_last, cntCharts, StopLoss, TakeProfit, CurrencyId_current, CurrencyId_history, isCalcAverageValuesInPercents, cntBarsCalcCorr, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId
having count(*) > 1


select *
from ntAverageValuesResults (nolock) 
where   cdate_last >= '2015.10.01'
	and cdate_last <  '2016.01.01'
order by cdatetime_last

select CalcCorrParamsId, cdate_last, count(*)
from ntAverageValuesResults (nolock) 
where CalcCorrParamsId = '2-1-1'
	and paramsidentifyer like '%_lp2040%'
group by CalcCorrParamsId, cdate_last
--having count(*) <> 1944
order by CalcCorrParamsId, cdate_last

select cdatetime_last, count(*)
from ntAverageValuesResults (nolock) 
where CalcCorrParamsId = '1-1-0'
group by cdatetime_last
having count(*) <> 12
order by cdatetime_last




select *
-- delete
from ntAverageValuesResults --(nolock) 
where CalcCorrParamsId = '1-1-0' and cdatetime_last in (
'2015.07.03 23:50',	'2015.07.03 23:55',	
'2015.09.18 12:05',	'2015.09.18 23:50',	'2015.09.18 23:55',
'2015.09.29 10:35',	'2015.09.29 23:50',	'2015.09.29 23:55'
)

select *
-- delete
from ntAverageValuesResults
where cdatetime_last in ()



select * from ntSettingsFilesParameters_cn 
-- update ntSettingsFilesParameters_cn set CalcCorrParamsId = '1-0-0'
where ParamsIdentifyer like ('6E_%')
select * from ntSettingsPeriodsParameters_cn 
-- update ntSettingsPeriodsParameters_cn set WeightCORR = 0 
where ParamsIdentifyer like ('6E_%') and FieldNumCurrent in (7,8)

select datediff(dd,'01.07.2015','31.12.2015')


select * from _ntAverageValuesResults_20151209 (nolock) where cdate_last = '2015.12.07' and CurrencyId_current = 1 and isCalcAverageValuesInPercents = 1 order by cdatetime_last desc -- рассчитанные общие показатели (за все время)
select * from ntAverageValuesResults (nolock) where cdate_last = '2016.03.24' and CurrencyId_current = 1 and isCalcAverageValuesInPercents = 1 and cntCharts = 15 and DeltaMinutesCalcCorr = 120 order by cdatetime_last desc -- рассчитанные общие показатели (за все время)
select * from ntAverageValuesResults (nolock) where cdatetime_last = '2016.03.24 19:25' and ctime_last >= '10:00' and ctime_last <= '10:25' and CurrencyId_current = 1 and isCalcAverageValuesInPercents = 1 and cntCharts = 15 and DeltaMinutesCalcCorr = 120 order by cdatetime_last desc -- рассчитанные общие показатели (за все время)

select * from ntAverageValuesResults (nolock) where cdate_last = '2016.03.24' order by cdatetime_calc desc
select * from ntAverageValuesResults (nolock) where cdate_last = '2016.03.24' and idn <= 279954 order by cdatetime_calc desc
-- delete from ntAverageValuesResults  where cdate_last = '2016.03.24' and idn <= 279954
select * from ntAverageValuesResults (nolock) where cdate_last = '2016.03.28' order by cdatetime_calc desc
select * from ntAverageValuesResults (nolock) where cdate_last = '2015.10.01' order by cdatetime_calc desc






select * from ntlog_ntCalendarIdnData with (nolock) order by cdatetime_log desc, idnDataEventdates desc
-- truncate table ntlog_ntCalendarIdnData

-- select * into ntAverageValuesResults_history from ntAverageValuesResults (nolock) where cdate_last < '2016.06.15' order by idn desc -- рассчитанные общие показатели (за все время)
-- delete from ntAverageValuesResults where cdate_last < '2016.06.15'

-- insert into ntAverageValuesResults_history (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer
from ntAverageValuesResults

-- insert into ntAverageValuesResults (cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer)
select cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cdate_last, ctime_last, cdatetime_last, copen_last, chigh_last, clow_last, cclose_last, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg, cdatetime_calc, isCalcAverageValuesInPercents, cntBarsCalcCorr, TakeProfit_isOk_Daily_up_AvgCnt_nd, TakeProfit_isOk_Daily_down_AvgCnt_nd, TakeProfit_isOk_Daily_up_PrcBars_nd, TakeProfit_isOk_Daily_down_PrcBars_nd, TakeProfit_isOk_AtOnce_up_AvgCnt_nd, TakeProfit_isOk_AtOnce_down_AvgCnt_nd, ChighMax_Daily_Avg_nd, ClowMin_Daily_Avg_nd, ChighMax_AtOnce_Avg_nd, ClowMin_AtOnce_Avg_nd, DeltaCcloseRangeMaxLimit, DeltaCcloseRangeMinLimit, IsCalcCorrOnlyForSameTime, DeltaMinutesCalcCorr, CalcCorrParamsId, CntBarsMinLimit, ParamsIdentifyer
from ntAverageValuesResults_history
where cdate_last >= '2016.06.18'
order by cdatetime_calc

-- delete
from ntAverageValuesResults_history
where cdate_last >= '2016.06.18'



select datediff(dd,'01.01.2013','20.12.2013')
select datediff(dd,'01.02.2014','15.07.2016')




select ParamsIdentifyer, * 
-- delete
from ntAverageValuesResults where ParamsIdentifyer like '6B_%_PA211%' and ParamsIdentifyer not like '%_lp2040%'
	and cdate_last = '2016.07.20'



-- оцениваем скорость работы: 3300-3500/час
select left(cdatetime_calc,16), count(*) --cdatetime_calc, left(cdatetime_calc,15), * 
from ntAverageValuesResults (nolock) 
where cdatetime_calc >= '17.06.2016 09:00'
group by left(cdatetime_calc,16)
order by left(cdatetime_calc,16) --idn desc

select cdatetime_calc, left(cdatetime_calc,15), * 
from ntAverageValuesResults (nolock) 
where cdatetime_calc >= '15.06.2016 12:00'
order by idn desc




-- лог
select * from ntlog_ntCalendarIdnData order by cdatetime_log desc

-- delete from ntlog_ntCalendarIdnData

exec ntpCorrResultsAverageValuesParamRanges  '6E_15_120_v2' 

select * from ntSettingsFilesParameters_cn
select * from ntSettingsPeriodsParameters_cn




select * from ntlog_ntCalendarIdnData with (nolock) 
--where ParamsIdentifyer = '6C_5_v06_PA2' 
order by cdatetime_log desc, idnDataEventdates desc
-- delete from ntlog_ntCalendarIdnData
	

select * from sys.sysprocesses where blocked != 0
EXEC sp_lock
EXEC sp_who2
EXEC sp_who2 active


select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v11_PA2'

645
290759981	1131587	2015.05.19	23:55	0	5	0,9250959		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759982	1107752	2015.01.16	23:55	0	5	0,92101		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759983	1111283	2015.02.04	23:55	0	5	0,9093521		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759984	843395	2011.04.15	23:35	20	5	0,9007068		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759985	925915	2012.06.18	23:55	0	5	0,8996804		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759986	980392	2013.03.27	23:20	35	5	0,8968415		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759987	929452	2012.07.05	23:40	15	5	0,894694		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759988	734651	2009.10.01	23:55	0	5	0,8857037		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759989	1045045	2014.02.26	23:55	0	5	0,8831658		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759990	1056900	2014.04.29	23:55	0	5	0,8762619		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759991	972440	2013.02.14	23:55	0	5	0,8727189		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759992	1113981	2015.02.18	23:35	20	5	0,8724482		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759993	975412	2013.03.01	23:20	35	5	0,8714393		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759994	943971	2012.09.18	23:20	35	5	0,8698384		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL
290759995	987297	2013.05.02	23:55	0	5	0,8657967		0	0	0	0	0	0	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	6E_5_v11_PA2	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL

delete from [ntCorrResultsPeriodsData_DataChart] where ParamsIdentifyer = '6E_5_v11_PA2'
delete from [ntCorrResultsPeriodsData_DataTotal] where ParamsIdentifyer = '6E_5_v11_PA2'
delete from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v11_PA2'
delete from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v11_PA2'


select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v01_PA2' and idndata = 1131587
select * from ntCorrResultsReport where ParamsIdentifyer = '6E_5_v11_PA2' and idndata = 1131587

exec ntpCorrResultsAverageValuesParamRanges  '6E_5_v01_PA2' 

select * from ntimportcurrent where ParamsIdentifyer = '6E_5_v11_PA2'
select * from ntCorrResultsPeriodsData_DataChart where ParamsIdentifyer = '6E_5_v11_PA2'
select * from ntCorrResultsPeriodsData_DataChart where ParamsIdentifyer = '6E_5_v01_PA2'
select * from ntCorrResultsPeriodsData_DataTotal where ParamsIdentifyer = '6E_5_v12_PA10'
select * from ntCorrResultsReport
select * from ntAverageValuesResults
select count(*) from ntPeriodsData
select * from ntCorrResultsPeriodsData_DataChart where ParamsIdentifyer = '6E_5_v12_PA10'

		select d2.cdate, d2.PeriodMultiplicator, count(*) as cntBars
		--into #TradeDays
		from ntPeriodsData d2 WITH(NOLOCK index=index3)
		where   d2.CurrencyId = 1
			and d2.DataSourceId = 2
			and d2.PeriodMinutes = 5
		group by d2.cdate, d2.PeriodMultiplicator
		having count(*) >= 30
					
	
-- delete from ntImportCurrent_NoAverageValues
-- delete from ntImportCurrent_NoAverageValues where ParamsIdentifyer = '1400_40_1_1_2_5_1_1_1_0'

-- select * into ntAverageValuesResults_DeltaMinutesCalcCorr_120 from ntAverageValuesResults

-- select * into ntAverageValuesResults_20150611_20160205_DeltaMinutesCalcCorr_30min from ntAverageValuesResults order by cdatetime_last
-- truncate table ntAverageValuesResults
select * from ntSettingsFilesParameters


--------------------
-- проверка правильности расчета общих показателей:
select TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, * 
-- delete -- для пересчета и проверки
from ntAverageValuesResults where cdatetime_last = '2015.07.21 12:55'

select TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, * 
-- delete -- для пересчета и проверки
from ntAverageValuesResults where cdatetime_last > '2016.02.17 11:15'


-- данные по каждому варианту из истории
select TakeProfit_isOk_AtOnce_up, * 
from ntCorrResultsReport where ParamsIdentifyer = '1_5'
			and cntBars_day is not null 	

--------------------




select ParamsIdentifyer, * from ntCorrResultsReport order by idn -- 816
-- delete from ntCorrResultsReport
select * from ntImportCurrent
select * from ntSettings

select * from ntAverageValuesResults where cdatetime_last is null
	
	

select * 
-- delete
-- update ntAverageValuesResults set ctime_first = '00:01', cdatetime_first = '2015.12.17 00:01'
from ntAverageValuesResults 
where cntBarsCalcCorr = 0 and cdatetime_last like '2015.12.23 %' 
 and PeriodMinutes = 5
 and CurrencyId_current = 1


SELECT c.idn, 0 as idnData, c.cdate, c.ctime, c.cdatetime, c.copen, c.chigh, c.clow, c.cclose, 
	   0 as cperiodResult, 0 as cdateResult, 0 as ctimeResult, 0 as deltaMinutesResult, 0 as ccorrResult, 0 as cperiodsAll, 0 as is_replaced, 0 as deltaKmaxPercent, 0 as ccorrmax_replaced, 0 as cperiodMax_replaced, 0 as deltaMinutesMax_replaced, c.Volume, c.ABV, c.ABVMini, c.ABMmPosition0, c.ABMmPosition1
	v.CcorrMax,
	v.CcorrAvg,
	v.TakeProfit_isOk_Daily_up_AvgCnt,
	v.TakeProfit_isOk_Daily_down_AvgCnt,
	v.TakeProfit_isOk_Daily_up_PrcBars,
	v.TakeProfit_isOk_Daily_down_PrcBars,
	v.TakeProfit_isOk_AtOnce_up_AvgCnt,
	v.TakeProfit_isOk_AtOnce_down_AvgCnt,
	v.ChighMax_Daily_Avg,
	v.ClowMin_Daily_Avg,
	v.ChighMax_AtOnce_Avg,
	v.ClowMin_AtOnce_Avg
from ntImportCurrentChart as c
left outer join ntImportCurrentChart as cf on cf.cdate + ' ' + cf.ctime = @cDateTimeFirst -- строка с временем начала расчета К
 -- строка с уже рассчитанными показателями по текущей дате
left outer join ntAverageValuesResults as v on
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
	
	
select *
from ntImportCurrent c






