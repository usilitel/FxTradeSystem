

alter PROCEDURE ntp_st_MakeDealsAllDays_v03 (
	-- процедура прогоняет тест стратегии с указанными параметрами по таблице #nt_st_chart
	-- и записывает совершенные сделки в таблицу #nt_st_deals
	
	-- неверно: (параметры в зависимости от времени дня берутся из таблицы nt_st_parameters_TimeInMinutes)
	-- верно:    параметры берутся из таблицы nt_st_parameters_ParamsIdentifyersSets
	
	-- таблица #nt_st_chart должна быть создана и заполнена
	-- таблица #nt_st_deals должна быть создана
	-- таблица #ntAverageValuesResults должна быть создана и заполнена
	
	
	-- переменные для построения графика цены
	--@CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
	--@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16),
	--@cntCharts int, 
	@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
	-- переменные для расчета сделок
	--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	--@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	--@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	---- прочие параметры стратегии
	--@param_StopLoss real, 
	--@param_TakeProfit real, 
	@param_cntSignalsBeforeDeal int, -- количество сигналов подряд, нужное для заключения сделки
	@param_volume real,
	--@param_DealTimeInMinutesFirst int, -- время в минутах от 00:00, начиная с которого заключаем сделки
	--@param_DealTimeInMinutesLast int,   -- время в минутах от 00:00, заканчивая которым заключаем сделки
	@param_IsOnlyOneActiveDeal int, -- 1 = только одна открытая позиция, 0 = неограниченное число открытых позиций (но в рамках одного временного периода - только одна)
	@param_IsOpenOppositeDeal int, -- 1 = если возникает противоположный сигнал - то закрываем все открытые позиции и открываем позицию по сигналу, 0 = закрываем позиции только по SL и TP
	
	
	@ParamsIdentifyersSetId int,
	@param_cntBuySignalsLimit_Start int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
	@param_cntSellSignalsLimit_Start int, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
	@param_cntBuySignalsLimit_Stop int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
	@param_cntSellSignalsLimit_Stop int -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего общего сигнала на ПОКУПКУ



	
)
AS BEGIN 
-- процедура для заполнения таблицы tPeriodsData данными

SET NOCOUNT ON

	-- переменные выбираемые из курсора
	declare
	@c_idn int, @c_copen real, @c_chigh real, @c_clow real, @c_cclose real, @c_Volume int, @c_ABV real, @c_ABVMini real, @c_TimeInMinutes int,
	@v_CcorrMax real, @v_CcorrAvg real, @v_TakeProfit_isOk_Daily_up_AvgCnt real, @v_TakeProfit_isOk_Daily_down_AvgCnt real, @v_TakeProfit_isOk_Daily_up_PrcBars real, @v_TakeProfit_isOk_Daily_down_PrcBars real, @v_TakeProfit_isOk_AtOnce_up_AvgCnt real, @v_TakeProfit_isOk_AtOnce_down_AvgCnt real, @v_ChighMax_Daily_Avg real, @v_ClowMin_Daily_Avg real, @v_ChighMax_AtOnce_Avg real, @v_ClowMin_AtOnce_Avg real,

	-- переменные для расчета сделок
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real,
	-- прочие параметры стратегии
	@param_StopLoss real, 
	@param_TakeProfit real
