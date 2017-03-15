
/*
exec ntpImportCurrentChartAverageValues --'2015.08.14 00:00', '2015.08.14 09:30', '2015.08.14 09:40', 15, 10, 20, 0.0001, 1, 1, 2, 5
	-- ��������� ������� ����� �����������
	@cDateTimeFirst = '2015.12.14 10:05', -- ����� ������ ������� �
	@cDateTimeFirstCalc = '2015.12.14 10:30', -- ����� ������ ������� ����� �����������
	@cDateTimeLastCalc = '2015.12.14 22:00', -- ����� ��������� ������� ����� �����������
	@cntCharts = 15,
	@StopLoss = 100,
	@TakeProfit = 200,
	@OnePoint = 1,
	@CurrencyId_current = 6,
	@CurrencyId_history = 6,
	@DataSourceId = 3,
	@PeriodMinutes = 5,
	@isCalcAverageValuesInPercents = 1, -- 1 - ������� ����������� �������� � ��������� �� ����, 0 - ������� � �������
	@pParamsIdentifyer = '1400_40_6_6_3_5_1_1_0_0',
	@pCntDaysPreviousShowABV = 100
*/
	
-- select * from ntImportCurrentChartAverageValues where ParamsIdentifyer = '1_5' order by idn desc

/*
exec ntpImportCurrentChartAverageValues --'2015.08.14 00:00', '2015.08.14 09:30', '2015.08.14 09:40', 15, 10, 20, 0.0001, 1, 1, 2, 5
	-- ��������� ������� ����� �����������
	@cDateTimeFirst = '2015.12.14 02:05', -- ����� ������ ������� �
	@cDateTimeFirstCalc = '2015.12.14 03:10', -- ����� ������ ������� ����� �����������
	@cDateTimeLastCalc = '2015.12.14 22:00', -- ����� ��������� ������� ����� �����������
	@cntCharts = 15,
	@StopLoss = 10,
	@TakeProfit = 20,
	@OnePoint = 0.0001,
	@CurrencyId_current = 1,
	@CurrencyId_history = 1,
	@DataSourceId = 2,
	@PeriodMinutes = 5,
	@isCalcAverageValuesInPercents = 1, -- 1 - ������� ����������� �������� � ��������� �� ����, 0 - ������� � �������
	@pParamsIdentifyer = '1400_40_1_1_2_5_1_1_0_0',
	@pCntDaysPreviousShowABV = 100
	*/

	
	

-- select * from ntImportCurrent
-- select * from ntAverageValuesResults
-- select * from ntAverageValuesResultsAgregated

