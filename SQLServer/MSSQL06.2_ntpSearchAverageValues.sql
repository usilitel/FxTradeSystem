
	


--/*
-- drop PROCEDURE ntpSearchAverageValues
alter PROCEDURE ntpSearchAverageValues (
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
	@pcntBarsCalcCorr int, -- ���������� �����, �� ������� ������� � (0 - �������� ��������� ����-�����)

	@DeltaCcloseRangeMaxLimit real, -- ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
	@DeltaCcloseRangeMinLimit real, -- ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
	@IsCalcCorrOnlyForSameTime int, -- 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
	@DeltaMinutesCalcCorr int, -- ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
	@CalcCorrParamsId varchar(20) -- ������������� ���������� ������� �	
	
)
AS BEGIN 
-- ���������:
-- 1) ���������, ���� �� ��� ������������ ������� ���������� �� ���� �� ��������� ��������� (�������� - � ������� ntImportCurrent, ������������ ������� ���������� - � ������� ntAverageValuesResults).
-- 2) ���������� � ������� ntImportCurrent_NoAverageValues �� ������� ����, �� ������� ����� ���������� ��� �� ����������.

-- �������: ������� ntImportCurrent (������� ������) �.�. ���������

SET NOCOUNT ON



	If object_ID('tempdb..#ntImportCurrent') Is not Null drop table #ntImportCurrent

	select *
	into #ntImportCurrent
	from ntImportCurrent
	where ParamsIdentifyer = @pParamsIdentifyer



	
	If object_ID('tempdb..#ntImportCurrent_NoAverageValues') Is not Null drop table #ntImportCurrent_NoAverageValues

	-- ������ ����� ������ (������� �������� ��, � ����� ����� ���������� � ����������)
	select top 1 *
	into #ntImportCurrent_NoAverageValues
	from ntImportCurrent_NoAverageValues

	truncate table #ntImportCurrent_NoAverageValues
	
	



if @pcntBarsCalcCorr = 0
begin
	-- ��������� ������� ������ �� ������� ntImportCurrent, �� ������� �� ���������� ����� ���������� (��� ��������������� ������� � ������� ntAverageValuesResults)
	insert into #ntImportCurrent_NoAverageValues (idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer)
	SELECT c.idn, @cDateTimeFirst, c.cdate, c.ctime, c.copen, c.chigh, c.clow, c.cclose, @pParamsIdentifyer
	from #ntImportCurrent c
	left outer join #ntImportCurrent cf on --cf.ParamsIdentifyer = @pParamsIdentifyer and 
		cf.cdate + ' ' + cf.ctime = @cDateTimeFirst -- ������ � �������� ������ ������� �
	 -- ������ � ��� ������������� ������������ �� ������� ����
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = @cDateTimeFirst -- ��������� ����� ������ ������� �
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- ��������� ����� ��������� ������� ����� �����������
		-- ��������� ���� � ������ ���������� �������
		and v.copen_first = cf.copen
		and v.chigh_first = cf.chigh
		and v.clow_first = cf.clow
		and v.cclose_first = cf.cclose
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
		and v.cntBarsCalcCorr = @pcntBarsCalcCorr		
		
		and v.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit -- ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		and v.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit -- ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		and v.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime -- 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
		and v.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr -- ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
		and v.CalcCorrParamsId = @CalcCorrParamsId -- ������������� ���������� ������� �	
		
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			c.cdate + ' ' + c.ctime >= @cDateTimeFirstCalc
		and c.cdate + ' ' + c.ctime <= @cDateTimeLastCalc
		and v.idn is null -- ����� ���������� �� ����������
end


if @pcntBarsCalcCorr > 0
	-- ��������� ������� ������ �� ������� ntImportCurrent, �� ������� �� ���������� ����� ���������� (��� ��������������� ������� � ������� ntAverageValuesResults)
	insert into #ntImportCurrent_NoAverageValues (idn, cdatetime_first, cdate_last, ctime_last, copen, chigh, clow, cclose, ParamsIdentifyer)
	SELECT c.idn, cf.cdate + ' ' + cf.ctime, c.cdate, c.ctime, c.copen, c.chigh, c.clow, c.cclose, @pParamsIdentifyer
	from #ntImportCurrent c
	left outer join #ntImportCurrent cf on --cf.ParamsIdentifyer = @pParamsIdentifyer and 
		cf.idn = c.idn - @pcntBarsCalcCorr + 1 -- ������ � �������� ������ ������� �
	 -- ������ � ��� ������������� ������������ �� ������� ����
	left outer join ntAverageValuesResults v with (nolock) on
			v.cdatetime_first = cf.cdate + ' ' + cf.ctime -- ��������� ����� ������ ������� �
		and v.cdatetime_last = c.cdate + ' ' + c.ctime -- ��������� ����� ��������� ������� ����� �����������
		-- ��������� ���� � ������ ���������� �������
		and v.copen_first = cf.copen
		and v.chigh_first = cf.chigh
		and v.clow_first = cf.clow
		and v.cclose_first = cf.cclose
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
		and v.cntBarsCalcCorr = @pcntBarsCalcCorr

		and v.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit -- ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		and v.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit -- ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
		and v.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime -- 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
		and v.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr -- ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
		and v.CalcCorrParamsId = @CalcCorrParamsId -- ������������� ���������� ������� �	
	where --c.ParamsIdentifyer = @pParamsIdentifyer
			c.cdate + ' ' + c.ctime >= @cDateTimeFirstCalc
		and c.cdate + ' ' + c.ctime <= @cDateTimeLastCalc
		and v.idn is null -- ����� ���������� �� ����������
		and cf.ctime is not null -- ���� ������ ���������� ����� ��� ������� �
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
--select * from ntImportCurrent_NoAverageValues (nolock) order by idn desc -- ����� ����������, ������� ����� ����������


/*

exec ntpSearchAverageValues --'2015.08.14 00:00', '2015.08.14 09:30', '2015.08.14 09:40', 15, 10, 20, 0.0001, 1, 1, 2, 5
	-- ��������� ������� ����� �����������
	@cDateTimeFirst = '2015.08.14 00:00', -- ����� ������ ������� �
	@cDateTimeFirstCalc = '2015.08.14 09:00', -- ����� ������ ������� ����� �����������
	@cDateTimeLastCalc = '2015.08.14 09:50', -- ����� ��������� ������� ����� �����������
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