--	@param_cntSignalsBeforeDeal int -- количество сигналов подряд, нужное для заключения сделки

	-- вспомогательные переменные	
	declare 
	@is_DealActive int, -- 1 - есть открытая длинная позиция, 2 - есть открытая короткая позиция, 0 - нет открытых позиций
	@cntSignalsBefore int, -- количество сигналов подряд, которые были до текущего момента (+ = количество сигналов на покупку, - = количество сигналов на продажу)
	--@is_first_deal int,
	@idn_AverageValues int, -- idn записи из таблицы ntAverageValuesResults
	@DealTimeInMinutesFirstCurrent int, -- текущее начало периода
	@DealTimeInMinutesLastCurrent int, -- текущий конец периода
	--@DealTimeInMinutesFirstPrevious int -- предыдущее начало периода (используется для определения перехода в следующий временной период)

	@cntBuySignals int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам
	@cntSellSignals int -- количество сигналов на продажу по разным ParamsIdentifyer-ам

	
	-- параметры сделки
	declare 
	@deal_copen real, -- цена открытия сделки
	@deal_direction int, -- направление сделки (1=buy, 2=sell)
	@deal_StopLoss real, -- StopLoss по сделке
	@deal_TakeProfit real, -- TakeProfit по сделке
	@deal_volume real, -- объем сделки
	@deal_cclose real, -- цена закрытия сделки
	@deal_profit real, -- прибыль по сделке
	@deal_profit_total real -- общая прибыль по всем сделкам
	


	-- начальное заполнение переменных
	select  @is_DealActive = 0,
			@cntSignalsBefore = 0,
			@deal_direction = 0,
			@deal_profit_total = 0
			

	truncate table #nt_st_deals








	If object_ID('tempdb..#t_cntBuySignals') Is not Null drop table #t_cntBuySignals
	If object_ID('tempdb..#t_cntSellSignals') Is not Null drop table #t_cntSellSignals


	-- вычисляем количество сигналов на покупку
	select  c.idn, 
			count(distinct vb.ParamsIdentifyer) as cntBuySignals
	into #t_cntBuySignals
	from #nt_st_chart c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.ParamsIdentifyersSetId = 1
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
	group by c.idn
	order by c.idn


	-- вычисляем количество сигналов на продажу
	select  c.idn, 
			count(distinct vs.ParamsIdentifyer) as cntSellSignals
	into #t_cntSellSignals
	from #nt_st_chart c
	left outer join nt_st_parameters_ParamsIdentifyersSets p on p.ParamsIdentifyersSetId = 1
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
	group by c.idn
	order by c.idn

	-- запоминаем количество сигналов на покупку и на продажу
	update c
	set c.cntBuySignals = bs.cntBuySignals,
		c.cntSellSignals = ss.cntSellSignals
	from #nt_st_chart c
	left outer join #t_cntBuySignals bs on bs.idn = c.idn -- сигналы на продажу
	left outer join #t_cntSellSignals ss on ss.idn = c.idn -- сигналы на продажу
















	DECLARE cPriceCursor CURSOR LOCAL FORWARD_ONLY FAST_FORWARD READ_ONLY FOR
	-- выбираем все цены и рассчитанные общие показатели
	SELECT  idn, copen, chigh, clow, cclose, Volume, ABV, ABVMini, TimeInMinutes
			--CcorrMax, CcorrAvg, TakeProfit_isOk_Daily_up_AvgCnt, TakeProfit_isOk_Daily_down_AvgCnt, TakeProfit_isOk_Daily_up_PrcBars, TakeProfit_isOk_Daily_down_PrcBars, TakeProfit_isOk_AtOnce_up_AvgCnt, TakeProfit_isOk_AtOnce_down_AvgCnt, ChighMax_Daily_Avg, ClowMin_Daily_Avg, ChighMax_AtOnce_Avg, ClowMin_AtOnce_Avg,
			--idn_AverageValues
	from #nt_st_chart
	order by cdatetime


	OPEN cPriceCursor

	-- запоминаем все цены и рассчитанные общие показатели
	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes
--		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
--		 @idn_AverageValues
	WHILE @@FETCH_STATUS = 0
	BEGIN


/*
		-- сначала определяем параметры стратегии для текущего временного периода
		select 	
			--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
			@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = null, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = null, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = null, 
			--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
			@limit_ChighMax_AtOnce_Avg = null, @limit_ClowMin_AtOnce_Avg = null, @limit_ChighMax_ClowMin_AtOnce_Avg_delta = null,
			-- прочие параметры стратегии
			@param_StopLoss = null, 
			@param_TakeProfit = null, 
--			@param_cntSignalsBeforeDeal = null, -- количество сигналов подряд, нужное для заключения сделки
			@DealTimeInMinutesFirstCurrent = null,
			@DealTimeInMinutesLastCurrent = null
					
		select 	
			--@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
			@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = limit_TakeProfit_isOk_AtOnce_up_AvgCnt, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = limit_TakeProfit_isOk_AtOnce_down_AvgCnt, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
			--@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
			@limit_ChighMax_AtOnce_Avg = limit_ChighMax_AtOnce_Avg, @limit_ClowMin_AtOnce_Avg = limit_ClowMin_AtOnce_Avg, @limit_ChighMax_ClowMin_AtOnce_Avg_delta = limit_ChighMax_ClowMin_AtOnce_Avg_delta,
			-- прочие параметры стратегии
			@param_StopLoss = param_StopLoss, 
			@param_TakeProfit = param_TakeProfit, 
--			@param_cntSignalsBeforeDeal = param_cntSignalsBeforeDeal, -- количество сигналов подряд, нужное для заключения сделки
			@DealTimeInMinutesFirstCurrent = param_DealTimeInMinutesFirst,
			@DealTimeInMinutesLastCurrent = param_DealTimeInMinutesLast
		from nt_st_parameters_TimeInMinutes
		where is_active = 1
		  and param_DealTimeInMinutesFirst <= @c_TimeInMinutes
		  and param_DealTimeInMinutesLast >= @c_TimeInMinutes
*/

		-- сначала определяем параметры стратегии для текущего временного периода
		select 	
			--@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = null, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt = null, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = null, 
			--@limit_ChighMax_AtOnce_Avg = null, @limit_ClowMin_AtOnce_Avg = null, @limit_ChighMax_ClowMin_AtOnce_Avg_delta = null,
			-- прочие параметры стратегии
			@param_StopLoss = @StopLoss, 
			@param_TakeProfit = @TakeProfit 
