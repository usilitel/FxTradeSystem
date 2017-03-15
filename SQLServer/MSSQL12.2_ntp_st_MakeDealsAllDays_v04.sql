

alter PROCEDURE ntp_st_MakeDealsAllDays_v04 (
	-- ��������� ��������� ���� ��������� � ���������� ����������� �� ������� #nt_st_chart
	-- � ���������� ����������� ������ � ������� #nt_st_deals
	
	-- �������: (��������� � ����������� �� ������� ��� ������� �� ������� nt_st_parameters_TimeInMinutes)
	-- �����:    ��������� ������� �� ������� nt_st_parameters_ParamsIdentifyersSets
	
	-- ������� #nt_st_chart ������ ���� ������� � ���������
	-- ������� #nt_st_deals ������ ���� �������
	-- ������� #ntAverageValuesResults ������ ���� ������� � ���������
	
	
	-- ���������� ��� ���������� ������� ����
	--@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	--@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	--@cntCharts int, 
	@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
	-- ���������� ��� ������� ������
	--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	--@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	--@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	---- ������ ��������� ���������
	--@param_StopLoss real, 
	--@param_TakeProfit real, 
	@param_cntSignalsBeforeDeal int, -- ���������� �������� ������, ������ ��� ���������� ������
	@param_volume real,
	--@param_DealTimeInMinutesFirst int, -- ����� � ������� �� 00:00, ������� � �������� ��������� ������
	--@param_DealTimeInMinutesLast int,   -- ����� � ������� �� 00:00, ���������� ������� ��������� ������
	@param_IsOnlyOneActiveDeal int, -- 1 = ������ ���� �������� �������  � ���� ������� (�������� ���� Buy � ���� Sell ������������), 0 = �������������� ����� �������� ������� (1 ������ = 1 ������)
	@param_IsOpenOppositeDeal int, -- 1 = ���� ��������� ��������������� ������ - �� ��������� ��� �������� ������� � ��������� ������� �� �������, 0 = ��������� ������� ������ �� SL � TP
	
	
--	@ParamsIdentifyersSetId int,
	@param_cntBuySignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
	@param_cntSellSignalsLimit_Start int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
	@param_cntBuySignalsLimit_Stop int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
	@param_cntSellSignalsLimit_Stop int -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������





	
)
AS BEGIN 
-- ��������� ��� ���������� ������� tPeriodsData �������

SET NOCOUNT ON

	-- ���������� ���������� �� �������
	declare @c_idn int, @c_idn_chart int, @c_deal_direction int, @c_idn_chart_deal_cclose int,
			@c_idn_previous int, @c_idn_chart_previous int, @c_deal_direction_previous int, @c_idn_chart_deal_cclose_previous int,
	
	@c_copen real, @c_chigh real, @c_clow real, @c_cclose real, @c_Volume int, @c_ABV real, @c_ABVMini real, @c_TimeInMinutes int,
	@v_CcorrMax real, @v_CcorrAvg real, @v_TakeProfit_isOk_Daily_up_AvgCnt real, @v_TakeProfit_isOk_Daily_down_AvgCnt real, @v_TakeProfit_isOk_Daily_up_PrcBars real, @v_TakeProfit_isOk_Daily_down_PrcBars real, @v_TakeProfit_isOk_AtOnce_up_AvgCnt real, @v_TakeProfit_isOk_AtOnce_down_AvgCnt real, @v_ChighMax_Daily_Avg real, @v_ClowMin_Daily_Avg real, @v_ChighMax_AtOnce_Avg real, @v_ClowMin_AtOnce_Avg real,

	-- ���������� ��� ������� ������
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	-- ������ ��������� ���������
	@param_StopLoss real, 
	@param_TakeProfit real
