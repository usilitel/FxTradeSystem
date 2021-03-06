

alter PROCEDURE ntp_st_MakeDealsAllDays (
	-- ��������� ��������� ���� ��������� � ���������� ����������� �� ������� #nt_st_chart
	-- � ���������� ����������� ������ � ������� #nt_st_deals
	
	-- ��������� � ����������� �� ������� ��� ������� �� ������� nt_st_parameters_TimeInMinutes
	
	-- ������� #nt_st_chart ������ ���� ������� � ���������
	-- ������� #nt_st_deals ������ ���� �������
	
	-- ���������� ��� ���������� ������� ����
	--@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	--@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	@cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	-- ���������� ��� ������� ������
	--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	--@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	--@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	---- ������ ��������� ���������
	--@param_StopLoss real, 
	--@param_TakeProfit real, 
	--@param_cntSignalsBeforeDeal int, -- ���������� �������� ������, ������ ��� ���������� ������
	@param_volume real,
	--@param_DealTimeInMinutesFirst int, -- ����� � ������� �� 00:00, ������� � �������� ��������� ������
	--@param_DealTimeInMinutesLast int,   -- ����� � ������� �� 00:00, ���������� ������� ��������� ������
	@param_IsOnlyOneActiveDeal int -- 1 = ������ ���� �������� �������, 0 = �������������� ����� �������� ������� (�� � ������ ������ ���������� ������� - ������ ����)
	
)
AS BEGIN 
-- ��������� ��� ���������� ������� tPeriodsData �������

SET NOCOUNT ON

	-- ���������� ���������� �� �������
	declare
	@c_idn int, @c_copen real, @c_chigh real, @c_clow real, @c_cclose real, @c_Volume int, @c_ABV real, @c_ABVMini real, @c_TimeInMinutes int,
	@v_CcorrMax real, @v_CcorrAvg real, @v_TakeProfit_isOk_Daily_up_AvgCnt real, @v_TakeProfit_isOk_Daily_down_AvgCnt real, @v_TakeProfit_isOk_Daily_up_PrcBars real, @v_TakeProfit_isOk_Daily_down_PrcBars real, @v_TakeProfit_isOk_AtOnce_up_AvgCnt real, @v_TakeProfit_isOk_AtOnce_down_AvgCnt real, @v_ChighMax_Daily_Avg real, @v_ClowMin_Daily_Avg real, @v_ChighMax_AtOnce_Avg real, @v_ClowMin_AtOnce_Avg real,

	-- ���������� ��� ������� ������
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	-- ������ ��������� ���������
	@param_StopLoss real, 
	@param_TakeProfit real, 
	@param_cntSignalsBeforeDeal int -- ���������� �������� ������, ������ ��� ���������� ������

	-- ��������������� ����������	
	declare 
	@is_DealActive int, -- 1 - ���� �������� ������� �������, 2 - ���� �������� �������� �������, 0 - ��� �������� �������
	@cntSignalsBefore int, -- ���������� �������� ������, ������� ���� �� �������� ������� (+ = ���������� �������� �� �������, - = ���������� �������� �� �������)
	--@is_first_deal int,
	@idn_AverageValues int, -- idn ������ �� ������� ntAverageValuesResults
	@DealTimeInMinutesFirstCurrent int, -- ������� ������ �������
	@DealTimeInMinutesLastCurrent int -- ������� ����� �������
	--@DealTimeInMinutesFirstPrevious int -- ���������� ������ ������� (������������ ��� ����������� �������� � ��������� ��������� ������)

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
	


	-- ��������� ���������� ����������
	select  @is_DealActive = 0,
			@cntSignalsBefore = 0,
			@deal_direction = 0,
			@deal_profit_total = 0
			

	truncate table #nt_st_deals




	DECLARE cPriceCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
	-- �������� ��� ���� � ������������ ����� ����������
	SELECT  idn, copen, chigh, clow, cclose, Volume, ABV, ABVMini, TimeInMinutes,
			CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg,
			idn_AverageValues
	from #nt_st_chart
	order by cdatetime


	OPEN cPriceCursor

	-- ���������� ��� ���� � ������������ ����� ����������
	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes,
		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
		 @idn_AverageValues
	WHILE @@FETCH_STATUS = 0
	BEGIN


		-- ������� ���������� ��������� ��������� ��� �������� ���������� �������
		select 	
			--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
			@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = null, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = null, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = null, 
			--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
			@limit_ChighMax_AtOnce_Avg = null, @limit_ClowMin_AtOnce_Avg = null, @limit_ChighMax_ClowMin_AtOnce_Avg_delta = null,
			-- ������ ��������� ���������
			@param_StopLoss = null, 
			@param_TakeProfit = null, 
			@param_cntSignalsBeforeDeal = null, -- ���������� �������� ������, ������ ��� ���������� ������
			@DealTimeInMinutesFirstCurrent = null,
			@DealTimeInMinutesLastCurrent = null
					
		select 	
			--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
			@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = limit_TakeProfit_isOk_AtOnce_up_AvgCnt, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = limit_TakeProfit_isOk_AtOnce_down_AvgCnt, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
			--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
			@limit_ChighMax_AtOnce_Avg = limit_ChighMax_AtOnce_Avg, @limit_ClowMin_AtOnce_Avg = limit_ClowMin_AtOnce_Avg, @limit_ChighMax_ClowMin_AtOnce_Avg_delta = limit_ChighMax_ClowMin_AtOnce_Avg_delta,
			-- ������ ��������� ���������
			@param_StopLoss = param_StopLoss, 
			@param_TakeProfit = param_TakeProfit, 
			@param_cntSignalsBeforeDeal = param_cntSignalsBeforeDeal, -- ���������� �������� ������, ������ ��� ���������� ������
			@DealTimeInMinutesFirstCurrent = param_DealTimeInMinutesFirst,
			@DealTimeInMinutesLastCurrent = param_DealTimeInMinutesLast
		from nt_st_parameters_TimeInMinutes
		where is_active = 1
		  and param_DealTimeInMinutesFirst <= @c_TimeInMinutes
		  and param_DealTimeInMinutesLast >= @c_TimeInMinutes



		-- ��������� �������� ������ �� StopLoss � TakeProfit
		update #nt_st_deals
		set deal_cclose = deal_TakeProfit -- ���� �������� ������
		where deal_direction = 1 -- Buy, TakeProfit
		  and @c_chigh >= deal_TakeProfit			
		  and deal_cclose is null -- ������ ��� �� �������
			
		update #nt_st_deals
		set deal_cclose = deal_StopLoss -- ���� �������� ������
		where deal_direction = 1 -- Buy, StopLoss
		  and @c_clow <= deal_StopLoss
		  and deal_cclose is null -- ������ ��� �� �������
			
		update #nt_st_deals
		set deal_cclose = deal_TakeProfit -- ���� �������� ������
		where deal_direction = 2 -- Sell, TakeProfit
		  and @c_clow <= deal_TakeProfit
		  and deal_cclose is null -- ������ ��� �� �������
			
		update #nt_st_deals
		set deal_cclose = deal_StopLoss -- ���� �������� ������
		where deal_direction = 2 -- Sell, StopLoss
		  and @c_chigh >= deal_StopLoss
		  and deal_cclose is null -- ������ ��� �� �������			
			




		if @DealTimeInMinutesFirstCurrent is not null
		begin
		
			-- ���������, ���� �� ���������� ������ � ������� ��������� �������
			if (select count(*)
				from #nt_st_deals
				where param_DealTimeInMinutesFirst = @DealTimeInMinutesFirstCurrent
				and deal_cclose is null -- ������ ��� �� �������
				) = 0
				select @is_DealActive = 0 -- ��� ������� � ������� ��������� ������� �������
			else
				select @is_DealActive = 1 -- ���� ���������� ������� � ������� ��������� �������



			-- ��������� ������ �� �������
			if		@is_DealActive = 0
				and @v_TakeProfit_isOk_AtOnce_up_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_up_AvgCnt
				and (@v_TakeProfit_isOk_AtOnce_up_AvgCnt - @v_TakeProfit_isOk_AtOnce_down_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
				and @v_ChighMax_AtOnce_Avg >= @limit_ChighMax_AtOnce_Avg
				and (@v_ChighMax_AtOnce_Avg - @v_ClowMin_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
				--and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
				--and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
			begin
				-- ��������� ������� ��� �������� ������� �� �������
				-- if @is_DealActive = 0
				-- ��������� ��������� ������
				select @deal_copen = @c_cclose, -- ���� �������� ������
					   @deal_direction = 1, -- ����������� ������ (1=buy, 2=sell)
					   @deal_StopLoss = @c_cclose - (@param_StopLoss * @OnePoint), -- StopLoss �� ������
					   @deal_TakeProfit = @c_cclose + (@param_TakeProfit * @OnePoint), -- TakeProfit �� ������
					   @deal_volume = @param_volume, -- ����� ������
					   @deal_cclose = null, -- ���� �������� ������
					   @deal_profit = null, -- ������� �� ������
					   @deal_profit_total = null, -- ����� ������� �� ���� �������
					   @cntSignalsBefore = (case when @cntSignalsBefore < 0 then 1 else @cntSignalsBefore + 1 end) -- ����������� ������� ��������
				--select 1, @idn_AverageValues, @v_ClowMin_AtOnce_Avg , @v_ChighMax_AtOnce_Avg , @limit_ChighMax_ClowMin_AtOnce_Avg_delta
			end
					
					
					
					
			-- ��������� ������ �� �������
			if		@is_DealActive = 0
				and @v_TakeProfit_isOk_AtOnce_down_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_down_AvgCnt
				and (@v_TakeProfit_isOk_AtOnce_down_AvgCnt - @v_TakeProfit_isOk_AtOnce_up_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
				and @v_ClowMin_AtOnce_Avg >= @limit_ClowMin_AtOnce_Avg
				and (@v_ClowMin_AtOnce_Avg - @v_ChighMax_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
				--and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
				--and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
			begin
				-- ��������� ������� ��� �������� ������� �� �������
				-- if @is_DealActive = 0
				-- ��������� ��������� ������
				select @deal_copen = @c_cclose, -- ���� �������� ������
					   @deal_direction = 2, -- ����������� ������ (1=buy, 2=sell)
					   @deal_StopLoss = @c_cclose + (@param_StopLoss * @OnePoint), -- StopLoss �� ������
					   @deal_TakeProfit = @c_cclose - (@param_TakeProfit * @OnePoint), -- TakeProfit �� ������
					   @deal_volume = @param_volume, -- ����� ������
					   @deal_cclose = null, -- ���� �������� ������
					   @deal_profit = null, -- ������� �� ������
					   @deal_profit_total = null, -- ����� ������� �� ���� �������
					   @cntSignalsBefore = (case when @cntSignalsBefore > 0 then -1 else @cntSignalsBefore - 1 end) -- ����������� ������� ��������
				--select 2, @idn_AverageValues, @v_ClowMin_AtOnce_Avg , @v_ChighMax_AtOnce_Avg , @limit_ChighMax_ClowMin_AtOnce_Avg_delta
			end
			
			if @deal_direction = 0 -- ���� ��� ������� �� �� �������, �� �� ������� - �� �������� ������� ��������
				select @cntSignalsBefore = 0 
			



			-- ��������� �������
			if @is_DealActive = 0 and @deal_direction <> 0 and abs(@cntSignalsBefore) >= @param_cntSignalsBeforeDeal
			begin			
				insert into #nt_st_deals(
					idn_chart,
					idn_AverageValues,
					-- ��������� ������� ����� �����������
					cntCharts, StopLoss, TakeProfit, OnePoint, 
					-- ��������� ���������
					-- ���������� ��� ������� ������
					limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, 
					limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
					limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, 
					limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta,
					-- ������ ��������� ���������
					param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, 
					param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast,
					-- ��������� ������
					deal_copen, -- ���� �������� ������
					deal_direction, -- ����������� ������ (1=buy, 2=sell)
					deal_StopLoss, -- StopLoss �� ������
					deal_TakeProfit, -- TakeProfit �� ������
					deal_volume, -- ����� ������
					ParamsIdentifyer,
					cdatetime
					--deal_cclose, -- ���� �������� ������
					--deal_profit, -- ������� �� ������
					--deal_profit_total -- ����� ������� �� ���� �������
					)
				select
					@c_idn,
					@idn_AverageValues,
					@cntCharts, @StopLoss, @TakeProfit, @OnePoint, 
					-- ���������� ��� ������� ������
					@limit_CcorrMax, @limit_CcorrAvg, @limit_TakeProfit_isOk_Daily_up_AvgCnt, @limit_TakeProfit_isOk_Daily_down_AvgCnt, @limit_TakeProfit_isOk_Daily_up_PrcBars, @limit_TakeProfit_isOk_Daily_down_PrcBars, 
					@limit_TakeProfit_isOk_AtOnce_up_AvgCnt, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
					@limit_ChighMax_Daily_Avg, @limit_ClowMin_Daily_Avg, 
					@limit_ChighMax_AtOnce_Avg, @limit_ClowMin_AtOnce_Avg, @limit_ChighMax_ClowMin_AtOnce_Avg_delta,
					-- ������ ��������� ���������
					@param_StopLoss, 
					@param_TakeProfit, 
					@param_cntSignalsBeforeDeal, -- ���������� �������� ������, ������ ��� ���������� ������
					@param_volume, 
					@DealTimeInMinutesFirstCurrent, @DealTimeInMinutesLastCurrent,
					-- ��������� ������
					@deal_copen, -- ���� �������� ������
					@deal_direction, -- ����������� ������ (1=buy, 2=sell)
					@deal_StopLoss, -- StopLoss �� ������
					@deal_TakeProfit, -- TakeProfit �� ������
					@deal_volume,  -- ����� ������
					@ParamsIdentifyer,
					space(16)
					--@deal_cclose, -- ���� �������� ������
					--@deal_profit, -- ������� �� ������
					--@deal_profit_total real -- ����� ������� �� ���� �������
					
					select @is_DealActive = @deal_direction
					--select @c_idn as idn_chart, @c_TimeInMinutes as TimeInMinutes, @DealTimeInMinutesFirstCurrent as DealTimeInMinutesFirstCurrent



			end


		end


		
		select @deal_direction = 0
		--select @DealTimeInMinutesFirstPrevious = @DealTimeInMinutesFirstCurrent
		


	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes,
		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
		 @idn_AverageValues
	END 


	--exit_cursor:
	
	CLOSE cPriceCursor;
	DEALLOCATE cPriceCursor;





	update #nt_st_deals
	set deal_profit = 	case when deal_direction = 1 then round(((deal_cclose - deal_copen) * param_volume),0)
							 when deal_direction = 2 then round(((deal_cclose - deal_copen) * param_volume),0) * (-1)
						else 0 end
	
	update t1
	set deal_profit_total = (select sum(deal_profit) from #nt_st_deals t2 where t2.idn <= t1.idn)
	from #nt_st_deals t1
	
	update d
	set d.cdatetime = c.cdatetime
	from #nt_st_deals d
	left outer join nt_st_chart c on c.idn=d.idn_chart

	


	---- ��������� ������������ ������ � ���������� �������
	--insert into nt_st_deals(idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer)
	--select					idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer
	--from #nt_st_deals
	--order by idn


END