--			@param_cntSignalsBeforeDeal = null, -- количество сигналов подряд, нужное для заключения сделки
			--@DealTimeInMinutesFirstCurrent = null,
			--@DealTimeInMinutesLastCurrent = null
			


-- select 111, @c_idn as c_idn, 0, @c_chigh as c_chigh, @c_clow as c_clow, * from #nt_st_deals



		-- вычисляем закрытие сделки по StopLoss и TakeProfit
		update #nt_st_deals
		set deal_cclose = deal_TakeProfit -- цена закрытия сделки
		where deal_direction = 1 -- Buy, TakeProfit
		  and @c_chigh >= deal_TakeProfit			
		  and deal_cclose is null -- сделка еще не закрыта
			
		update #nt_st_deals
		set deal_cclose = deal_StopLoss -- цена закрытия сделки
		where deal_direction = 1 -- Buy, StopLoss
		  and @c_clow <= deal_StopLoss
		  and deal_cclose is null -- сделка еще не закрыта
			
		update #nt_st_deals
		set deal_cclose = deal_TakeProfit -- цена закрытия сделки
		where deal_direction = 2 -- Sell, TakeProfit
		  and @c_clow <= deal_TakeProfit
		  and deal_cclose is null -- сделка еще не закрыта
			
		update #nt_st_deals
		set deal_cclose = deal_StopLoss -- цена закрытия сделки
		where deal_direction = 2 -- Sell, StopLoss
		  and @c_chigh >= deal_StopLoss
		  and deal_cclose is null -- сделка еще не закрыта			
			




		--if @DealTimeInMinutesFirstCurrent is not null
		--begin
		
		
		/*
			if @param_IsOpenOppositeDeal = 1 -- 1 = если возникает противоположный сигнал - то закрываем все открытые позиции и открываем позицию по сигналу
			begin

				-- вычисляем сигнал на ПОКУПКУ
				if		--(@is_DealActive = 0 or @param_IsOpenOppositeDeal = 1)
						 @v_TakeProfit_isOk_AtOnce_up_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_up_AvgCnt
					and (@v_TakeProfit_isOk_AtOnce_up_AvgCnt - @v_TakeProfit_isOk_AtOnce_down_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
					and @v_ChighMax_AtOnce_Avg >= @limit_ChighMax_AtOnce_Avg
					and (@v_ChighMax_AtOnce_Avg - @v_ClowMin_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
					--and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
					--and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
				begin
					-- проверяем условия для открытия позиции на ПОКУПКУ
					-- if @is_DealActive = 0
					-- вычисляем параметры сделки
					select @deal_copen = @c_cclose, -- цена открытия сделки
						   @deal_direction = 1, -- направление сделки (1=buy, 2=sell)
						   @deal_StopLoss = @c_cclose - (@param_StopLoss * @OnePoint), -- StopLoss по сделке
						   @deal_TakeProfit = @c_cclose + (@param_TakeProfit * @OnePoint), -- TakeProfit по сделке
						   @deal_volume = @param_volume, -- объем сделки
						   @deal_cclose = null, -- цена закрытия сделки
						   @deal_profit = null, -- прибыль по сделке
						   @deal_profit_total = null, -- общая прибыль по всем сделкам
						   @cntSignalsBefore = (case when @cntSignalsBefore < 0 then 1 else @cntSignalsBefore + 1 end) -- увеличиваем счетчик сигналов
					--select 1, @idn_AverageValues, @v_ClowMin_AtOnce_Avg , @v_ChighMax_AtOnce_Avg , @limit_ChighMax_ClowMin_AtOnce_Avg_delta
				end
						
						
						
						
				-- вычисляем сигнал на ПРОДАЖУ
				if		--(@is_DealActive = 0 or @param_IsOpenOppositeDeal = 1)
						 @v_TakeProfit_isOk_AtOnce_down_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_down_AvgCnt
					and (@v_TakeProfit_isOk_AtOnce_down_AvgCnt - @v_TakeProfit_isOk_AtOnce_up_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
					and @v_ClowMin_AtOnce_Avg >= @limit_ClowMin_AtOnce_Avg
					and (@v_ClowMin_AtOnce_Avg - @v_ChighMax_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
					--and @c_TimeInMinutes >= @param_DealTimeInMinutesFirst
					--and @c_TimeInMinutes <= @param_DealTimeInMinutesLast
				begin
					-- проверяем условия для открытия позиции на ПРОДАЖУ
					-- if @is_DealActive = 0
					-- вычисляем параметры сделки
					select @deal_copen = @c_cclose, -- цена открытия сделки
						   @deal_direction = 2, -- направление сделки (1=buy, 2=sell)
						   @deal_StopLoss = @c_cclose + (@param_StopLoss * @OnePoint), -- StopLoss по сделке
						   @deal_TakeProfit = @c_cclose - (@param_TakeProfit * @OnePoint), -- TakeProfit по сделке
						   @deal_volume = @param_volume, -- объем сделки
						   @deal_cclose = null, -- цена закрытия сделки
						   @deal_profit = null, -- прибыль по сделке
						   @deal_profit_total = null, -- общая прибыль по всем сделкам
						   @cntSignalsBefore = (case when @cntSignalsBefore > 0 then -1 else @cntSignalsBefore - 1 end) -- увеличиваем счетчик сигналов
					--select 2, @idn_AverageValues, @v_ClowMin_AtOnce_Avg , @v_ChighMax_AtOnce_Avg , @limit_ChighMax_ClowMin_AtOnce_Avg_delta
				end
				
				if @deal_direction = 0 -- если нет сигнала ни на покупку, ни на продажу - то обнуляем счетчик сигналов
					select @cntSignalsBefore = 0 
					
			
				-- если возник сигнал на покупку - то закрываем все короткие позиции
				if @deal_direction = 1
					update #nt_st_deals
					set deal_cclose = @c_cclose
					where deal_direction = 2
					and deal_cclose is null -- сделка еще не закрыта
				
				-- если возник сигнал на продажу - то закрываем все длинные позиции
				if @deal_direction = 2
					update #nt_st_deals
					set deal_cclose = @c_cclose
					where deal_direction = 1
					and deal_cclose is null -- сделка еще не закрыта

				-- вычисляем, есть ли незакрытые сделки в текущем временном периоде
				if (select count(*)
					from #nt_st_deals
					where param_DealTimeInMinutesFirst = @DealTimeInMinutesFirstCurrent
					and deal_cclose is null -- сделка еще не закрыта
					) = 0
					select @is_DealActive = 0 -- все позиции в текущем временном периоде закрыты
				else
					select @is_DealActive = 1 -- есть незакрытые позиции в текущем временном периоде

			end
*/



			if @param_IsOpenOppositeDeal = 0 -- 0 = закрываем позиции только по SL и TP
			begin
		
				-- вычисляем, есть ли незакрытые сделки в текущем временном периоде
				if (select count(*)
					from #nt_st_deals
					where --param_DealTimeInMinutesFirst = @DealTimeInMinutesFirstCurrent
						deal_cclose is null -- сделка еще не закрыта
					) = 0
					select @is_DealActive = 0 -- все позиции в текущем временном периоде закрыты
				else
					select @is_DealActive = 1 -- есть незакрытые позиции в текущем временном периоде