--	@param_cntSignalsBeforeDeal int -- ���������� �������� ������, ������ ��� ���������� ������

	-- ��������������� ����������	
	declare 
	@is_DealActive int, -- 1 - ���� �������� ������� �������, 2 - ���� �������� �������� �������, 0 - ��� �������� �������
	@cntSignalsBefore int, -- ���������� �������� ������, ������� ���� �� �������� ������� (+ = ���������� �������� �� �������, - = ���������� �������� �� �������)
	--@is_first_deal int,
	@idn_AverageValues int, -- idn ������ �� ������� ntAverageValuesResults
	@DealTimeInMinutesFirstCurrent int, -- ������� ������ �������
	@DealTimeInMinutesLastCurrent int, -- ������� ����� �������
	--@DealTimeInMinutesFirstPrevious int -- ���������� ������ ������� (������������ ��� ����������� �������� � ��������� ��������� ������)

	@cntBuySignals int, -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��
	@cntSellSignals int -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��



	
	-- ��������� ������
	declare 
	@deal_copen real, -- ���� �������� ������
	@deal_direction int, -- ����������� ������ (1=buy, 2=sell)
	@deal_StopLoss real, -- StopLoss �� ������
	@deal_TakeProfit real, -- TakeProfit �� ������
	@deal_volume real, -- ����� ������
	@deal_cclose real, -- ���� �������� ������
	@deal_profit real, -- ������� �� ������
	@deal_profit_total real -- ����� ������� �� ���� �������
	

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 1

	-- ��������� ���������� ����������
	select  @is_DealActive = 0,
			@cntSignalsBefore = 0,
			@deal_direction = 0,
			@deal_profit_total = 0
			

	truncate table #nt_st_deals








	If object_ID('tempdb..#t_cntBuySignals') Is not Null drop table #t_cntBuySignals
	If object_ID('tempdb..#t_cntSellSignals') Is not Null drop table #t_cntSellSignals

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 2




	-- ��������� ���������� �������� �� �������
	select  c.idn, 
			count(distinct vb.ParamsIdentifyer) as cntBuySignals
			--count(distinct p2.CalcCorrParamsId) as cntCalcCorrParamsId
			--count(distinct p2.CalcCorrParamsId) as cntBuySignals
	into #t_cntBuySignals
	from #nt_st_chart c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.is_active = 1 --ParamsIdentifyersSetId = @ParamsIdentifyersSetId
	left outer join #ntAverageValuesResults vb with (index=index1) on -- ������� �� �������
			vb.ParamsIdentifyer = p.ParamsIdentifyer
		and vb.cdatetime_last = c.cdatetime
		and (
			 vb.TakeProfit_isOk_AtOnce_up_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_AtOnce_up_AvgCnt-vb.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vb.TakeProfit_isOk_Daily_up_AvgCnt >= p.limit_TakeProfit_isOk_Daily_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_Daily_up_AvgCnt-vb.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
	--left outer join ntSettingsFilesParameters_cn p2 with (nolock) on p2.ParamsIdentifyer = vb.ParamsIdentifyer
	group by c.idn
	order by c.idn

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 3
-- select * from ntSettingsFilesParameters_cn

	-- ��������� ���������� �������� �� �������
	select  c.idn, 
			count(distinct vs.ParamsIdentifyer) as cntSellSignals
			--count(distinct p2.CalcCorrParamsId) as cntCalcCorrParamsId
			--count(distinct p2.CalcCorrParamsId) as cntSellSignals
	into #t_cntSellSignals
	from #nt_st_chart c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.is_active = 1 --ParamsIdentifyersSetId = @ParamsIdentifyersSetId
	left outer join #ntAverageValuesResults vs with (index=index1) on -- ������� �� �������
			vs.ParamsIdentifyer = p.ParamsIdentifyer
		and vs.cdatetime_last = c.cdatetime
		and (
			 vs.TakeProfit_isOk_AtOnce_down_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_AtOnce_up_AvgCnt-vs.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vs.TakeProfit_isOk_Daily_down_AvgCnt >= p.limit_TakeProfit_isOk_Daily_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_Daily_up_AvgCnt-vs.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
	--left outer join ntSettingsFilesParameters_cn p2 with (nolock) on p2.ParamsIdentifyer = vs.ParamsIdentifyer
	group by c.idn
	order by c.idn



	
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 4

	-- ���������� ���������� �������� �� ������� � �� �������
	update c
	set c.cntBuySignals = bs.cntBuySignals,
		c.cntSellSignals = ss.cntSellSignals
	from #nt_st_chart c
	left outer join #t_cntBuySignals bs on bs.idn = c.idn -- ������� �� �������
	left outer join #t_cntSellSignals ss on ss.idn = c.idn -- ������� �� �������




-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 5


	-- ���������� ������
	insert into #nt_st_deals(
		idn_chart,
		-- ��������� ������� ����� �����������
		StopLoss, TakeProfit, OnePoint, 
		-- ������ ��������� ���������
		param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, 
		-- ��������� ������
		deal_copen, -- ���� �������� ������
		deal_direction, -- ����������� ������ (1=buy, 2=sell)
		--deal_StopLoss, -- StopLoss �� ������
		--deal_TakeProfit, -- TakeProfit �� ������
		deal_volume, -- ����� ������
		cdatetime,
		CurrencyIdCurrent,
		CurrencyIdHistory,
		ABMmPosition0,
		ABMmPosition1,
		TimeInMinutes_deal_copen
		)
	select
		idn,
		@StopLoss, @TakeProfit, @OnePoint, 
		-- ������ ��������� ���������
		@StopLoss, 
		@TakeProfit, 
		@param_cntSignalsBeforeDeal, -- ���������� �������� ������, ������ ��� ���������� ������
		@param_volume, 
		-- ��������� ������
		cclose, -- ���� �������� ������

		case when (
								cntBuySignals >= @param_cntBuySignalsLimit_Start -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
								and
								cntSellSignals <= @param_cntSellSignalsLimit_Stop -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
								)
			then 1
			when (
								cntSellSignals >= @param_cntSellSignalsLimit_Start -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
								and
								cntBuySignals <= @param_cntBuySignalsLimit_Stop -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
								)
			then 2
			else 0
			end as deal_direction, -- ����������� ������ (1=buy, 2=sell)
		--@deal_StopLoss, -- StopLoss �� ������
		--@deal_TakeProfit, -- TakeProfit �� ������
		@param_volume as deal_volume,  -- ����� ������
		cdatetime,
		CurrencyIdCurrent,
		CurrencyIdHistory,
		ABMmPosition0,
		ABMmPosition1,		
		CONVERT(int,SUBSTRING(cdatetime,12,2))*60 + CONVERT(int,SUBSTRING(cdatetime,15,2))
	from #nt_st_chart
	where	(
			cntBuySignals >= @param_cntBuySignalsLimit_Start -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
			and
			cntSellSignals <= @param_cntSellSignalsLimit_Stop -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
			)
			or
			(
			cntSellSignals >= @param_cntSellSignalsLimit_Start -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������� �� �������
			and
			cntBuySignals <= @param_cntBuySignalsLimit_Stop -- ���������� �������� �� ������� �� ������ ParamsIdentifyer-��, ����������� ��� ������ ������ ������� �� �������
			)
						

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 6

	-- ��������� deal_StopLoss � deal_TakeProfit
	update #nt_st_deals
	set deal_StopLoss = case when deal_direction = 1
							 then deal_copen - (StopLoss * OnePoint)
							 when deal_direction = 2
							 then deal_copen + (StopLoss * OnePoint)
							 else 0
						end ,
		deal_TakeProfit = case when deal_direction = 1
							 then deal_copen + (TakeProfit * OnePoint)
							 when deal_direction = 2
							 then deal_copen - (TakeProfit * OnePoint)
							 else 0
						end


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 7


	-- ��������� �������� ������ �� �������
	update d
	set d.deal_cclose = case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then deal_TakeProfit
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then deal_StopLoss
							 else 0 
						end,
		d.idn_chart_deal_cclose = -- idn_chart ���� �������� ������
						case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then isnull(cp.idn,100000000)
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then isnull(cl.idn,100000000)
							 else 0 
						end
	from #nt_st_deals d
	left outer join #nt_st_chart cp on -- ������ ��� � TakeProfit
			cp.idn > d.idn_chart
		and cp.chigh >= d.deal_TakeProfit
		and cp.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and chigh >= d.deal_TakeProfit)
	left outer join #nt_st_chart cl on -- ������ ��� � StopLoss
			cl.idn > d.idn_chart
		and cl.clow <= d.deal_StopLoss
		and cl.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and clow <= d.deal_StopLoss)
	where d.deal_direction = 1


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 8

	-- ��������� �������� ������ �� �������
	update d
	set d.deal_cclose = case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then deal_TakeProfit
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then deal_StopLoss
							 else 0 
						end,
		d.idn_chart_deal_cclose = -- idn_chart ���� �������� ������
						case when isnull(cp.idn,100000000) <= isnull(cl.idn,100000000) then isnull(cp.idn,100000000)
							 when isnull(cp.idn,100000000) > isnull(cl.idn,100000000) then isnull(cl.idn,100000000)
							 else 0 
						end
	from #nt_st_deals d
	left outer join #nt_st_chart cp on -- ������ ��� � TakeProfit
			cp.idn > d.idn_chart
		and cp.clow <= d.deal_TakeProfit
		and cp.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and clow <= d.deal_TakeProfit)
	left outer join #nt_st_chart cl on -- ������ ��� � StopLoss
			cl.idn > d.idn_chart
		and cl.chigh >= d.deal_StopLoss
		and cl.idn = (select min(idn) from #nt_st_chart where idn > d.idn_chart and chigh >= d.deal_StopLoss)
	where d.deal_direction = 2


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 9

	-- ������ ����� �������� ������
	update d
	set d.cdatetime_deal_cclose = c.cdatetime,
		d.TimeInMinutes_deal_cclose = CONVERT(int,SUBSTRING(c.cdatetime,12,2))*60 + CONVERT(int,SUBSTRING(c.cdatetime,15,2))
	from #nt_st_deals d
	left outer join #nt_st_chart c on c.idn = d.idn_chart_deal_cclose



-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 10


	-- ������� ������, �������� ������ ��� ��������� ����������
	if @param_IsOnlyOneActiveDeal = 1
	begin
		DECLARE cDealsCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
		-- �������� ��� ������ �� �������
		SELECT  idn, idn_chart, deal_direction, idn_chart_deal_cclose
		from #nt_st_deals
		where deal_direction = 1
		order by cdatetime

		select @c_idn = 0, @c_idn_chart = 0, @c_deal_direction = 0, @c_idn_chart_deal_cclose = 0
		select @c_idn_previous = 0, @c_idn_chart_previous = 0, @c_deal_direction_previous = 0, @c_idn_chart_deal_cclose_previous = 0
		
		OPEN cDealsCursor

		-- ���������� ��� ���� � ������������ ����� ����������
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		WHILE @@FETCH_STATUS = 0
		BEGIN

			if @c_idn_previous = 0 -- ���� ������ ������
				select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- ���������� ��������� �������� ������
			else -- ���� �� ������ ������
			begin
				if @c_idn_chart < @c_idn_chart_deal_cclose_previous -- ������ ������� ������ ��� ��������� ����������
					update #nt_st_deals
					set deal_direction = 0
					where idn = @c_idn
				else
					select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- ���������� ��������� �������� ������
			end
			
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		END 
		--exit_cursor:
		CLOSE cDealsCursor;
		DEALLOCATE cDealsCursor;
		
		
		
		
		
		DECLARE cDealsCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
		-- �������� ��� ������ �� �������
		SELECT  idn, idn_chart, deal_direction, idn_chart_deal_cclose
		from #nt_st_deals
		where deal_direction = 2
		order by cdatetime

		select @c_idn = 0, @c_idn_chart = 0, @c_deal_direction = 0, @c_idn_chart_deal_cclose = 0
		select @c_idn_previous = 0, @c_idn_chart_previous = 0, @c_deal_direction_previous = 0, @c_idn_chart_deal_cclose_previous = 0
		
		OPEN cDealsCursor

		-- ���������� ��� ���� � ������������ ����� ����������
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		WHILE @@FETCH_STATUS = 0
		BEGIN

			if @c_idn_previous = 0 -- ���� ������ ������
				select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- ���������� ��������� �������� ������
			else -- ���� �� ������ ������
			begin
				if @c_idn_chart < @c_idn_chart_deal_cclose_previous -- ������ ������� ������ ��� ��������� ����������
					update #nt_st_deals
					set deal_direction = 0
					where idn = @c_idn
				else
					select @c_idn_previous = @c_idn, @c_idn_chart_previous = @c_idn_chart, @c_deal_direction_previous = @c_deal_direction, @c_idn_chart_deal_cclose_previous = @c_idn_chart_deal_cclose -- ���������� ��������� �������� ������
			end
			
		FETCH NEXT FROM cDealsCursor 
		INTO @c_idn, @c_idn_chart, @c_deal_direction, @c_idn_chart_deal_cclose
		END 
		--exit_cursor:
		CLOSE cDealsCursor;
		DEALLOCATE cDealsCursor;	
		
		delete from #nt_st_deals where deal_direction = 0
	end
	
	
---------------------------------------

	-- ������� ������ �� ��� � "�������" ���������
	update d
	set d.deal_direction = 0
	from #nt_st_deals d
	left outer join ntCalendarIdnData c on c.cdate = left(d.cdatetime,10) -- ��� ������� �� ���� ������
	left outer join ntCalendarActive ca on -- ���������� ������� �� ���� ������
			ca.CurrencyId = d.CurrencyIdCurrent
		and ca.cName = c.cName
		and ca.cCountry = c.cCountry
		and ((ca.cVolatility = c.cVolatility) or (ca.cVolatility = -1))
		and ca.isActive = 0
	where ca.isActive = 0
		
	delete from #nt_st_deals where deal_direction = 0


	-- ������� ������ ����������� ������ 11:30
	-- !!! ����� ����������: �������� ������� "����� ������� ��������"
	delete from #nt_st_deals where TimeInMinutes_deal_copen < (11*60+30)

	--delete from #nt_st_deals where deal_direction = 2

---------------------------------------




	update #nt_st_deals
	set deal_profit = 	case when deal_direction = 1 then round(((deal_cclose - deal_copen) * param_volume),0)
							 when deal_direction = 2 then round(((deal_cclose - deal_copen) * param_volume),0) * (-1)
						else 0 end
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 11

	update t1
	set deal_profit_total = (select sum(deal_profit) from #nt_st_deals t2 where t2.idn <= t1.idn)
	from #nt_st_deals t1
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'ntp_st_MakeDealsAllDays_v04', '', GETDATE(), 12
	
	
	/*
	update d
	set d.cdatetime = c.cdatetime
	from #nt_st_deals d
	left outer join nt_st_chart c on c.idn=d.idn_chart

	*/


	---- ��������� ������������ ������ � ���������� �������
	--insert into nt_st_deals(idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer)
	--select					idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer
	--from #nt_st_deals
	--order by idn


END


