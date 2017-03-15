

alter PROCEDURE ntp_st_MakeDeals (
	-- ��������� ��������� ���� ��������� � ���������� ����������� �� ������� #nt_st_chart 
	-- � ���������� ����������� ������ � ������� nt_st_deals
	
	-- ������� #nt_st_chart ������ ���� ������� � ���������
	-- ������� #nt_st_deals ������ ���� �������
	
	
	-- ���������� ��� ���������� ������� ����
	--@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	--@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	@cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	-- ���������� ��� ������� ������
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	-- ������ ��������� ���������
	@param_StopLoss real, 
	@param_TakeProfit real, 
	@param_cntSignalsBeforeDeal int, -- ���������� �������� ������, ������ ��� ���������� ������
	@param_volume real,
	@param_DealTimeInMinutesFirst int, -- ����� � ������� �� 00:00, ������� � �������� ��������� ������
	@param_DealTimeInMinutesLast int   -- ����� � ������� �� 00:00, ���������� ������� ��������� ������
	
)
AS BEGIN 
-- ��������� ��� ���������� ������� tPeriodsData �������

SET NOCOUNT ON

	-- ���������� ���������� �� �������
	declare
	@c_idn int, @c_copen real, @c_chigh real, @c_clow real, @c_cclose real, @c_Volume int, @c_ABV real, @c_ABVMini real, @c_TimeInMinutes int,
	@v_CcorrMax real, @v_CcorrAvg real, @v_TakeProfit_isOk_Daily_up_AvgCnt real, @v_TakeProfit_isOk_Daily_down_AvgCnt real, @v_TakeProfit_isOk_Daily_up_PrcBars real, @v_TakeProfit_isOk_Daily_down_PrcBars real, @v_TakeProfit_isOk_AtOnce_up_AvgCnt real, @v_TakeProfit_isOk_AtOnce_down_AvgCnt real, @v_ChighMax_Daily_Avg real, @v_ClowMin_Daily_Avg real, @v_ChighMax_AtOnce_Avg real, @v_ClowMin_AtOnce_Avg real

	-- ��������������� ����������	
	declare 
	@is_DealActive int, -- 1 - ���� �������� ������� �������, 2 - ���� �������� �������� �������, 0 - ��� �������� �������
	@cntSignalsBefore int, -- ���������� �������� ������, ������� ���� �� �������� ������� (+ = ���������� �������� �� �������, - = ���������� �������� �� �������)
	@is_first_deal int,
	@idn_AverageValues int -- idn ������ �� ������� ntAverageValuesResults
	
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
			@deal_profit_total = 0,
			@is_first_deal = 1

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

-- select @c_idn, @is_DealActive, @c_chigh, @c_clow, @deal_TakeProfit

		-- ��������� �������� ������ �� StopLoss � TakeProfit
		if @is_DealActive = 1 and @c_chigh >= @deal_TakeProfit -- Buy, TakeProfit
			select 
			@deal_cclose = @deal_TakeProfit, -- ���� �������� ������
			@deal_profit = (@deal_TakeProfit - @deal_copen) * @param_volume -- ������� �� ������
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_TakeProfit - @deal_copen) * @param_volume) -- ����� ������� �� ���� �������

		if @is_DealActive = 1 and @c_clow <= @deal_StopLoss -- Buy, StopLoss
			select 
			@deal_cclose = @deal_StopLoss, -- ���� �������� ������
			@deal_profit = (@deal_StopLoss - @deal_copen) * @param_volume -- ������� �� ������
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_StopLoss - @deal_copen) * @param_volume) -- ����� ������� �� ���� �������

		if @is_DealActive = 2 and @c_clow <= @deal_TakeProfit -- Sell, TakeProfit
			select 
			@deal_cclose = @deal_TakeProfit, -- ���� �������� ������
			@deal_profit = (@deal_copen - @deal_TakeProfit) * @param_volume -- ������� �� ������
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_copen - @deal_TakeProfit) * @param_volume) -- ����� ������� �� ���� �������

		if @is_DealActive = 2 and @c_chigh >= @deal_StopLoss -- Sell, StopLoss
			select 
			@deal_cclose = @deal_StopLoss, -- ���� �������� ������
			@deal_profit = (@deal_copen- @deal_StopLoss) * @param_volume -- ������� �� ������
			--@deal_profit_total = isnull(@deal_profit_total,0) + ((@deal_copen- @deal_StopLoss) * @param_volume) -- ����� ������� �� ���� �������



-- if @c_idn >= 51240 select @c_idn, @c_chigh, @c_clow, @deal_StopLoss

		if @is_DealActive <> 0 and @deal_cclose is not null
		begin
			update #nt_st_deals
			set deal_cclose = @deal_cclose, -- ���� �������� ������
				deal_profit = round(@deal_profit,0), -- ������� �� ������
				deal_profit_total = round(case when @is_first_deal = 1 then @deal_profit else @deal_profit + isnull((select deal_profit_total from #nt_st_deals where idn = (select MAX(idn)-1 from #nt_st_deals)),0) end,0) -- ����� ������� �� ���� �������
			where idn = (select MAX(idn) from #nt_st_deals)
			
			select @is_DealActive = 0 -- ������� �������
			select @is_first_deal = 0
			
			

			--IF (@c_TimeInMinutes >= @param_DealTimeInMinutesLast) break -- ���� ������� ������ �� ��������� ������� ���������� ������ - �� ���������� ����
		end

		--IF ((@is_DealActive = 0) and (@c_TimeInMinutes > @param_DealTimeInMinutesLast)) break -- ���� ��� �������� ������� � ����� �� ������� ������� ���������� ������ - �� ���������� ����


		-- ��������� ������ �� �������
		if		@is_DealActive = 0
			and @v_TakeProfit_isOk_AtOnce_up_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			and (@v_TakeProfit_isOk_AtOnce_up_AvgCnt - @v_TakeProfit_isOk_AtOnce_down_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
			and @v_ChighMax_AtOnce_Avg >= @limit_ChighMax_AtOnce_Avg
			and (@v_ChighMax_AtOnce_Avg - @v_ClowMin_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
			and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
			and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
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
			and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
			and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
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
				ParamsIdentifyer
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
				@param_DealTimeInMinutesFirst, @param_DealTimeInMinutesLast,
				-- ��������� ������
				@deal_copen, -- ���� �������� ������
				@deal_direction, -- ����������� ������ (1=buy, 2=sell)
				@deal_StopLoss, -- StopLoss �� ������
				@deal_TakeProfit, -- TakeProfit �� ������
				@deal_volume,  -- ����� ������
				@ParamsIdentifyer
				--@deal_cclose, -- ���� �������� ������
				--@deal_profit, -- ������� �� ������
				--@deal_profit_total real -- ����� ������� �� ���� �������
				
				select @is_DealActive = @deal_direction

		end
		
		select @deal_direction = 0
		


	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes,
		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
		 @idn_AverageValues
	END 


	--exit_cursor:
	
	CLOSE cPriceCursor;
	DEALLOCATE cPriceCursor;

	-- ��������� ������������ ������ � ���������� �������
	insert into nt_st_deals(idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer)
	select					idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer
	from #nt_st_deals
	order by idn


END