-- select 111, @c_idn as c_idn, 1, @is_DealActive as is_DealActive


				-- проверяем условия для открытия позиций на ПОКУПКУ и на ПРОДАЖУ
				if		@is_DealActive = 0
				begin

					-- вычисляем количество сигналов на покупку по разным ParamsIdentifyer-ам
					select @cntBuySignals = cntBuySignals
					from #nt_st_chart c
					where   c.idn = @c_idn

					-- вычисляем количество сигналов на продажу по разным ParamsIdentifyer-ам
					select @cntSellSignals = cntSellSignals
					from #nt_st_chart c
					where   c.idn = @c_idn


					-- проверяем условия для открытия позиции на ПОКУПКУ
					if  @cntBuySignals >= @param_cntBuySignalsLimit_Start -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
						and
						@cntSellSignals <= @param_cntSellSignalsLimit_Stop -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего общего сигнала на ПОКУПКУ
					begin
						select @deal_copen = @c_cclose, -- цена открытия сделки
							   @deal_direction = 1, -- направление сделки (1=buy, 2=sell)
							   @deal_StopLoss = @c_cclose - (@param_StopLoss * @OnePoint), -- StopLoss по сделке
							   @deal_TakeProfit = @c_cclose + (@param_TakeProfit * @OnePoint), -- TakeProfit по сделке
							   @deal_volume = @param_volume, -- объем сделки
							   @deal_cclose = null, -- цена закрытия сделки
							   @deal_profit = null, -- прибыль по сделке
							   @deal_profit_total = null, -- общая прибыль по всем сделкам
							   @cntSignalsBefore = (case when @cntSignalsBefore < 0 then 1 else @cntSignalsBefore + 1 end) -- увеличиваем счетчик сигналов