/*
declare
	-- ������� ��������� (��������� ������� ����� �����������)
	@cDateTimeFirst varchar(16), -- ����� ������ ������� �
	@cDateTimeFirstCalc varchar(16), -- ����� ������ ������� ����� �����������
	@cDateTimeLastCalc varchar(16), -- ����� ��������� ������� ����� �����������
	
	@cntCharts int, -- ���������� ������� ��������, ������� ����� ��� �������
	@StopLoss real, -- StopLoss � �������
	@TakeProfit real, -- TakeProfit � �������
	@OnePoint real, -- �������� ������ ������ � ����
	@CurrencyId_current	int, -- CurrencyId ������ ������� ������
	@CurrencyId_history	int, -- CurrencyId ������ ������������ ������ (� �������� ����������)
	@DataSourceId	int,
	@PeriodMinutes int
	
select	
	-- ��������� ������� ����� �����������
	@cDateTimeFirst = '2015.08.04 00:00', -- ����� ������ ������� �
	@cDateTimeFirstCalc = '2015.08.04 09:30', -- ����� ������ ������� ����� �����������
	@cDateTimeLastCalc = '2015.08.04 09:40', -- ����� ��������� ������� ����� �����������
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



-- ������� ��������� ��� ���������� �������� ������� ������ ������������
-- drop PROCEDURE ntpImportCurrentChartAverageValues
alter PROCEDURE ntpImportCurrentChartAverageValues(
	-- ������� ��������� (��������� ������� ����� �����������)
	@cDateTimeFirst varchar(16), -- ����� ������ ������� �
	@cDateTimeFirstCalc varchar(16), -- ����� ������ ������� ����� �����������
	@cDateTimeLastCalc varchar(16), -- ����� ��������� ������� ����� �����������
	
	@cntCharts int, -- ���������� ������� ��������, ������� ����� ��� �������
	@StopLoss real, -- StopLoss � �������
	@TakeProfit real, -- TakeProfit � �������
	@OnePoint real, -- �������� ������ ������ � ����
	@CurrencyId_current	int, -- CurrencyId ������ ������� ������
	@CurrencyId_history	int, -- CurrencyId ������ ������������ ������ (� �������� ����������)
	@DataSourceId	int,
	@PeriodMinutes int,
	@isCalcAverageValuesInPercents int, -- 1 - ������� ����������� �������� � ��������� �� ����, 0 - ������� � �������
	@pParamsIdentifyer VARCHAR(50),
	@pCntDaysPreviousShowABV int, -- ���������� ���������� ����, �� ������� ���������� ABV �� ������� (1 - ���������� ������ �� ������� ����)
	@pCntBarsCalcCorr int -- ���������� �����, �� ������� ������� � (0 - �������� ��������� ����-�����)

	
)
AS BEGIN 
-- ��������� ��������� ������� ������ (������� ntImportCurrentChartAverageValues) ������ ������������

-- ������� ��� �������: 
-- ������� ntImportCurrentChartAverageValues �.�. ��� ���������

-- ���������: 
-- 1) � ������� ntImportCurrentChartAverageValues ����������� ����� ������������ �������� (�� ������� ntAverageValuesResults)

	SET NOCOUNT ON

 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 1

	
	declare
		@CntBarsMinLimit integer, -- ����������� ���������� �����, ������� ����� ���� � �������� ���
		@DeltaCcloseRangeMaxLimit real, -- ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		@DeltaCcloseRangeMinLimit real, -- ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		@IsCalcCorrOnlyForSameTime int, -- 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
		@DeltaMinutesCalcCorr int, -- ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
		@CalcCorrParamsId varchar(20) -- ������������� ���������� ������� �	
		
		
	-- ����� ����������� ��������� �������
	select
		@CntBarsMinLimit = CntBarsMinLimit, -- ����������� ���������� �����, ������� ����� ���� � �������� ���
		@DeltaCcloseRangeMaxLimit = DeltaCcloseRangeMaxLimit, -- ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		@DeltaCcloseRangeMinLimit = DeltaCcloseRangeMinLimit, -- ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		@IsCalcCorrOnlyForSameTime = IsCalcCorrOnlyForSameTime, -- 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
		@DeltaMinutesCalcCorr = DeltaMinutesCalcCorr, -- ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
		@CalcCorrParamsId = CalcCorrParamsId -- ������������� ���������� ������� �	
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


	-- ��������� ����� ���������� �� ���� �������
	-- SELECT c.*, v.*
	update c
	set	c.CcorrMax = v.CcorrMax,
		c.CcorrAvg = v.CcorrAvg,
		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt = v.TakeProfit_isOk_Daily_up_AvgCnt, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
		c.TakeProfit_isOk_Daily_down_AvgCnt = v.TakeProfit_isOk_Daily_down_AvgCnt, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
		c.TakeProfit_isOk_Daily_up_PrcBars = v.TakeProfit_isOk_Daily_up_PrcBars, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		c.TakeProfit_isOk_Daily_down_PrcBars = v.TakeProfit_isOk_Daily_down_PrcBars, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt = v.TakeProfit_isOk_AtOnce_up_AvgCnt, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt = v.TakeProfit_isOk_AtOnce_down_AvgCnt, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
		-- (3)
		c.ChighMax_Daily_Avg = v.ChighMax_Daily_Avg, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
		c.ClowMin_Daily_Avg = v.ClowMin_Daily_Avg, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
		-- (4)
		c.ChighMax_AtOnce_Avg = v.ChighMax_AtOnce_Avg, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
		c.ClowMin_AtOnce_Avg = v.ClowMin_AtOnce_Avg, -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)

		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt_nd = v.TakeProfit_isOk_Daily_up_AvgCnt_nd, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
		c.TakeProfit_isOk_Daily_down_AvgCnt_nd = v.TakeProfit_isOk_Daily_down_AvgCnt_nd, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
		c.TakeProfit_isOk_Daily_up_PrcBars_nd = v.TakeProfit_isOk_Daily_up_PrcBars_nd, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		c.TakeProfit_isOk_Daily_down_PrcBars_nd = v.TakeProfit_isOk_Daily_down_PrcBars_nd, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
		-- (3)
		c.ChighMax_Daily_Avg_nd = v.ChighMax_Daily_Avg_nd, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
		c.ClowMin_Daily_Avg_nd = v.ClowMin_Daily_Avg_nd, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
		-- (4)
		c.ChighMax_AtOnce_Avg_nd = v.ChighMax_AtOnce_Avg_nd, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
		c.ClowMin_AtOnce_Avg_nd = v.ClowMin_AtOnce_Avg_nd -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
	from #ntImportCurrentChartAverageValues c
	left outer join ntImportCurrent cf with (nolock) on cf.ParamsIdentifyer = @pParamsIdentifyer and cf.cdate + ' ' + cf.ctime = @cDateTimeFirst -- ������ � �������� ������ ������� �
	 -- ������ � ��� ������������� ������������ �� ������� ����
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = (case when @pCntBarsCalcCorr = 0 then @cDateTimeFirst else v.cdatetime_first end) -- ��������� ����� ������ ������� � (�� ����������� ��� @pCntBarsCalcCorr > 0)
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- ��������� ����� ��������� ������� ����� �����������
		-- ��������� ���� � ������ ���������� ������� (�� ����������� ��� @pCntBarsCalcCorr > 0)
		and v.copen_first = (case when @pCntBarsCalcCorr = 0 then cf.copen else v.copen_first end)
		and v.chigh_first = (case when @pCntBarsCalcCorr = 0 then cf.chigh else v.chigh_first end)
		and v.clow_first = (case when @pCntBarsCalcCorr = 0 then cf.clow else v.clow_first end)
		and v.cclose_first = (case when @pCntBarsCalcCorr = 0 then cf.cclose else v.cclose_first end)
		-- ��������� ���� � ����� ���������� �������
		and v.copen_last = c.copen
		and v.chigh_last = c.chigh
		and v.clow_last = c.clow
		and v.cclose_last = c.cclose		
		-- ��������� ��������� ������� ����� �����������	
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
	--	and v.idn is null -- ����� ���������� �� ����������



 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 4




	-- ��������� ����� ���������� �� ������ �����
	
	-- ���������� ��� ������������ ����������
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
	  and cTime_First = right(@cDateTimeFirst,5) -- ��������� cTime_First
	  
	  and CntBarsMinLimit = @CntBarsMinLimit
	  and DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit	  
	  and DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit	  
	  and IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime	  
	  and DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr	  
	  and CalcCorrParamsId = @CalcCorrParamsId	  
	  
	group by cdate_first, ctime_first, cdatetime_first, copen_first, chigh_first, clow_first, cclose_first, cntCharts, StopLoss, TakeProfit, OnePoint, CurrencyId_current, CurrencyId_history, DataSourceId, PeriodMinutes, isCalcAverageValuesInPercents


-- select 1, * from #ntAverageValuesResultsAgregated

	-- �������� �� ������, � ������� � ������� ������� ���� ����������� ������ ��� ������ ������� �
	update v set cntValues = 0
	-- select * 
	from #ntAverageValuesResultsAgregated v
	left outer join #ntImportCurrentChartAverageValues c with (nolock) on 
			--c.ParamsIdentifyer = @pParamsIdentifyer
			c.cdate = v.cdate_first
	where c.cdatetime is null

	delete from #ntAverageValuesResultsAgregated where cntValues = 0

-- select 2, * from #ntAverageValuesResultsAgregated

	-- ���������� ������������ ���������� ������������ ����������� �� ����
	select cdate_first, MAX(cntValues) as MaxCntValues
	into #ntAverageValuesResultsAgregatedMaxCntValues
	from #ntAverageValuesResultsAgregated
	group by cdate_first

	-- select * from #ntAverageValuesResultsAgregatedMaxCntValues

	-- �������� ������ � ������������ ����������� ������������ �����������
	update v set cntValues = 0
	--select * 
	from #ntAverageValuesResultsAgregated v
	left outer join #ntAverageValuesResultsAgregatedMaxCntValues m on 
		  m.cdate_first = v.cdate_first
	  and m.MaxCntValues = v.CntValues
	where m.MaxCntValues is null

	delete from #ntAverageValuesResultsAgregated where cntValues = 0

-- select 3, * from #ntAverageValuesResultsAgregated

	-- �������� ������ � ����������� �������� ������ ������� �
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


	-- ��������� ����� ���������� �� ������ �����
	 --SELECT * --c.*, v.*
	update c
	set	c.CcorrMax = v.CcorrMax,
		c.CcorrAvg = v.CcorrAvg,
		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt = v.TakeProfit_isOk_Daily_up_AvgCnt, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
		c.TakeProfit_isOk_Daily_down_AvgCnt = v.TakeProfit_isOk_Daily_down_AvgCnt, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
		c.TakeProfit_isOk_Daily_up_PrcBars = v.TakeProfit_isOk_Daily_up_PrcBars, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		c.TakeProfit_isOk_Daily_down_PrcBars = v.TakeProfit_isOk_Daily_down_PrcBars, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt = v.TakeProfit_isOk_AtOnce_up_AvgCnt, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt = v.TakeProfit_isOk_AtOnce_down_AvgCnt, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
		-- (3)
		c.ChighMax_Daily_Avg = v.ChighMax_Daily_Avg, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
		c.ClowMin_Daily_Avg = v.ClowMin_Daily_Avg, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
		-- (4)
		c.ChighMax_AtOnce_Avg = v.ChighMax_AtOnce_Avg, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
		c.ClowMin_AtOnce_Avg = v.ClowMin_AtOnce_Avg, -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)

		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt_nd = v.TakeProfit_isOk_Daily_up_AvgCnt_nd, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
		c.TakeProfit_isOk_Daily_down_AvgCnt_nd = v.TakeProfit_isOk_Daily_down_AvgCnt_nd, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
		c.TakeProfit_isOk_Daily_up_PrcBars_nd = v.TakeProfit_isOk_Daily_up_PrcBars_nd, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		c.TakeProfit_isOk_Daily_down_PrcBars_nd = v.TakeProfit_isOk_Daily_down_PrcBars_nd, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
		-- (3)
		c.ChighMax_Daily_Avg_nd = v.ChighMax_Daily_Avg_nd, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
		c.ClowMin_Daily_Avg_nd = v.ClowMin_Daily_Avg_nd, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
		-- (4)
		c.ChighMax_AtOnce_Avg_nd = v.ChighMax_AtOnce_Avg_nd, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
		c.ClowMin_AtOnce_Avg_nd = v.ClowMin_AtOnce_Avg_nd -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
	from #ntImportCurrentChartAverageValues c
	left outer join #ntAverageValuesResultsAgregated a on a.cdate_first = c.cdate -- ���������� cdate_first, ��� �������� ����� �������� ������������ ���������� �� ����
	 -- ������ � ��� ������������� ������������ �� ������� ����
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = a.cdatetime_first -- ��������� ����� ������ ������� �
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- ��������� ����� ��������� ������� ����� �����������
		-- ��������� ���� � ������ ���������� �������
		and v.copen_first = a.copen_first
		and v.chigh_first = a.chigh_first
		and v.clow_first = a.clow_first
		and v.cclose_first = a.cclose_first
		-- ��������� ���� � ����� ���������� �������
		and v.copen_last = c.copen
		and v.chigh_last = c.chigh
		and v.clow_last = c.clow
		and v.cclose_last = c.cclose
		-- ��������� ��������� ������� ����� �����������	
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
			c.CcorrMax is NULL -- ����� ���������� �� ����������
	    and c.cdate <> left(@cDateTimeFirst,10) -- ������ ����
	
 --select 5, * from ntImportCurrentChartAverageValues where ParamsIdentifyer = @pParamsIdentifyer
 
 -- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntpImportCurrentChartAverageValues', @pParamsIdentifyer, GETDATE(), 6

	-- ��������� ABV ������ �� ������ ���
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
		c.TakeProfit_isOk_Daily_up_AvgCnt = v.TakeProfit_isOk_Daily_up_AvgCnt, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
		c.TakeProfit_isOk_Daily_down_AvgCnt = v.TakeProfit_isOk_Daily_down_AvgCnt, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
		c.TakeProfit_isOk_Daily_up_PrcBars = v.TakeProfit_isOk_Daily_up_PrcBars, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		c.TakeProfit_isOk_Daily_down_PrcBars = v.TakeProfit_isOk_Daily_down_PrcBars, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt = v.TakeProfit_isOk_AtOnce_up_AvgCnt, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt = v.TakeProfit_isOk_AtOnce_down_AvgCnt, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
		-- (3)
		c.ChighMax_Daily_Avg = v.ChighMax_Daily_Avg, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
		c.ClowMin_Daily_Avg = v.ClowMin_Daily_Avg, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
		-- (4)
		c.ChighMax_AtOnce_Avg = v.ChighMax_AtOnce_Avg, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
		c.ClowMin_AtOnce_Avg = v.ClowMin_AtOnce_Avg, -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)

		-- (1)
		c.TakeProfit_isOk_Daily_up_AvgCnt_nd = v.TakeProfit_isOk_Daily_up_AvgCnt_nd, -- ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
		c.TakeProfit_isOk_Daily_down_AvgCnt_nd = v.TakeProfit_isOk_Daily_down_AvgCnt_nd, -- ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
		c.TakeProfit_isOk_Daily_up_PrcBars_nd = v.TakeProfit_isOk_Daily_up_PrcBars_nd, -- (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		c.TakeProfit_isOk_Daily_down_PrcBars_nd = v.TakeProfit_isOk_Daily_down_PrcBars_nd, -- (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
		-- (2)
		c.TakeProfit_isOk_AtOnce_up_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_up_AvgCnt_nd, -- ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
		c.TakeProfit_isOk_AtOnce_down_AvgCnt_nd = v.TakeProfit_isOk_AtOnce_down_AvgCnt_nd, -- ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
		-- (3)
		c.ChighMax_Daily_Avg_nd = v.ChighMax_Daily_Avg_nd, -- ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
		c.ClowMin_Daily_Avg_nd = v.ClowMin_Daily_Avg_nd, -- ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
		-- (4)
		c.ChighMax_AtOnce_Avg_nd = v.ChighMax_AtOnce_Avg_nd, -- ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
		c.ClowMin_AtOnce_Avg_nd = v.ClowMin_AtOnce_Avg_nd -- ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
			
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
 --select * from ntImportCurrent cf where cf.ParamsIdentifyer = '6E_5_v11_PA2' and cf.cdate + ' ' + cf.ctime = '2016.05.26 02:10' -- ������ � �������� ������ ������� �

	
