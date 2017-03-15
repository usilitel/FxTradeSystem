
	



select * from #nt_st_chart
select * from ntPeriodsData
select * from #ntAverageValuesResults
select * from nt_st_parameters_ParamsIdentifyersSets
select * from #nt_st_deals

p.limit_TakeProfit_isOk_AtOnce_up_AvgCnt 
p.limit_TakeProfit_isOk_AtOnce_down_AvgCnt 
p.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta


0,2666667	0,4



0,432	0,498	0,298

2016.06.02 05:00

-------------------------


--/*

--drop table #nt_st_deals2
--select * into #nt_st_deals2 from #nt_st_deals order by idn --where param_DealTimeInMinutesFirst = 300
--drop table #nt_st_deals


-- анализируем сделки
If object_ID('tempdb..#nt_st_deals2') Is not Null drop table #nt_st_deals2



select d.idn, 
	cf.idn as cf_idn, cl.idn as cl_idn, --cl.cdatetime as cl_cdatetime, 
	cf.cdatetime as cf_cdatetime, cl.cdatetime as cl_cdatetime, --cl.cdatetime as cl_cdatetime, 
	(select MIN(clow) from nt_st_chart where cdatetime >= cf.cdatetime and cdatetime <= cl.cdatetime) as clow_min,
	(select MAX(chigh) from nt_st_chart where cdatetime >= cf.cdatetime and cdatetime <= cl.cdatetime) as chigh_max,
	(select MIN(ABV) from nt_st_chart where cdatetime >= cf.cdatetime and cdatetime <= cl.cdatetime) as ABV_min,
	(select MAX(ABV) from nt_st_chart where cdatetime >= cf.cdatetime and cdatetime <= cl.cdatetime) as ABV_max,
	(select MIN(ABVMini) from nt_st_chart where cdatetime >= cf.cdatetime and cdatetime <= cl.cdatetime) as ABVMini_min,
	(select MAX(ABVMini) from nt_st_chart where cdatetime >= cf.cdatetime and cdatetime <= cl.cdatetime) as ABVMini_max,
	cl.ABV as cl_ABV,
	cl.ABVMini as cl_ABVMini,	
	d.deal_profit, 
	--cf.ctime as cf_ctime,
	cl.ctime as cl_ctime,
	left(cl.ctime,2) as cl_chour,
	right(cl.ctime,2) as cl_cminutes,
	v.CcorrMax, v.CcorrAvg,
	v.CcorrMax as StDev_cclose, v.CcorrMax as StDevP_cclose, v.CcorrMax as Var_cclose, v.CcorrMax as VarP_cclose,
	cl.Volume as Volume,
	d.deal_direction,
	d.deal_copen,
	param_DealTimeInMinutesFirst,
	v.CcorrMax as sum_cclose_up, v.CcorrMax as sum_cclose_down, v.CcorrMax as percent_cclose_UpDown
into #nt_st_deals2
from #nt_st_deals d with (nolock)
left outer join nt_st_chart cl with (nolock) on cl.idn = d.idn_chart and cl.ParamsIdentifyer = d.ParamsIdentifyer -- последняя запись на графике
left outer join ntAverageValuesResults v with (nolock) on v.idn = d.idn_AverageValues
left outer join nt_st_chart cf with (nolock) on cf.cdatetime = v.cdatetime_first and cf.copen = v.copen_first and cf.chigh = v.chigh_first and cf.clow = v.clow_first and cf.cclose = v.cclose_first -- первая запись на графике
	and cf.ParamsIdentifyer = d.ParamsIdentifyer
where 1=1
order by d.idn --(select MAX(chigh) from nt_st_chart where idn >= cf.idn and idn <= cl.idn) - (select MIN(clow) from nt_st_chart where idn >= cf.idn and idn <= cl.idn), d.idn






-- select * from #nt_st_deals2
-- select * from #nt_st_deals order by param_DealTimeInMinutesFirst
-- select * from nt_st_chart

----------------
-- select * from #nt_st_deals2



----------------
/*
declare @idn int, @cf_cdatetime varchar(16), @cl_cdatetime varchar(16)
declare @cclose_min real, @cclose_max real
--declare @chigh_max real, @clow_min real
declare @StDev_cclose real, @StDevP_cclose real, @Var_cclose real, @VarP_cclose real
declare @Volume int
declare @sum_cclose_up real, @sum_cclose_down real, @percent_cclose_UpDown real



-- делаем курсор по следкам для вычисдения дополнительных показателей
	DECLARE cDealsCursor CURSOR FOR
	-- выбираем все цены и рассчитанные общие показатели
	SELECT  idn, cf_cdatetime, cl_cdatetime
	from #nt_st_deals2
	order by idn


	OPEN cDealsCursor

	-- запоминаем все цены и рассчитанные общие показатели
	FETCH NEXT FROM cDealsCursor 
	INTO @idn, @cf_cdatetime, @cl_cdatetime
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- строим график цены с начала дня до сделки
		If object_ID('tempdb..#nt_st_DealChart') Is not Null drop table #nt_st_DealChart
		
		select *, cclose as cclose_changed, 
			cclose as sum_cclose_up, cclose as sum_cclose_down, cclose as percent_cclose_UpDown
		into #nt_st_DealChart
		from nt_st_chart with (nolock)
		where cdatetime >= @cf_cdatetime and cdatetime <= @cl_cdatetime
		order by cdatetime

--------------------
--	SELECT  idn, cf_cdatetime, cl_cdatetime
--	from #nt_st_deals2
--	order by idn
	
--select * from #nt_st_DealChart order by idn

--		select *, cclose as cclose_changed
--		--into #nt_st_DealChart
--		from nt_st_chart with (nolock)
--		where cdatetime >= '2015.06.11 00:00' and cdatetime <= '2014.04.15 01:00'
--		order by cdatetime
		
---------------------
		
		select @cclose_min = MIN(cclose) from #nt_st_DealChart
		select @cclose_max = MAX(cclose) from #nt_st_DealChart
		--select @clow_min = MIN(clow) from #nt_st_DealChart
		--select @chigh_max = MAX(chigh) from #nt_st_DealChart
		select @Volume = SUM(Volume)  from #nt_st_DealChart
		
		-- приводим cclose к диапазону от 0 до 1
		update #nt_st_DealChart set cclose_changed = (cclose-@cclose_min)*1.0/(@cclose_max-@cclose_min)

		-- считаем статистические показатели по графику цены текущей сделки
		select  @StDev_cclose = StDev(cclose_changed), 
				@StDevP_cclose = StDevP(cclose_changed), 
				@Var_cclose = Var(cclose_changed), 
				@VarP_cclose = VarP(cclose_changed)
		from #nt_st_DealChart
		
		select @sum_cclose_up   = sum(case when c1.cclose > c2.cclose then (c1.cclose - c2.cclose) else 0 end), -- as sum_cclose_up,
			   @sum_cclose_down = sum(case when c1.cclose < c2.cclose then (c2.cclose - c1.cclose) else 0 end) --  as sum_cclose_down
		from #nt_st_DealChart c1
		left outer join nt_st_chart c2 on c2.idn = c1.idn - 1 -- предыдущий бар
		where c2.idn is not null	
		
		select @percent_cclose_UpDown = case when @sum_cclose_up >= @sum_cclose_down then @sum_cclose_up/@sum_cclose_down else @sum_cclose_down/@sum_cclose_up end
		
		update #nt_st_deals2
		set StDev_cclose = @StDev_cclose, 
			StDevP_cclose = @StDevP_cclose, 
			Var_cclose = @Var_cclose, 
			VarP_cclose = @VarP_cclose,
			Volume = @Volume,
			sum_cclose_up = @sum_cclose_up,
			sum_cclose_down = @sum_cclose_down,			
			percent_cclose_UpDown = @percent_cclose_UpDown
		where idn = @idn
		
		 --select * from #nt_st_DealChart order by idn

	FETCH NEXT FROM cDealsCursor 
	INTO @idn, @cf_cdatetime, @cl_cdatetime
	END 

	CLOSE cDealsCursor;
	DEALLOCATE cDealsCursor;
*/

