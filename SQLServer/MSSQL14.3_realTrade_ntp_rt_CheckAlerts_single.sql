

alter PROCEDURE ntp_rt_CheckAlerts_single (
	-- проверяем условия для заключения сделки, заданные в таблице nt_rt_parameters_ParamsIdentifyersSets
	-- таблица #ntImportCurrentChartAverageValues должна быть заполнена	
	
		@activation_ParamsIdentifyer varchar(50), -- ParamsIdentifyer, который активирует проверку условий сделки
		@ParamsIdentifyersSetId int, -- id набора ParamsIdentifyer-ов из таблицы nt_rt_parameters_ParamsIdentifyersSets (по которому будет делаться расчет)
		-- параметры сделок
		--@StopLoss int, @TakeProfit int, @OnePoint real, --@ParamsIdentifyer VARCHAR(50),
		@param_cntSignalsBeforeDeal int, -- количество сигналов подряд, нужное для заключения сделки
		--@param_volume real,
		@param_IsOnlyOneActiveDeal int, -- 1 = только одна открытая позиция  в одну сторону (максимум один Buy и один Sell одновременно), 0 = неограниченное число открытых позиций (1 сигнал = 1 сделка)
		@param_IsOpenOppositeDeal int, -- 1 = если возникает противоположный сигнал - то закрываем все открытые позиции и открываем позицию по сигналу, 0 = закрываем позиции только по SL и TP
		@param_cntBuySignalsLimit_Start int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
		@param_cntSellSignalsLimit_Start int, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
		@param_cntBuySignalsLimit_Stop int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
		@param_cntSellSignalsLimit_Stop int, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего общего сигнала на ПОКУПКУ
		@result int Output -- возвращаемое значение: 0 - нет сигнала, 1 - сигнал на покупку, 2 - сигнал на продажу
)
AS BEGIN 

SET NOCOUNT ON




	
	-- вспомогательные переменные
	declare @cntBuySignals int -- количество сигналов на покупку
	declare @cntSellSignals int -- количество сигналов на продажу

		
	select @result = 0
	
	If object_ID('tempdb..#ntAverageValuesResults') Is not Null drop table #ntAverageValuesResults



	-- сначала из таблицы ntAverageValuesResults выбираем записи по нужным нам ParamsIdentifyer-ам по нужному бару
	select v.* 
	into #ntAverageValuesResults
	from #ntImportCurrentChartAverageValues c
	left outer join ntSettingsFilesParameters_cn fp on fp.ParamsIdentifyer = @activation_ParamsIdentifyer -- исходный ParamsIdentifyer (нужно для определения параметров расчета ОП)
	left outer join nt_rt_parameters_ParamsIdentifyersSets ps on -- нужные нам ParamsIdentifyer-ы
			ps.ParamsIdentifyersSetId = @ParamsIdentifyersSetId
		and ps.is_active = 1
	left outer join ntSettingsFilesParameters_cn fp2 on fp2.ParamsIdentifyer = ps.ParamsIdentifyer -- нужные нам ParamsIdentifyer-ы
	left outer join ntAverageValuesResults v on -- записи по нужным нам ParamsIdentifyer-ам по нужному бару
				v.cdatetime_last = c.cdatetime
			and v.copen_last = c.copen and v.chigh_last = c.chigh and v.clow_last = c.clow and v.cclose_last = c.cclose
			and v.ParamsIdentifyer = fp2.ParamsIdentifyer 



	--select * from #ntAverageValuesResults

	-- вычисляем количество сигналов на покупку
	select @cntBuySignals = count(*)
	from #ntAverageValuesResults vb
	left outer join nt_rt_parameters_ParamsIdentifyersSets p on -- нужные нам ParamsIdentifyer-ы
			p.ParamsIdentifyersSetId = @ParamsIdentifyersSetId
		and p.is_active = 1
		and p.ParamsIdentifyer = vb.ParamsIdentifyer
	where	(
			 vb.TakeProfit_isOk_AtOnce_up_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_AtOnce_up_AvgCnt-vb.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vb.TakeProfit_isOk_Daily_up_AvgCnt >= p.limit_TakeProfit_isOk_Daily_up_AvgCnt
			 )
		and
			abs(vb.TakeProfit_isOk_Daily_up_AvgCnt-vb.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta	
		and (
			 vb.ClowMin_AtOnce_Avg <= p.limit_ClowMin_AtOnce_Avg
			 )
		and
			abs(vb.ChighMax_AtOnce_Avg-vb.ClowMin_AtOnce_Avg) >= p.limit_ChighMax_ClowMin_AtOnce_Avg_delta	

	
	
	-- вычисляем количество сигналов на продажу
	select @cntSellSignals = count(*)
	from #ntAverageValuesResults vs
	left outer join nt_rt_parameters_ParamsIdentifyersSets p on -- нужные нам ParamsIdentifyer-ы
			p.ParamsIdentifyersSetId = @ParamsIdentifyersSetId
		and p.is_active = 1
		and p.ParamsIdentifyer = vs.ParamsIdentifyer
	where	(
			 vs.TakeProfit_isOk_AtOnce_down_AvgCnt >= p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_AtOnce_up_AvgCnt-vs.TakeProfit_isOk_AtOnce_down_AvgCnt) >= p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
		and (
			 vs.TakeProfit_isOk_Daily_down_AvgCnt >= p.limit_TakeProfit_isOk_Daily_down_AvgCnt
			 )
		and
			abs(vs.TakeProfit_isOk_Daily_up_AvgCnt-vs.TakeProfit_isOk_Daily_down_AvgCnt) >= p.limit_TakeProfit_isOk_Daily_up_down_AvgCnt_delta
		and (
			 vs.ChighMax_AtOnce_Avg <= p.limit_ClowMin_AtOnce_Avg
			 )
		and
			abs(vs.ChighMax_AtOnce_Avg-vs.ClowMin_AtOnce_Avg) >= p.limit_ChighMax_ClowMin_AtOnce_Avg_delta	


	-- проверяем, выполняются ли условия для заключения сделки
	select @result = 
		case when (
								@cntBuySignals >= @param_cntBuySignalsLimit_Start -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
								and
								@cntSellSignals <= @param_cntSellSignalsLimit_Stop -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для отмены общего сигнала на ПОКУПКУ
								)
			then 1
			when (
								@cntSellSignals >= @param_cntSellSignalsLimit_Start -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
								and
								@cntBuySignals <= @param_cntBuySignalsLimit_Stop -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для отмены общего сигнала на ПРОДАЖУ
								)
			then 2
			else 0
			end
			
			
			
				

/*

		@param_cntBuySignalsLimit_Start int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПОКУПКУ
		@param_cntSellSignalsLimit_Start int, -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего сигнала на ПРОДАЖУ
		@param_cntBuySignalsLimit_Stop int, -- количество сигналов на покупку по разным ParamsIdentifyer-ам, достаточных для ОТМЕНЫ общего сигнала на ПРОДАЖУ
		@param_cntSellSignalsLimit_Stop int -- количество сигналов на продажу по разным ParamsIdentifyer-ам, достаточных для общего общего сигнала на ПОКУПКУ

*/



END