-- select 111, @c_idn as c_idn, 2, @cntBuySignals as cntBuySignals, @c_cclose as c_cclose, @param_TakeProfit as param_TakeProfit, @OnePoint as OnePoint
					end

					-- проверяем условия для открытия позиции на ПРОДАЖУ
					if  @cntSellSignals >= @param_cntSellSignalsLimit_Start -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
						and
						@cntBuySignals <= @param_cntBuySignalsLimit_Stop -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
					begin
						select @deal_copen = @c_cclose, -- цена открытия сделки
							   @deal_direction = 2, -- направление сделки (1=buy, 2=sell)
							   @deal_StopLoss = @c_cclose + (@param_StopLoss * @OnePoint), -- StopLoss по сделке
							   @deal_TakeProfit = @c_cclose - (@param_TakeProfit * @OnePoint), -- TakeProfit по сделке
							   @deal_volume = @param_volume, -- объем сделки
							   @deal_cclose = null, -- цена закрытия сделки
							   @deal_profit = null, -- прибыль по сделке
							   @deal_profit_total = null, -- общая прибыль по всем сделкам
							   @cntSignalsBefore = (case when @cntSignalsBefore > 0 then -1 else @cntSignalsBefore - 1 end) -- увеличиваем счетчик сигналов
-- select 111, @c_idn as c_idn, 3, @cntSellSignals as cntSellSignals, @c_cclose as c_cclose, @param_TakeProfit as param_TakeProfit, @OnePoint as OnePoint
					end

				end



				
				if @deal_direction = 0 -- если нет сигнала ни на покупку, ни на продажу - то обнуляем счетчик сигналов
					select @cntSignalsBefore = 0 
			end
			