-- select * from #nt_st_deals2
-- select * from nt_st_chart where cdatetime = '2015.11.30 11:40'


	


-- select * from ntAverageValuesResults_20140101_20160205_DeltaMinutesCalcCorr_30min

-- зависимость от положения и величины цены внутри дня
SET DATEFORMAT ymd
select d.idn, cf_cdatetime, cl_cdatetime, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax,
	d.Volume as Volume_total,
	cl.Volume as Volume_last,
	d.deal_direction,
	d.deal_copen,
	(d.deal_copen - d.clow_min)/(d.chigh_max - d.clow_min) as deal_copen_DayPosition,
	case when deal_profit<0 then deal_profit else 0 end as Stoploss,
	case when deal_profit>0 then deal_profit else 0 end as Takeprofit,
	d.chigh_max - d.deal_copen as DeltaChighCopen,
	convert(real,(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min)) as deal_ABV_DayPosition,
	convert(real,(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min)) as deal_ABVMini_DayPosition,
	convert(real,(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min)-(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min)) as deal_ABV_ABVMini_DayPosition,
	percent_cclose_UpDown
	--v.TakeProfit_isOk_AtOnce_up_AvgCnt, 
	--v.TakeProfit_isOk_AtOnce_down_AvgCnt,
	--v.TakeProfit_isOk_AtOnce_up_AvgCnt - v.TakeProfit_isOk_AtOnce_down_AvgCnt
