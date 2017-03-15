


--/*
-- создаем процедуру для заполнения таблицы ntCorrResultsPeriodsData (графики) данными
-- drop PROCEDURE ntpCorrResultsPeriodsData

alter PROCEDURE ntpCorrResultsPeriodsData (@pCountCharts int, @pbarsBefore int, @pbarsTotal int, @pDeltaMinutes int, @pParamsIdentifyer VARCHAR(50), @pCntBarsCalcCorr int)
AS BEGIN 
-- процедура для заполнения таблицы ntCorrResultsPeriodsData данными
-- @pCountCharts - сколько графиков строить
-- @pbarsBefore  - сколько баров в графике брать до текущего
-- @pbarsTotal   - сколько баров в графике брать всего
-- @pDeltaMinutes - максимальное отклонение в минутах, до которого история идет в первую очередь
SET NOCOUNT ON

DECLARE @idn int
DECLARE @Counter int
declare @CurrencyId int
declare @idnData_max int
declare @idnData_min int
declare @cntRows int
declare @i int

--truncate table [ntCorrResultsPeriodsData]
--delete from [ntCorrResultsPeriodsData] where ParamsIdentifyer = @pParamsIdentifyer
delete from [ntCorrResultsPeriodsData_DataChart] where ParamsIdentifyer = @pParamsIdentifyer
delete from [ntCorrResultsPeriodsData_DataTotal] where ParamsIdentifyer = @pParamsIdentifyer

SET @Counter = 0

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select '111', @pParamsIdentifyer, GETDATE(), 111


	If object_ID('tempdb..#ntCorrResultsPeriodsData_DataChart_copy') Is not Null drop table #ntCorrResultsPeriodsData_DataChart_copy
	If object_ID('tempdb..#ntCorrResultsPeriodsData_DataTotal_copy') Is not Null drop table #ntCorrResultsPeriodsData_DataTotal_copy

	-- делаем копии таблиц (сначала заполним их, а потом разом перебросим в постоянные)
	select top 1 *
	into #ntCorrResultsPeriodsData_DataChart_copy
	from ntCorrResultsPeriodsData_DataChart

	select top 1 *
	into #ntCorrResultsPeriodsData_DataTotal_copy
	from ntCorrResultsPeriodsData_DataTotal
	
	truncate table #ntCorrResultsPeriodsData_DataChart_copy
	truncate table #ntCorrResultsPeriodsData_DataTotal_copy
	
	
	
	
DECLARE cCorrResultsReport CURSOR FOR
SELECT idnData
FROM ntCorrResultsReport r with (nolock)
where r.ParamsIdentifyer = @pParamsIdentifyer
order by (case when r.deltaMinutes <= @pDeltaMinutes then 0 else 1 end),
          r.ccorr desc

OPEN cCorrResultsReport

FETCH NEXT FROM cCorrResultsReport 
INTO @idn
WHILE @@FETCH_STATUS = 0
BEGIN

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 112

	--If object_ID('tempdb..#ntCorrResultsPeriodsData_temp') Is not Null drop table #ntCorrResultsPeriodsData_temp
	If object_ID('tempdb..#ntCorrResultsPeriodsData_DataChart_temp') Is not Null drop table #ntCorrResultsPeriodsData_DataChart_temp
	If object_ID('tempdb..#ntCorrResultsPeriodsData_DataTotal_temp') Is not Null drop table #ntCorrResultsPeriodsData_DataTotal_temp






	-- вычисляем нужный нам CurrencyId
	IF @Counter = 0 select @CurrencyId = pd.CurrencyId 
					from ntCorrResultsReport r with (nolock)
					left outer join ntPeriodsData pd with (nolock) on pd.idn = @idn
					where r.ParamsIdentifyer = @pParamsIdentifyer 
						and r.idnData = @idn
					order by pd.idn

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 113



-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 114


	select 
		pd.idn as idnData,
		pd.cdate, 
		pd.ctime, 
		pd.cdate + ' ' + pd.ctime as cdatetime, 
		pd.copen, 
		pd.chigh, 
		pd.clow, 
		pd.cclose, 
		--r.cperiod as cperiodResult, 
		--r.cdate as cdateResult, 
		--r.ctime as ctimeResult, 
		--r.deltaMinutes as deltaMinutesResult, 
		--r.ccorr as ccorrResult, 
		--r.cperiodsAll, 
		--r.is_replaced, 
		--r.deltaKmaxPercent, 
		--r.ccorrmax_replaced, 
		--r.cperiodMax_replaced, 
		--r.deltaMinutesMax_replaced,
		pd.Volume, pd.ABV, pd.ABVMini, pd.ABMmPosition0_M5 as ABMmPosition0, pd.ABMmPosition1_M5 as ABMmPosition1,
		pd.CurrencyId,
		pd.BSV, pd.BSVMini
	into #ntCorrResultsPeriodsData_DataChart_temp
	from ntCorrResultsReport r with (nolock)
	left outer join ntPeriodsData pd with (nolock index=idnindex) on pd.idn >= (@idn-@pbarsBefore+1) 
								    and pd.idn <= (@idn+@pbarsTotal-@pbarsBefore)
	where r.ParamsIdentifyer = @pParamsIdentifyer
		and r.idnData = @idn
	--  and pd.CurrencyId = @CurrencyId -- берем только нужный CurrencyId
	order by pd.idn


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 115

--select 1, * from #ntCorrResultsPeriodsData_DataTotal_temp
	
	select 
		r.cperiod as cperiodResult, 
		r.cdate as cdateResult, 
		r.ctime as ctimeResult, 
		r.deltaMinutes as deltaMinutesResult, 
		r.ccorr as ccorrResult, 
		r.cperiodsAll, 
		r.is_replaced, 
		r.deltaKmaxPercent, 
		r.ccorrmax_replaced, 
		r.cperiodMax_replaced, 
		r.deltaMinutesMax_replaced
	into #ntCorrResultsPeriodsData_DataTotal_temp
	from ntCorrResultsReport r with (nolock)
	where r.ParamsIdentifyer = @pParamsIdentifyer
		and r.idnData = @idn

--select 2, @pParamsIdentifyer, @idn, * from #ntCorrResultsPeriodsData_DataTotal_temp

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 116

	-- если взяли данные из самого конца таблицы ntPeriodsData (не хватает строк для  графика), то добавляем строки (чтобы не было разрыва на графике)
	--select @idnData_max = MAX(idnData) from #ntCorrResultsPeriodsData_temp
	select @idnData_max = MAX(idnData) from #ntCorrResultsPeriodsData_DataChart_temp
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 117

	if @idnData_max < (@idn+@pbarsTotal-@pbarsBefore)
	begin
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 118

		select @cntRows = (@idn+@pbarsTotal-@pbarsBefore) - @idnData_max -- количество строк, которые нужно добавить в конец таблицы #ntCorrResultsPeriodsData_temp
		
		select @i=1
		WHILE @i<=@cntRows
		begin

			insert into #ntCorrResultsPeriodsData_DataChart_temp (
				idnData,
				cdate, 
				ctime, 
				cdatetime, 
				copen, 
				chigh, 
				clow, 
				cclose, 
				Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
				CurrencyId,
				BSV, BSVMini
				)
			select
				@idnData_max+1 as idnData,
				cdate, 
				ctime, 
				cdatetime, 
				cclose, 
				cclose, 
				cclose, 
				cclose, 
				Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
				CurrencyId,
				BSV, BSVMini
			from #ntCorrResultsPeriodsData_DataChart_temp
			where idnData = @idnData_max

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 119
						
			set @i = @i + 1
		end
	end


	-- если взяли данные из самого начала таблицы ntPeriodsData (не хватает строк для  графика), то добавляем строки (чтобы не было разрыва на графике)
	--select @idnData_min = MIN(idnData) from #ntCorrResultsPeriodsData_temp
	select @idnData_min = MIN(idnData) from #ntCorrResultsPeriodsData_DataChart_temp
	
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 120

	if @idnData_min > (@idn-@pbarsBefore+1)
	begin
	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 121

		select @cntRows = @idnData_min - (@idn-@pbarsBefore+1) -- количество строк, которые нужно добавить в начало таблицы #ntCorrResultsPeriodsData_temp
		
		select @i=1
		WHILE @i<=@cntRows
		begin

			
			insert into #ntCorrResultsPeriodsData_DataChart_temp (
				idnData,
				cdate, 
				ctime, 
				cdatetime, 
				copen, 
				chigh, 
				clow, 
				cclose, 
				Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
				CurrencyId,
				BSV, BSVMini
				)
			select
				@idnData_min-1 as idnData,
				cdate, 
				ctime, 
				cdatetime, 
				cclose, 
				cclose, 
				cclose, 
				cclose, 
				Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
				CurrencyId,
				BSV, BSVMini
			from #ntCorrResultsPeriodsData_DataChart_temp
			where idnData = @idnData_min			

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 122			
			
			set @i = @i + 1
		end
	end


		
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 123

	-- исправляем неверные записи в начале таблицы
	-- select *
	update t
	set t.copen = t1.copen, 
		t.chigh = t1.chigh,
		t.clow = t1.clow,
		t.cclose = t1.cclose,
		t.Volume = t1.Volume,
		t.ABV = t1.ABV,
		t.ABVMini = t1.ABVMini,
		t.ABMmPosition0 = t1.ABMmPosition0,
		t.ABMmPosition1 = t1.ABMmPosition1,
		t.BSV = t1.BSV,
		t.BSVMini = t1.BSVMini
	from #ntCorrResultsPeriodsData_DataChart_temp t
	left outer join #ntCorrResultsPeriodsData_DataChart_temp t1 on t1.idnData = (select MIN(idnData) from #ntCorrResultsPeriodsData_DataChart_temp where CurrencyId = @CurrencyId) -- первая запись с правильным CurrencyId
	where t.idnData < @idn
	  and t.CurrencyId <> @CurrencyId

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 124

	-- исправляем неверные записи в конце таблицы
	-- select *
	update t
	set t.copen = t1.copen, 
		t.chigh = t1.chigh,
		t.clow = t1.clow,
		t.cclose = t1.cclose,
		t.Volume = t1.Volume,
		t.ABV = t1.ABV,
		t.ABVMini = t1.ABVMini,
		t.ABMmPosition0 = t1.ABMmPosition0,
		t.ABMmPosition1 = t1.ABMmPosition1,
		t.BSV = t1.BSV,
		t.BSVMini = t1.BSVMini
	from #ntCorrResultsPeriodsData_DataChart_temp t
	left outer join #ntCorrResultsPeriodsData_DataChart_temp t1 on t1.idnData = (select Max(idnData) from #ntCorrResultsPeriodsData_DataChart_temp where CurrencyId = @CurrencyId) -- последняя запись с правильным CurrencyId
	where t.idnData > @idn
	  and t.CurrencyId <> @CurrencyId

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 125

	
--	insert into [ntCorrResultsPeriodsData_DataChart](
	insert into #ntCorrResultsPeriodsData_DataChart_copy(	
		[idnData],
		[cdate], 
		[ctime], 
		[cdatetime],
		[copen], 
		[chigh], 
		[clow], 
		[cclose], 
		Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
		ParamsIdentifyer, BSV, BSVMini)
	select 
		idnData,
		cdate, 
		ctime, 
		cdatetime, 
		copen, 
		chigh, 
		clow, 
		cclose, 
		Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
		@pParamsIdentifyer, BSV, BSVMini
	from #ntCorrResultsPeriodsData_DataChart_temp
	order by idnData


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 126
	
	--insert into [ntCorrResultsPeriodsData_DataTotal](
	insert into #ntCorrResultsPeriodsData_DataTotal_copy(
		cperiodResult, 
		cdateResult, 
		ctimeResult, 
		deltaMinutesResult, 
		ccorrResult, 
		[cperiodsAll], 
		[is_replaced], 
		[deltaKmaxPercent], 
		[ccorrmax_replaced], 
		[cperiodMax_replaced], 
		[deltaMinutesMax_replaced],
		ParamsIdentifyer)
	select 
		cperiodResult, 
		cdateResult, 
		ctimeResult, 
		deltaMinutesResult, 
		ccorrResult, 
		cperiodsAll, 
		is_replaced, 
		deltaKmaxPercent, 
		ccorrmax_replaced, 
		cperiodMax_replaced, 
		deltaMinutesMax_replaced,
		@pParamsIdentifyer
	from #ntCorrResultsPeriodsData_DataTotal_temp


	
-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 127	


	SET @Counter = @Counter + 1
    IF @Counter = @pCountCharts GOTO exit_cursor

    FETCH NEXT FROM cCorrResultsReport 
    INTO @idn
END 

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 128

exit_cursor:
CLOSE cCorrResultsReport;
DEALLOCATE cCorrResultsReport;


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 130

-- ставим отсечки в начале дня
update t1
set t1.chigh = t1.copen*(1+2.0/1000),
    t1.clow = t1.copen*(1-2.0/1000)
    --t1.is_changed = 1
from #ntCorrResultsPeriodsData_DataChart_copy t1 with (nolock)
left outer join #ntCorrResultsPeriodsData_DataChart_copy t2 with (nolock) on t2.idnData = t1.idnData-1
where t1.cdate <> t2.cdate

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 131	
	
-- ставим отсечки в нулевых барах
update t1
set t1.chigh = t1.copen*(1+2.0/1000),
    t1.clow = t1.copen*(1-2.0/1000)
    --t1.is_changed = 1
from #ntCorrResultsPeriodsData_DataChart_copy t1 with (nolock)
inner join ntCorrResultsReport r with (nolock) on r.ParamsIdentifyer = @pParamsIdentifyer
	and r.idnData = t1.idnData
--where t1.ParamsIdentifyer = @pParamsIdentifyer

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 132

-- select * from ntCorrResultsReport

-- ставим отсечки в барах начала расчета К
if @pCntBarsCalcCorr > 0
	update t2
	set t2.chigh = t2.copen*(1+2.0/1000),
		t2.clow = t2.copen*(1-2.0/1000)
		--t2.is_changed = 1
	from #ntCorrResultsPeriodsData_DataChart_copy t2 with (nolock)
	inner join #ntCorrResultsPeriodsData_DataChart_copy t1 with (nolock) on --t2.ParamsIdentifyer = t1.ParamsIdentifyer and 
		t2.idn = t1.idn - @pCntBarsCalcCorr + 1
	inner join ntCorrResultsReport r with (nolock) on r.ParamsIdentifyer = @pParamsIdentifyer
		and r.idnData = t1.idnData
--	where t1.ParamsIdentifyer = @pParamsIdentifyer

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 133







	-- вставляем данные в постоянные таблицы
	insert into [ntCorrResultsPeriodsData_DataChart](
		[idnData],
		[cdate], 
		[ctime], 
		[cdatetime],
		[copen], 
		[chigh], 
		[clow], 
		[cclose], 
		Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
		ParamsIdentifyer, BSV, BSVMini)
	select 
		idnData,
		cdate, 
		ctime, 
		cdatetime, 
		copen, 
		chigh, 
		clow, 
		cclose, 
		Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1,
		@pParamsIdentifyer, BSV, BSVMini
	from #ntCorrResultsPeriodsData_DataChart_copy
	order by idn


-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 134
	
	--select * from ntCorrResultsPeriodsData_DataTotal where ParamsIdentifyer = @pParamsIdentifyer
	
	insert into [ntCorrResultsPeriodsData_DataTotal](
		cperiodResult, 
		cdateResult, 
		ctimeResult, 
		deltaMinutesResult, 
		ccorrResult, 
		[cperiodsAll], 
		[is_replaced], 
		[deltaKmaxPercent], 
		[ccorrmax_replaced], 
		[cperiodMax_replaced], 
		[deltaMinutesMax_replaced],
		ParamsIdentifyer)
	select 
		cperiodResult, 
		cdateResult, 
		ctimeResult, 
		deltaMinutesResult, 
		ccorrResult, 
		cperiodsAll, 
		is_replaced, 
		deltaKmaxPercent, 
		ccorrmax_replaced, 
		cperiodMax_replaced, 
		deltaMinutesMax_replaced,
		@pParamsIdentifyer
	from #ntCorrResultsPeriodsData_DataTotal_copy
	order by idn
	
	--select * from ntCorrResultsPeriodsData_DataTotal where ParamsIdentifyer = @pParamsIdentifyer
	
	
	
	

-- insert into ntlog_ntCalendarIdnData (cname, ParamsIdentifyer, cdatetime_log, idnDataEventdates) select @idn, @pParamsIdentifyer, GETDATE(), 135


END


--go
--exec ntpCorrResultsPeriodsData 20,1000,1400,10000,'6E_5_v11_PA2',0
--select * from ntCorrResultsPeriodsData_DataTotal where ParamsIdentifyer = '6E_5_v01_PA2'