-- select 111, @c_idn as c_idn, 4, abs(@cntSignalsBefore) , @param_cntSignalsBeforeDeal

			-- открываем позицию
			if   @is_DealActive = 0
			  and @deal_direction <> 0 
			  and abs(@cntSignalsBefore) >= @param_cntSignalsBeforeDeal
			begin			
				insert into #nt_st_deals(
					idn_chart,
					idn_AverageValues,
					-- параметры расчета общих показателей
					StopLoss, TakeProfit, OnePoint, 
					-- параметры стратегии
					-- переменные для расчета сделок
					limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, 
					limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
					limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, 
					limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta,
					-- прочие параметры стратегии
					param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, 
					param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast,
					-- параметры сделки
					deal_copen, -- цена открытия сделки
					deal_direction, -- направление сделки (1=buy, 2=sell)
					deal_StopLoss, -- StopLoss по сделке
					deal_TakeProfit, -- TakeProfit по сделке
					deal_volume, -- объем сделки
					--ParamsIdentifyer,
					cdatetime
					--deal_cclose, -- цена закрытия сделки
					--deal_profit, -- прибыль по сделке
					--deal_profit_total -- общая прибыль по всем сделкам
					)
				select
					@c_idn,
					@idn_AverageValues,
					@StopLoss, @TakeProfit, @OnePoint, 
					-- переменные для расчета сделок
					@limit_CcorrMax, @limit_CcorrAvg, @limit_TakeProfit_isOk_Daily_up_AvgCnt, @limit_TakeProfit_isOk_Daily_down_AvgCnt, @limit_TakeProfit_isOk_Daily_up_PrcBars, @limit_TakeProfit_isOk_Daily_down_PrcBars, 
					@limit_TakeProfit_isOk_AtOnce_up_AvgCnt, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, 
					@limit_ChighMax_Daily_Avg, @limit_ClowMin_Daily_Avg, 
					@limit_ChighMax_AtOnce_Avg, @limit_ClowMin_AtOnce_Avg, @limit_ChighMax_ClowMin_AtOnce_Avg_delta,
					-- прочие параметры стратегии
					@param_StopLoss, 
					@param_TakeProfit, 
					@param_cntSignalsBeforeDeal, -- количество сигналов подряд, нужное для заключения сделки
					@param_volume, 
					@DealTimeInMinutesFirstCurrent, @DealTimeInMinutesLastCurrent,
					-- параметры сделки
					@deal_copen, -- цена открытия сделки
					@deal_direction, -- направление сделки (1=buy, 2=sell)
					@deal_StopLoss, -- StopLoss по сделке
					@deal_TakeProfit, -- TakeProfit по сделке
					@deal_volume,  -- объем сделки
					--@ParamsIdentifyer,
					space(16)
					--@deal_cclose, -- цена закрытия сделки
					--@deal_profit, -- прибыль по сделке
					--@deal_profit_total real -- общая прибыль по всем сделкам
					
					select @is_DealActive = @deal_direction
					--select @c_idn as idn_chart, @c_TimeInMinutes as TimeInMinutes, @DealTimeInMinutesFirstCurrent as DealTimeInMinutesFirstCurrent
			end				
		--end


		select @deal_direction = 0
		--select @DealTimeInMinutesFirstPrevious = @DealTimeInMinutesFirstCurrent
		


	FETCH NEXT FROM cPriceCursor 
	INTO @c_idn, @c_copen, @c_chigh, @c_clow, @c_cclose, @c_Volume, @c_ABV, @c_ABVMini, @c_TimeInMinutes
--		 @v_CcorrMax, @v_CcorrAvg, @v_TakeProfit_isOk_Daily_up_AvgCnt, @v_TakeProfit_isOk_Daily_down_AvgCnt, @v_TakeProfit_isOk_Daily_up_PrcBars, @v_TakeProfit_isOk_Daily_down_PrcBars, @v_TakeProfit_isOk_AtOnce_up_AvgCnt, @v_TakeProfit_isOk_AtOnce_down_AvgCnt, @v_ChighMax_Daily_Avg, @v_ClowMin_Daily_Avg, @v_ChighMax_AtOnce_Avg, @v_ClowMin_AtOnce_Avg,
--		 @idn_AverageValues
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

	


	---- вставляем рассчитанные данные в постоянную таблицу
	--insert into nt_st_deals(idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer)
	--select					idn_chart, cntCharts, StopLoss, TakeProfit, OnePoint, limit_CcorrMax, limit_CcorrAvg, limit_TakeProfit_isOk_Daily_up_AvgCnt, limit_TakeProfit_isOk_Daily_down_AvgCnt, limit_TakeProfit_isOk_Daily_up_PrcBars, limit_TakeProfit_isOk_Daily_down_PrcBars, limit_TakeProfit_isOk_AtOnce_up_AvgCnt, limit_TakeProfit_isOk_AtOnce_down_AvgCnt, limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta, limit_ChighMax_Daily_Avg, limit_ClowMin_Daily_Avg, limit_ChighMax_AtOnce_Avg, limit_ClowMin_AtOnce_Avg, limit_ChighMax_ClowMin_AtOnce_Avg_delta, param_StopLoss, param_TakeProfit, param_cntSignalsBeforeDeal, param_volume, param_DealTimeInMinutesFirst, param_DealTimeInMinutesLast, deal_copen, deal_direction, deal_StopLoss, deal_TakeProfit, deal_volume, deal_cclose, deal_profit, deal_profit_total, idn_AverageValues, ParamsIdentifyer
	--from #nt_st_deals
	--order by idn


END