from #nt_st_deals2 d
left outer join nt_st_chart cl (nolock) on cl.cdatetime = d.cl_cdatetime
-- left outer join ntAverageValuesResults_20140101_20160205_DeltaMinutesCalcCorr_30min v on v.cdatetime_last = d.cl_cdatetime -- общие показатели с другими параметрами
where 1=1
	--and round((chigh_max - clow_min)*10000,0) <= 60 -- chart_range
	and substring(d.cl_cdatetime,12,2)='11' or substring(d.cl_cdatetime,12,2)='12' or substring(d.cl_cdatetime,12,2)='13'
	--and substring(d.cl_cdatetime,12,2)='09'-- or substring(d.cl_cdatetime,12,2)='12' or substring(d.cl_cdatetime,12,2)='13'
order by 
	d.deal_direction,
	--(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min)-(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min), -- deal_ABV_ABVMini_DayPosition
	--(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min), -- deal_ABV_DayPosition
	--(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min), -- deal_ABVMini_DayPosition
	(d.deal_copen - d.clow_min)/(d.chigh_max - d.clow_min), -- deal_copen_DayPosition
	--d.chigh_max - d.deal_copen, -- DeltaChighCopen
	1
		
	
/*


-- зависимость от положения ABV внутри дня
SET DATEFORMAT ymd
select d.idn, cf_cdatetime, cl_cdatetime, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax,
	d.Volume as Volume_total,
	cl.Volume as Volume_last,
	d.deal_direction,
	d.deal_copen,
	(d.deal_copen - d.clow_min)/(d.chigh_max - d.clow_min) as deal_copen_DayPosition,
	case when deal_profit<0 then deal_profit else 0 end as Stoploss,
	case when deal_profit>0 then deal_profit else 0 end as Takeprofit,
	d.chigh_max - d.deal_copen as DeltaChighCopen,
	convert(real,(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min)) as deal_ABV_DayPosition,
	convert(real,(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min)) as deal_ABVMini_DayPosition,
	convert(real,(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min)-(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min)) as deal_ABV_ABVMini_DayPosition
from #nt_st_deals2 d
left outer join nt_st_chart cl (nolock) on cl.cdatetime = d.cl_cdatetime
where substring(d.cl_cdatetime,12,2)='11' or substring(d.cl_cdatetime,12,2)='12' or substring(d.cl_cdatetime,12,2)='13'
order by 
	d.deal_direction,
	(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min)-(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min), -- deal_ABV_ABVMini_DayPosition
	--(d.cl_ABV - d.ABV_min)*1.0/(d.ABV_max - d.ABV_min), -- deal_ABV_DayPosition
	--(d.cl_ABVMini - d.ABVMini_min)*1.0/(d.ABVMini_max - d.ABVMini_min), -- deal_ABVMini_DayPosition
	(d.deal_copen - d.clow_min)/(d.chigh_max - d.clow_min), -- deal_copen_DayPosition
	d.chigh_max - d.deal_copen -- DeltaChighCopen




-- зависимость от часа дня и минут
SET DATEFORMAT ymd
select d.idn, cf_cdatetime, cl_cdatetime, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax,
	d.Volume as Volume_total,
	cl.Volume as Volume_last,
	d.deal_direction,
	d.deal_copen,
	(d.deal_copen - d.clow_min)/(d.chigh_max - d.clow_min) as deal_copen_DayPosition
from #nt_st_deals2 d
left outer join nt_st_chart cl on cl.cdatetime = d.cl_cdatetime
--where d.idn>=190 and d.idn<=220
order by --d.cl_cdatetime --cl.Volume,
	--DATEPART(dw,cl.cdate),
	cl_chour,
	cl_cminutes,
	chigh_max - clow_min, 
	--CcorrMax 
	VarP_cclose
	--chigh_max - clow_min
	
	
	
	--cl.Volume,
	--DATEPART(dw,cl.cdate),
	cl_chour,
	cl_cminutes,
	chigh_max - clow_min, 
	--CcorrMax 
	VarP_cclose
	--chigh_max - clow_min
	
	
	
	

clow_min	chigh_max		deal_copen
1,1262	1,1288	26	-23	11	00	0,2584379	0,2573678	0,06679016	0,06623817	2015.02.27	5	0,8756315	24402	308	1	1,1283


-- зависимость от статистических показателей (разброса)
select d.idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax,
	d.Volume as Volume_total,
	cl.Volume as Volume_last
from #nt_st_deals d
left outer join nt_st_chart cl on cl.idn = d.cl_idn
order by --cl.Volume,
	--DATEPART(dw,cl.cdate),
	--cl_chour,
	--cl_cminutes,
	--chigh_max - clow_min, 
	--CcorrMax 
	VarP_cclose
	--chigh_max - clow_min



-- зависимость от диапазона и статистических показателей (разброса)
select d.idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	--round((chigh_max - clow_min)*10000,0) as chart_range,
	round((chigh_max - clow_min)*10,2) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax,
	d.Volume as Volume_total,
	cl.Volume as Volume_last
from #nt_st_deals d
left outer join nt_st_chart cl on cl.idn = d.cl_idn
order by --cl.Volume,
	--DATEPART(dw,cl.cdate),
	--cl_chour,
	--cl_cminutes,
	--chigh_max - clow_min, 
	--CcorrMax 
	round((chigh_max - clow_min)*10,2),
	VarP_cclose
	--chigh_max - clow_min


SET DATEFORMAT ymd

-- зависимость от дня недели
select d.idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax
from #nt_st_deals d
left outer join nt_st_chart cl on cl.idn = d.cl_idn
order by DATEPART(dw,cl.cdate),
	cl_chour,
	cl_cminutes,
	chigh_max - clow_min, 
	--CcorrMax 
	VarP_cclose
	--chigh_max - clow_min


-- зависимость от объемов
select d.idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	StDev_cclose,
	StDevP_cclose,
	Var_cclose,
	VarP_cclose,
	cl.cdate,
	DATEPART(dw,cl.cdate) as day_of_week,
	CcorrMax,
	d.Volume as Volume_total,
	cl.Volume as Volume_last
from #nt_st_deals d
left outer join nt_st_chart cl on cl.idn = d.cl_idn
order by cl.Volume,
	DATEPART(dw,cl.cdate),
	cl_chour,
	cl_cminutes,
	chigh_max - clow_min, 
	--CcorrMax 
	VarP_cclose
	--chigh_max - clow_min

*/


