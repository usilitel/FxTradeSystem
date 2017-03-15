

-- создаем процедуру для перебора параметров расчета ОП
-- drop PROCEDURE ntpCorrResultsAverageValuesParamRanges
alter PROCEDURE ntpCorrResultsAverageValuesParamRanges (
	-- входные параметры
	@pParamsIdentifyer VARCHAR(50)
)
AS BEGIN 
-- процедура для перебора параметров расчета ОП

-- условия для расчета: 
-- 1) таблица ntCorrResultsReport д.б. уже заполнена
-- 2) таблица ntImportCurrent д.б. заполнена (нужны только 1-я и последняя записи)

-- результат: 
-- в цикле запускается процедура ntpCorrResultsAverageValues с перебором параметров

	SET NOCOUNT ON


	-- параметры, по которым происходит перебор
	declare
	-- количество похожих графиков, которые берем для анализа
	@cntCharts int,
	@cntCharts_first int,
	@cntCharts_last int,
	@cntCharts_step int,
	-- StopLoss в пунктах (в текущих ценах)
	@StopLoss int, 
	@StopLoss_first int, 
	@StopLoss_last int, 
	@StopLoss_step int, 
	-- TakeProfit в пунктах (в текущих ценах)
	@TakeProfit int, 
	@TakeProfit_first int, 
	@TakeProfit_last int, 
	@TakeProfit_step int, 	
	-- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
	@isCalcAverageValuesInPercents int, 
	@isCalcAverageValuesInPercents_first int, 
	@isCalcAverageValuesInPercents_last int, 
	@isCalcAverageValuesInPercents_step int, 
	-- минимальное количество баров, которое может быть в торговом дне
	@CntBarsMinLimit integer, 
	@CntBarsMinLimit_first integer, 
	@CntBarsMinLimit_last integer, 
	@CntBarsMinLimit_step integer, 
	-- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
	@DeltaCcloseRangeMaxLimit real, 
	@DeltaCcloseRangeMaxLimit_first real, 
	@DeltaCcloseRangeMaxLimit_last real, 
	@DeltaCcloseRangeMaxLimit_step real, 
	-- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
	@DeltaCcloseRangeMinLimit real, 
	@DeltaCcloseRangeMinLimit_first real, 
	@DeltaCcloseRangeMinLimit_last real, 
	@DeltaCcloseRangeMinLimit_step real, 
	-- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
	@IsCalcCorrOnlyForSameTime int, 
	@IsCalcCorrOnlyForSameTime_first int, 
	@IsCalcCorrOnlyForSameTime_last int, 
	@IsCalcCorrOnlyForSameTime_step int, 
	-- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
	@DeltaMinutesCalcCorr int, 
	@DeltaMinutesCalcCorr_first int, 
	@DeltaMinutesCalcCorr_last int, 
	@DeltaMinutesCalcCorr_step int


	-- параметры, по которым нет перебора
	declare
	@OnePoint real, -- значение одного пункта в цене
	@CurrencyId_current	int, -- CurrencyId валюты текущих данных
	@CurrencyId_history	int, -- CurrencyId валюты исторических данных (с которыми сравниваем)
	@DataSourceId	int,
	@PeriodMinutes int,
	@CntBarsCalcCorr int, -- количество баров, по которым считать К (0 - задается начальная дата-время)
	@ctime_CalcAverageValuesWithNextDay varchar(5), -- время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
	@CalcCorrParamsId varchar(20) -- идентификатор параметров расчета К	
	
	declare @cntBarsCurrent int
	declare @clowMinCurrent real, @chighMaxCurrent real, @DeltaCcloseRangeCurrent real
	
	declare @ParamsIdentifyerWithChangedParams VARCHAR(50) -- ParamsIdentifyer с измененными параметрами
	
	declare @DeltaMinutesCalcCorr_plus int
	
	
	If object_ID('tempdb..#ntImportCurrent') Is not Null drop table #ntImportCurrent
	
	select top 1 0 as idn, cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer
	into #ntImportCurrent
	from ntImportCurrent

	truncate table #ntImportCurrent
	
	/*
	CREATE TABLE #ntImportCurrent(
		idn int, -- identity(1,1),
		[cdate] [varchar](10),
		[ctime] [varchar](5),
		[copen] [real],
		[chigh] [real],
		[clow] [real],
		[cclose] [real],
		ParamsIdentifyer VARCHAR(50) NULL,
		cdatetime_log datetime
	) 
	*/
	
	
	-- временная таблица для упорядочивания idn записей из таблицы ntCorrResultsReport (нужна для того, чтобы убрать разрывы в idn)
	If object_ID('tempdb..#ntCorrResultsReport') Is not Null drop table #ntCorrResultsReport
	
	
	
	
	CREATE TABLE #ntCorrResultsReport(
		[idn_temp] int identity(1,1),
		[idn] int,
		[idnData] [int] NULL,
		[cdate] [varchar](10) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
		[ctime] [varchar](5) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL,
		[deltaMinutes] [int] NULL,
		[cperiod] [int] NULL,
		[ccorr] [real] NULL,
		[cperiodsAll] [varchar](50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL,
		[is_replaced] [int] NOT NULL,
		[deltaKmaxPercent] [real] NULL,
		[ccorrmax_replaced] [real] NULL,
		[cperiodMax_replaced] [int] NULL,
		[deltaMinutesMax_replaced] [int] NULL,
		[idnmax_replaced] [int] NULL,
		
		StopLoss real, -- StopLoss в пунктах
		TakeProfit real, -- TakeProfit в пунктах
			
		-- вычисляемые средние/суммарные показателей по всем похожим ситуациям (вычисляются в процедуре ntpCorrResultsAverageValues)
		cntBars_day int NULL, -- кол-во баров до конца дня
		-- (1)
		TakeProfit_isOk_Daily_up int NULL, -- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
		TakeProfit_isOk_Daily_down int NULL, -- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
		-- (2)
		TakeProfit_isOk_AtOnce_up int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
		TakeProfit_isOk_AtOnce_down int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
		-- (3)
		ChighMax_Daily int NULL, -- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		ClowMin_Daily int NULL, -- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		ChighMax_AtOnce int NULL, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		ClowMin_AtOnce int NULL, -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

		cntBars_day_nd int NULL, -- кол-во баров до конца дня
		-- (1)
		TakeProfit_isOk_Daily_up_nd int NULL, -- TakeProfit сработал до конца дня вверх (кол-во баров за уровнем TakeProfit)
		TakeProfit_isOk_Daily_down_nd int NULL, -- TakeProfit сработал до конца дня вниз (кол-во баров за уровнем TakeProfit)
		-- (2)
		TakeProfit_isOk_AtOnce_up_nd int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вверх (кол-во баров за уровнем TakeProfit)
		TakeProfit_isOk_AtOnce_down_nd int NULL, -- TakeProfit сработал сразу (без стоп-лосса) вниз (кол-во баров за уровнем TakeProfit)
		-- (3)
		ChighMax_Daily_nd int NULL, -- максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
		ClowMin_Daily_nd int NULL, -- максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
		-- (4)
		ChighMax_AtOnce_nd int NULL, -- максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
		ClowMin_AtOnce_nd int NULL, -- максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

		ParamsIdentifyer VARCHAR(50) NULL
	) ON [PRIMARY]
	CREATE UNIQUE CLUSTERED INDEX [idn0index] ON #ntCorrResultsReport 
	([idn_temp] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
	
	
		
	-- определяем границы параметров
	select 	
		-- параметры, по которым происходит перебор
		-- количество похожих графиков, которые берем для анализа
		@cntCharts_first = cntCharts,
		@cntCharts_last = cntCharts_last,
		@cntCharts_step = cntCharts_step,
		-- StopLoss в пунктах (в текущих ценах)
		@StopLoss_first = StopLoss, 
		@StopLoss_last = StopLoss_last, 
		@StopLoss_step = StopLoss_step, 
		-- TakeProfit в пунктах (в текущих ценах)
		@TakeProfit_first = TakeProfit, 
		@TakeProfit_last = TakeProfit_last, 
		@TakeProfit_step = TakeProfit_step, 	
		-- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
		@isCalcAverageValuesInPercents_first = isCalcAverageValuesInPercents, 
		@isCalcAverageValuesInPercents_last = isCalcAverageValuesInPercents_last, 
		@isCalcAverageValuesInPercents_step = isCalcAverageValuesInPercents_step, 
		-- минимальное количество баров, которое может быть в торговом дне
		@CntBarsMinLimit_first = CntBarsMinLimit, 
		@CntBarsMinLimit_last = CntBarsMinLimit_last, 
		@CntBarsMinLimit_step = CntBarsMinLimit_step, 
		-- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@DeltaCcloseRangeMaxLimit_first = DeltaCcloseRangeMaxLimit, 
		@DeltaCcloseRangeMaxLimit_last = DeltaCcloseRangeMaxLimit_last, 
		@DeltaCcloseRangeMaxLimit_step = DeltaCcloseRangeMaxLimit_step, 
		-- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@DeltaCcloseRangeMinLimit_first = DeltaCcloseRangeMinLimit, 
		@DeltaCcloseRangeMinLimit_last = DeltaCcloseRangeMinLimit_last, 
		@DeltaCcloseRangeMinLimit_step = DeltaCcloseRangeMinLimit_step, 
		-- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		@IsCalcCorrOnlyForSameTime_first = IsCalcCorrOnlyForSameTime, 
		@IsCalcCorrOnlyForSameTime_last = IsCalcCorrOnlyForSameTime_last, 
		@IsCalcCorrOnlyForSameTime_step = IsCalcCorrOnlyForSameTime_step, 
		-- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
		@DeltaMinutesCalcCorr_first = DeltaMinutesCalcCorr, 
		@DeltaMinutesCalcCorr_last = DeltaMinutesCalcCorr_last, 
		@DeltaMinutesCalcCorr_step = DeltaMinutesCalcCorr_step,
		
		-- параметры, по которым нет перебора
		@OnePoint = OnePoint, -- значение одного пункта в цене
		@CurrencyId_current	= CurrencyId_current, -- CurrencyId валюты текущих данных
		@CurrencyId_history	= CurrencyId_history, -- CurrencyId валюты исторических данных (с которыми сравниваем)
		@DataSourceId = DataSourceId,
		@PeriodMinutes = PeriodMinutes,
		@CntBarsCalcCorr = isnull(CntBarsCalcCorr,0), -- количество баров, по которым считать К (0 - задается начальная дата-время)
		@ctime_CalcAverageValuesWithNextDay = ctime_CalcAverageValuesWithNextDay, -- время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
		@CalcCorrParamsId = CalcCorrParamsId -- идентификатор параметров расчета К
	from ntSettingsFilesParameters_cn WITH(NOLOCK)
	where ParamsIdentifyer = @pParamsIdentifyer

/*
	select 			@cntCharts_first,		@cntCharts_last,		@cntCharts_step
	*/
	

	-- перебираем параметры
	select @cntCharts = @cntCharts_first
	WHILE @cntCharts <= @cntCharts_last
	begin
		select @StopLoss = @StopLoss_first
		WHILE @StopLoss <= @StopLoss_last
		begin
			select @TakeProfit = @TakeProfit_first
			WHILE @TakeProfit <= @TakeProfit_last
			begin			
				select @isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents_first
				WHILE @isCalcAverageValuesInPercents <= @isCalcAverageValuesInPercents_last
				begin
					select @CntBarsMinLimit = @CntBarsMinLimit_first
					WHILE @CntBarsMinLimit <= @CntBarsMinLimit_last
					begin
						select @DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit_first
						WHILE @DeltaCcloseRangeMaxLimit <= @DeltaCcloseRangeMaxLimit_last
						begin
							select @DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit_first
							WHILE @DeltaCcloseRangeMinLimit <= @DeltaCcloseRangeMinLimit_last
							begin
								select @IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime_first
								WHILE @IsCalcCorrOnlyForSameTime <= @IsCalcCorrOnlyForSameTime_last
								begin
									select @DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr_first 
									WHILE @DeltaMinutesCalcCorr >= @DeltaMinutesCalcCorr_last -- этот параметр уменьшаем
									begin
									
										
										
------------------------------------------------------------------------

	select @ParamsIdentifyerWithChangedParams = @pParamsIdentifyer


	If object_ID('tempdb..#ntCorrResultsReport1') Is not Null drop table #ntCorrResultsReport1

	select top 1 *
	into #ntCorrResultsReport1
	from ntCorrResultsReport
			
	truncate table #ntCorrResultsReport1
		
		
	-- если расчет делается не для первого набора параметров, то вычисляем ParamsIdentifyer с измененными параметрами
	if @cntCharts <> @cntCharts_first
		or @StopLoss <> @StopLoss_first
			or @TakeProfit <> @TakeProfit_first
				or @isCalcAverageValuesInPercents <> @isCalcAverageValuesInPercents_first
					or @CntBarsMinLimit <> @CntBarsMinLimit_first
						or @DeltaCcloseRangeMaxLimit <> @DeltaCcloseRangeMaxLimit_first
							or @DeltaCcloseRangeMinLimit <> @DeltaCcloseRangeMinLimit_first
								or @IsCalcCorrOnlyForSameTime <> @IsCalcCorrOnlyForSameTime_first
									or @DeltaMinutesCalcCorr <> @DeltaMinutesCalcCorr_first 
	begin
		select @ParamsIdentifyerWithChangedParams = p2.ParamsIdentifyer		
		from ntSettingsFilesParameters_cn p1 with (nolock)
		left outer join ntSettingsFilesParameters_cn p2 with (nolock) on -- совпадают параметры расчета общих показателей
			    p2.ctimefirst = p1.ctimefirst 
				and p2.cntCharts = @cntCharts 
				and p2.StopLoss = @StopLoss
				and p2.TakeProfit = @TakeProfit
			and p2.OnePoint = p1.OnePoint
			and p2.CurrencyId_current = p1.CurrencyId_current
			and p2.CurrencyId_history = p1.CurrencyId_history
			and p2.DataSourceId = p1.DataSourceId
			and p2.PeriodMinutes = p1.PeriodMinutes
				and p2.isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents
			and isnull(p2.CntBarsCalcCorr,0) = isnull(p1.CntBarsCalcCorr,0)
				  and p2.CntBarsMinLimit = @CntBarsMinLimit
				  and p2.DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit	  
				  and p2.DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit	  
				  and p2.IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime	  
				  and p2.DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr	  
			and p2.CalcCorrParamsId = p1.CalcCorrParamsId
			and p2.ctime_CalcAverageValuesWithNextDay = p1.ctime_CalcAverageValuesWithNextDay
		where p1.ParamsIdentifyer = @pParamsIdentifyer

		if @ParamsIdentifyerWithChangedParams is not null
		begin
			--delete from ntCorrResultsReport where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
			--delete from ntImportCurrent where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
	        
	        
	        
	        --If object_ID('tempdb..#ntImportCurrent') Is Null
				truncate table #ntImportCurrent
				
				insert into #ntImportCurrent (idn, cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer)
				select idn, cdate, ctime, copen, chigh, clow, cclose, @ParamsIdentifyerWithChangedParams as ParamsIdentifyer
				--into #ntImportCurrent
				from ntImportCurrent with (nolock)
				where ParamsIdentifyer = @pParamsIdentifyer
				order by idn

	        -- select * from ntImportCurrent
	        -- select * from ntCorrResultsReport
			
			--insert into ntImportCurrent (cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer)
			--select cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer
			--from #ntImportCurrent
			--order by idn
			
			select @DeltaMinutesCalcCorr_plus = @DeltaMinutesCalcCorr --+ @PeriodMinutes

			
			-- заполняем таблицу ntCorrResultsReport по нужному ParamsIdentifyer с нужным DeltaMinutes
			exec ntpCorrResultsReport @DeltaMinutesCalcCorr_plus, @pParamsIdentifyer, @ParamsIdentifyerWithChangedParams
		end
		


	
		-- если ParamsIdentifyer с такими параметрами не существует, то прекращаем расчет по этим параметрам
		if @ParamsIdentifyerWithChangedParams is null
			GOTO exit_step
	
	end
	
	
	
    --If object_ID('tempdb..#ntImportCurrent') Is Null
    if (select count(*) from #ntImportCurrent) = 0
		insert into #ntImportCurrent (idn, cdate, ctime, copen, chigh, clow, cclose, ParamsIdentifyer)
		select idn, cdate, ctime, copen, chigh, clow, cclose, @ParamsIdentifyerWithChangedParams as ParamsIdentifyer
		--into #ntImportCurrent
		from ntImportCurrent with (nolock)
		where ParamsIdentifyer = @pParamsIdentifyer
		order by idn






	If (select count(*) from #ntCorrResultsReport1) = 0
	begin
--		select 8, @pParamsIdentifyer, @ParamsIdentifyerWithChangedParams
		
		--select *
		--into #ntCorrResultsReport1
		--from ntCorrResultsReport WITH(NOLOCK)
		--where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
		--order by idn
		
		insert into #ntCorrResultsReport1 (
			[idnData] ,
			[cdate] ,
			[ctime] ,
			[deltaMinutes] ,
			[cperiod] ,
			[ccorr] ,
			[cperiodsAll] ,
			[is_replaced] ,
			[deltaKmaxPercent] ,
			[ccorrmax_replaced] ,
			[cperiodMax_replaced] ,
			[deltaMinutesMax_replaced] ,
			[idnmax_replaced] ,
			ParamsIdentifyer
		)
		select  
			[idnData] ,
			[cdate] ,
			[ctime] ,
			[deltaMinutes] ,
			[cperiod] ,
			[ccorr] ,
			[cperiodsAll] ,
			[is_replaced] ,
			[deltaKmaxPercent] ,
			[ccorrmax_replaced] ,
			[cperiodMax_replaced] ,
			[deltaMinutesMax_replaced] ,
			[idnmax_replaced] ,
			ParamsIdentifyer
		from ntCorrResultsReport
		where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
		order by idn
		
--		select 88, * from #ntCorrResultsReport1
				  		
	end







	-- временная таблица для хранения только нужных записей
	If object_ID('tempdb..#ntCorrResultsReport_temp') Is not Null drop table #ntCorrResultsReport_temp
	
	select *, convert(real,0) as chighmax, convert(real,0) as clowmin, convert(real,0) as DeltaCcloseRange
	into #ntCorrResultsReport_temp
	from #ntCorrResultsReport1 -- WITH(NOLOCK)
	--where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
	order by idn
	
--	select 7, * from #ntCorrResultsReport_temp
		
	-- если понадобится убирать данные со слишком большим диапазоном цены, то рассчитываем его
	if @DeltaCcloseRangeMinLimit <> 0 or @DeltaCcloseRangeMaxLimit <> 0
	begin
		select @cntBarsCurrent = count(*) from #ntImportCurrent --WITH(NOLOCK) where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
		select @clowMinCurrent = MIN(clow) from #ntImportCurrent --WITH(NOLOCK) where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
		select @chighMaxCurrent = MAX(chigh) from #ntImportCurrent --WITH(NOLOCK) where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
		select @DeltaCcloseRangeCurrent = @chighMaxCurrent - @clowMinCurrent

		If object_ID('tempdb..#ntCorrResultsReport_PriceRanges') Is not Null drop table #ntCorrResultsReport_PriceRanges

		-- вычисляем диапазон цен по историческим данным
		select r.idndata, min(d2.clow) as clowMin, max(d2.chigh) as chighMax
		into #ntCorrResultsReport_PriceRanges
		from #ntCorrResultsReport_temp r
		left outer join ntPeriodsData d1 WITH(NOLOCK index=idnindex) on d1.idn = r.idnData
		left outer join ntPeriodsData d2 WITH(NOLOCK index=index5) on 
						d2.idn > r.idnData-@cntBarsCurrent
					and d2.idn <= r.idnData
					and d2.CurrencyId = d1.CurrencyId
					and d2.DataSourceId = d1.DataSourceId
					and d2.PeriodMinutes = d1.PeriodMinutes
					and d2.PeriodMultiplicator = d1.PeriodMultiplicator
		group by r.idndata
		
		update r
		set r.clowMin = pr.clowMin, r.chighMax = pr.chighMax, r.DeltaCcloseRange = pr.chighMax - pr.clowMin
		from #ntCorrResultsReport_temp r
		left outer join #ntCorrResultsReport_PriceRanges pr on pr.idnData = r.idnData


	end
	
	



	
	-- убираем данные, выходящие за временные рамки (количество минут в ту и другую сторону относительно текущего бара)
	if @IsCalcCorrOnlyForSameTime = 1
		delete from #ntCorrResultsReport_temp where DeltaMinutes > @DeltaMinutesCalcCorr + cperiod


	-- убираем данные со слишком большим диапазоном цены
	if @DeltaCcloseRangeMinLimit <> 0
		delete from #ntCorrResultsReport_temp
		where DeltaCcloseRange < @DeltaCcloseRangeCurrent * @DeltaCcloseRangeMinLimit

	if @DeltaCcloseRangeMaxLimit <> 0
		delete from #ntCorrResultsReport_temp
		where DeltaCcloseRange > @DeltaCcloseRangeCurrent * @DeltaCcloseRangeMaxLimit


	

	-- если расчет делается не для первого набора параметров, то обновляем таблицу ntCorrResultsReport (т.к. потом по ней будум строить графики)
	-- не делать, т.к. это уже сделали в ХП ntpCorrResultsReport
	--if @ParamsIdentifyerWithChangedParams <> @pParamsIdentifyer
	--	insert into ntCorrResultsReport (idnData, cdate, ctime, deltaMinutes, cperiod, ccorr, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, idnmax_replaced, StopLoss, TakeProfit, cntBars_day, TakeProfit_isOk_Daily_up, TakeProfit_isOk_Daily_down, TakeProfit_isOk_AtOnce_up, TakeProfit_isOk_AtOnce_down, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce, ParamsIdentifyer, cntBars_day_nd, TakeProfit_isOk_Daily_up_nd, TakeProfit_isOk_Daily_down_nd, TakeProfit_isOk_AtOnce_up_nd, TakeProfit_isOk_AtOnce_down_nd, ChighMax_Daily_nd, ClowMin_Daily_nd, ChighMax_AtOnce_nd, ClowMin_AtOnce_nd)
	--	select idnData, cdate, ctime, deltaMinutes, cperiod, ccorr, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, idnmax_replaced, StopLoss, TakeProfit, cntBars_day, TakeProfit_isOk_Daily_up, TakeProfit_isOk_Daily_down, TakeProfit_isOk_AtOnce_up, TakeProfit_isOk_AtOnce_down, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce, @ParamsIdentifyerWithChangedParams, cntBars_day_nd, TakeProfit_isOk_Daily_up_nd, TakeProfit_isOk_Daily_down_nd, TakeProfit_isOk_AtOnce_up_nd, TakeProfit_isOk_AtOnce_down_nd, ChighMax_Daily_nd, ClowMin_Daily_nd, ChighMax_AtOnce_nd, ClowMin_AtOnce_nd 
	--	from #ntCorrResultsReport_temp
	--	order by (case when deltaMinutes <= @DeltaMinutesCalcCorr then 0 else 1 end),
	--		ccorr desc
	
	--select 2, * from #ntCorrResultsReport_temp
	
	truncate table #ntCorrResultsReport

	insert into #ntCorrResultsReport(idn, idnData, cdate, ctime, deltaMinutes, cperiod, ccorr, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, idnmax_replaced, StopLoss, TakeProfit, cntBars_day, TakeProfit_isOk_Daily_up, TakeProfit_isOk_Daily_down, TakeProfit_isOk_AtOnce_up, TakeProfit_isOk_AtOnce_down, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce, ParamsIdentifyer)
	select idn, idnData, cdate, ctime, deltaMinutes, cperiod, ccorr, cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, idnmax_replaced, StopLoss, TakeProfit, cntBars_day, TakeProfit_isOk_Daily_up, TakeProfit_isOk_Daily_down, TakeProfit_isOk_AtOnce_up, TakeProfit_isOk_AtOnce_down, ChighMax_Daily, ClowMin_Daily, ChighMax_AtOnce, ClowMin_AtOnce, ParamsIdentifyer
	--from ntCorrResultsReport WITH(NOLOCK)
	from #ntCorrResultsReport_temp
	--where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
	order by idn


--select 5, * from #ntCorrResultsReport
	delete from #ntCorrResultsReport where idn_temp > @cntCharts
--select 6, * from #ntCorrResultsReport
	
	
	--select * from #ntCorrResultsReport
	--select @cntCharts, @StopLoss, @TakeProfit, @isCalcAverageValuesInPercents, @CntBarsMinLimit, @DeltaCcloseRangeMaxLimit, @DeltaCcloseRangeMinLimit, @IsCalcCorrOnlyForSameTime, @DeltaMinutesCalcCorr
	
	
	--select @ParamsIdentifyerWithChangedParams, * from ntCorrResultsReport where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
	--select @ParamsIdentifyerWithChangedParams, * from ntImportCurrent where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams
	--select @ParamsIdentifyerWithChangedParams, * from #ntCorrResultsReport
	

	
	--insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select 'exec ntpCorrResultsAverageValues ' + convert(varchar,@cntCharts) + ' ' + isnull(@ParamsIdentifyerWithChangedParams,'null'), '', GETDATE(), 1

	exec ntpCorrResultsAverageValues 
	--select
	-- входные параметры
		@cntCharts , -- количество похожих графиков, которые берем для анализа
		@StopLoss , -- StopLoss в пунктах (в текущих ценах)
		@TakeProfit , -- TakeProfit в пунктах (в текущих ценах)
	@OnePoint , -- значение одного пункта в цене
	@CurrencyId_current	, -- CurrencyId валюты текущих данных
	@CurrencyId_history	, -- CurrencyId валюты исторических данных (с которыми сравниваем)
	@DataSourceId	,
	@PeriodMinutes ,
		@isCalcAverageValuesInPercents , -- 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах
	@ParamsIdentifyerWithChangedParams, --@pParamsIdentifyer ,	
	@CntBarsCalcCorr , -- количество баров, по которым считать К (0 - задается начальная дата-время)
	@ctime_CalcAverageValuesWithNextDay , -- время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
		@CntBarsMinLimit , -- минимальное количество баров, которое может быть в торговом дне
		@DeltaCcloseRangeMaxLimit , -- максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@DeltaCcloseRangeMinLimit , -- минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
		@IsCalcCorrOnlyForSameTime , -- 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
		@DeltaMinutesCalcCorr , -- количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
	@CalcCorrParamsId , -- идентификатор параметров расчета К	
	1 --@isTakeHistoryResultsFromTempTable int -- 1 = таблица #ntCorrResultsReport уже есть и заполнена, 0 = ее надо сделать и заполнить самому из постоянной таблицы

	--select @ParamsIdentifyerWithChangedParams, * from ntCorrResultsReport where ParamsIdentifyer = @ParamsIdentifyerWithChangedParams	
	--select 			@cntCharts_first,		@cntCharts_last,		@cntCharts_step


exit_step:
		
------------------------------------------------------------------------										
										
										set @DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr + @DeltaMinutesCalcCorr_step
									end
									set @DeltaMinutesCalcCorr = @DeltaMinutesCalcCorr - @DeltaMinutesCalcCorr_step
									set @IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime + @IsCalcCorrOnlyForSameTime_step
								end
								set @IsCalcCorrOnlyForSameTime = @IsCalcCorrOnlyForSameTime - @IsCalcCorrOnlyForSameTime_step
								set @DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit + @DeltaCcloseRangeMinLimit_step
							end
							set @DeltaCcloseRangeMinLimit = @DeltaCcloseRangeMinLimit - @DeltaCcloseRangeMinLimit_step
							set @DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit + @DeltaCcloseRangeMaxLimit_step
						end
						set @DeltaCcloseRangeMaxLimit = @DeltaCcloseRangeMaxLimit - @DeltaCcloseRangeMaxLimit_step
						set @CntBarsMinLimit = @CntBarsMinLimit + @CntBarsMinLimit_step
					end
					set @CntBarsMinLimit = @CntBarsMinLimit - @CntBarsMinLimit_step
					set @isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents + @isCalcAverageValuesInPercents_step
				end
				set @isCalcAverageValuesInPercents = @isCalcAverageValuesInPercents - @isCalcAverageValuesInPercents_step
				set @TakeProfit = @TakeProfit + @TakeProfit_step
			end
			set @TakeProfit = @TakeProfit - @TakeProfit_step
			set @StopLoss = @StopLoss + @StopLoss_step
		end
		set @StopLoss = @StopLoss - @StopLoss_step
		set @cntCharts = @cntCharts + @cntCharts_step
	end
	set @cntCharts = @cntCharts - @cntCharts_step

If object_ID('tempdb..#ntImportCurrent') Is not Null drop table #ntImportCurrent
	
END



-- go
-- exec ntpCorrResultsAverageValuesParamRanges '6E_5_v01_PA2'



