

-- тестер стратегий


select * from nt_st_chart
select * from nt_st_deals
select * from nt_st_parameters_TimeInMinutes

-- расчитываем общие результаты по стратегиям

-----------------------
-- убираем незавершенные сделки (чтобы не мешались)
select *
-- delete
from nt_st_deals 
where deal_cclose is null and deal_profit is null and deal_profit_total is null
-----------------------

-- truncate table nt_st_deals


If object_ID('tempdb..#nt_st_results') Is not Null drop table #nt_st_results

select 	round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) as limit_TakeProfit_isOk_AtOnce_up_AvgCnt,
		round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) as limit_TakeProfit_isOk_AtOnce_down_AvgCnt,
		limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,
		limit_ChighMax_AtOnce_Avg,
		limit_ClowMin_AtOnce_Avg,
		limit_ChighMax_ClowMin_AtOnce_Avg_delta,
		param_StopLoss,
		param_TakeProfit,
		param_cntSignalsBeforeDeal,
		param_DealTimeInMinutesFirst,
		param_DealTimeInMinutesLast,
		SUM(deal_profit) as deal_profit_total,
		SUM(case when deal_profit<0 then deal_profit else 0 end) as sum_StopLoss,
		SUM(case when deal_profit>0 then deal_profit else 0 end) as sum_TakeProfit,
		count(deal_profit) as cnt_deals,
		SUM(case when deal_profit<0 then 1 else 0 end) as cnt_StopLoss,
		SUM(case when deal_profit>0 then 1 else 0 end) as cnt_TakeProfit,
		SUM(case when deal_direction=1 then 1 else 0 end) as cnt_Buy,
		SUM(case when deal_direction=1 and deal_profit>0 then 1 else 0 end) as cnt_BuyTakeProfit,
		SUM(case when deal_direction=1 and deal_profit<0 then 1 else 0 end) as cnt_BuyStopLoss,
		SUM(case when deal_direction=2 then 1 else 0 end) as cnt_Sell,
		SUM(case when deal_direction=2 and deal_profit>0 then 1 else 0 end) as cnt_SellTakeProfit,
		SUM(case when deal_direction=2 and deal_profit<0 then 1 else 0 end) as cnt_SellStopLoss
into #nt_st_results
from nt_st_deals with (nolock)
--from nt_st_deals_v02__06_12 with (nolock)
where ParamsIdentifyer = '1_5_20150611'
  and param_DealTimeInMinutesFirst = (11*60)
group by limit_TakeProfit_isOk_AtOnce_up_AvgCnt,
		limit_TakeProfit_isOk_AtOnce_down_AvgCnt,
		limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,
		limit_ChighMax_AtOnce_Avg,
		limit_ClowMin_AtOnce_Avg,
		limit_ChighMax_ClowMin_AtOnce_Avg_delta,
		param_StopLoss,
		param_TakeProfit,
		param_cntSignalsBeforeDeal,
		param_DealTimeInMinutesFirst,
		param_DealTimeInMinutesLast
		


select  *, 
		round((cnt_StopLoss*1.0/cnt_deals),2) as percent_StopLoss,
		case when cnt_Buy=0  then null else round((cnt_BuyStopLoss*1.0/cnt_Buy),2) end as percent_BuyStopLoss,
		case when cnt_Sell=0 then null else round((cnt_SellStopLoss*1.0/cnt_Sell),2) end as percent_SellStopLoss,
		param_DealTimeInMinutesFirst,
		case when sum_TakeProfit=0 then 1 else abs(sum_StopLoss)*1.0/sum_TakeProfit end as percent_LossProfit
from #nt_st_results
where  	1=1
and limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.432
and limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.498
and limit_ChighMax_AtOnce_Avg	= 25
and limit_ClowMin_AtOnce_Avg = 30
-- and param_StopLoss = 16
--	and param_TakeProfit = 16
-- and param_StopLoss <= param_TakeProfit -- не учитывать! главное - percent_LossProfit
and cnt_deals >= 10
--and deal_profit_total >= 300
--and case when cnt_Buy=0  then null else round((cnt_BuyStopLoss*1.0/cnt_Buy),2) end < 0.5 -- as percent_BuyStopLoss,
--and case when cnt_Sell=0 then null else round((cnt_SellStopLoss*1.0/cnt_Sell),2) end < 0.5 -- as percent_SellStopLoss,
and cnt_Buy >= 7
and cnt_Sell >= 7
and ((cnt_Buy*1.0/cnt_Sell) >= 0.5 and (cnt_Buy*1.0/cnt_Sell) <= 2)
and param_DealTimeInMinutesFirst = (11*60)
order by 
		case when sum_TakeProfit=0 then 1 else abs(sum_StopLoss)*1.0/sum_TakeProfit end, -- as percent_LossProfit
		--round((cnt_StopLoss*1.0/cnt_deals),2),
		--case when cnt_Buy=0  then null else round((cnt_BuyStopLoss*1.0/cnt_Buy),2) end,
		--case when cnt_Sell=0 then null else round((cnt_SellStopLoss*1.0/cnt_Sell),2) end, --as percent_SellStopLoss
		 deal_profit_total desc


0,432	0,498	0,298	25	30	8	20	20	1	660	715	300	-900	1200	105	45	60	46	25	21	59	35	24	0.430000000000	0.460000000000	0.410000000000	660	0,75




-- выводим сделки
select *
from nt_st_deals_v02__16_21
where round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) = 0.564
	and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) = 0.432
	and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3) = 0.298
	and limit_ChighMax_AtOnce_Avg = 15
	and limit_ClowMin_AtOnce_Avg = 35
	and limit_ChighMax_ClowMin_AtOnce_Avg_delta = 12
	and param_StopLoss	= 20
	and param_TakeProfit = 20
	and param_cntSignalsBeforeDeal = 1
	and ParamsIdentifyer = '1_5_20150611'
	and param_DealTimeInMinutesFirst = (18*60)
order by idn
















--------------------------

-- 
select distinct param_DealTimeInMinutesFirst*1.0/60
-- delete
from nt_st_deals
where param_DealTimeInMinutesFirst >= (16*60)

select  *
from #nt_st_results
where  	1=1
	and param_DealTimeInMinutesFirst = (16*60)
order by 
	param_DealTimeInMinutesFirst ,
	limit_TakeProfit_isOk_AtOnce_up_AvgCnt ,
	limit_TakeProfit_isOk_AtOnce_down_AvgCnt ,
	limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta ,
	limit_ChighMax_AtOnce_Avg ,
	limit_ClowMin_AtOnce_Avg ,
	limit_ChighMax_ClowMin_AtOnce_Avg_delta ,
	param_StopLoss ,
	param_TakeProfit ,
	param_cntSignalsBeforeDeal 

---------------------------




-- выводим сделки
select *
-- delete
from nt_st_deals
where round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) = 0.498
	and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) = 0.498
	and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3) = 0.298
	and limit_ChighMax_AtOnce_Avg = 35
	and limit_ClowMin_AtOnce_Avg = 40
	and limit_ChighMax_ClowMin_AtOnce_Avg_delta = 10
	and param_StopLoss	= 27
	and param_TakeProfit = 31
	and param_cntSignalsBeforeDeal = 1
	and ParamsIdentifyer = '1_5_20150611'
	and param_DealTimeInMinutesFirst = (17*60)
order by idn

0,498	0,498	0,298	35	40	10	26	32	1	512	-416	928	45	16	29	13	11	2	32	18	14	0.360000000000	0.150000000000	0.440000000000
0,498	0,498	0,298	35	40	10	40	97	1	946	-800	1746	38	20	18	13	6	7	25	12	13	0.530000000000	0.540000000000	0.520000000000

-- 1_5
0,4		0,466	0,2	35	30	15
0,4		0,664	0,2	35	30	15
-- 1_5_20150611
0,466	0,466	0,2	30	35	15
0,466	0,664	0,2	30	30	15
0,466	0,664	0,2	30	40	15
0,466	0,664	0,266	30	40	15
0,598	0,4	0,2	30	40	15
0,598	0,4	0,2	30	35	15
0,598	0,466	0,2	30	35	15
0,598	0,532	0,2	30	35	15
0,466	0,664	0,266	30	30	15

0,598	0,598	0,232	30	35	10	20	20	1	900
0,598	0,598	0,298	30	35	10	20	20	1	900

-- оптимальные параметры:
nt_st_deals_v02__05_06, param_DealTimeInMinutesFirst = (5*60)
0,3	0,564	0,1	20	35	8	23	23	1	300	355	874	-1035	1909	128	45	83	111	73	38	17	10	7	0.350000000000	0.340000000000	0.410000000000	300
nt_st_deals_v02__06_12, param_DealTimeInMinutesFirst = (6*60)
0,564	0,63	0,298	40	25	10	20	20	1	360	415	120	-160	280	22	8	14	15	9	6	7	5	2	0.360000000000	0.400000000000	0.290000000000	360
nt_st_deals_v02__06_12, param_DealTimeInMinutesFirst = (7*60)
0,762	0,432	0,298	40	20	12	22	60	1	420	475	504	-396	900	33	18	15	0	0	0	33	15	18	0.550000000000	NULL	0.550000000000	420
nt_st_deals_v02__06_12, param_DealTimeInMinutesFirst = (8*60)
0,63	0,564	0,298	35	35	10	30	40	1	480	535	270	-210	480	19	7	12	8	6	2	11	6	5	0.370000000000	0.250000000000	0.450000000000	480	0,4375
nt_st_deals_v02__06_12, param_DealTimeInMinutesFirst = (9*60)
0,564	0,564	0,298	40	40	10	32	41	1	540	595	423	-192	615	21	6	15	9	6	3	12	9	3	0.290000000000	0.330000000000	0.250000000000	540	0,31219512195122
nt_st_deals_v02__06_12, param_DealTimeInMinutesFirst = (10*60)
0,762	0,498	0,232	35	35	8	38	32	1	600	655	918	-266	1184	44	7	37	0	0	0	44	37	7	0.160000000000	NULL	0.160000000000	600	0,224662162162162
nt_st_deals_v02__06_12, param_DealTimeInMinutesFirst = (11*60)
0,762	0,63	0,298	25	30	12	32	28	1	660	715	328	-64	392	16	2	14	0	0	0	16	14	2	0.130000000000	NULL	0.130000000000	660	0,163265306122449
nt_st_deals_v02__12_13
limit_TakeProfit_isOk_AtOnce_up_AvgCnt	limit_TakeProfit_isOk_AtOnce_down_AvgCnt	limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta	limit_ChighMax_AtOnce_Avg	limit_ClowMin_AtOnce_Avg	limit_ChighMax_ClowMin_AtOnce_Avg_delta	param_StopLoss	param_TakeProfit	param_cntSignalsBeforeDeal	deal_profit_total
0,598	0,4	0,232	40	23	10	23	76	2	720	775	1242	-506	1748	45	22	23	5	4	1	40	19	21	0.490000000000	0.200000000000	0.530000000000	720	0,289473684210526
nt_st_deals_v02__13_14
limit_TakeProfit_isOk_AtOnce_up_AvgCnt	limit_TakeProfit_isOk_AtOnce_down_AvgCnt	limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta	limit_ChighMax_AtOnce_Avg	limit_ClowMin_AtOnce_Avg	limit_ChighMax_ClowMin_AtOnce_Avg_delta	param_StopLoss	param_TakeProfit	param_cntSignalsBeforeDeal	deal_profit_total
0,432	0,63	0,398	20	35	10	20	20	2	780	835	220	-80	300	19	4	15	11	10	1	8	5	3	0.210000000000	0.090000000000	0.380000000000	780	0,266666666666667
nt_st_deals_v02__14_15
limit_TakeProfit_isOk_AtOnce_up_AvgCnt	limit_TakeProfit_isOk_AtOnce_down_AvgCnt	limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta	limit_ChighMax_AtOnce_Avg	limit_ClowMin_AtOnce_Avg	limit_ChighMax_ClowMin_AtOnce_Avg_delta	param_StopLoss	param_TakeProfit	param_cntSignalsBeforeDeal	deal_profit_total	sum_StopLoss	sum_TakeProfit	cnt_deals	cnt_StopLoss	cnt_TakeProfit	cnt_Buy	cnt_BuyTakeProfit	cnt_BuyStopLoss	cnt_Sell	cnt_SellTakeProfit	cnt_SellStopLoss	percent_StopLoss	percent_BuyStopLoss	percent_SellStopLoss
0,498	0,498	0,298	35	40	10	27	31	1	840	895	668	-324	992	44	12	32	13	12	1	31	20	11	0.270000000000	0.080000000000	0.350000000000	840	0,326612903225806
nt_st_deals_v02__15_16
0,564	0,564	0,1	40	40	10	16	45	1	900	955	518	-112	630	21	7	14	8	5	3	13	9	4	0.330000000000	0.380000000000	0.310000000000	900	0,177777777777778
nt_st_deals_v02__16_21, param_DealTimeInMinutesFirst = (16*60)
0,629	0,564	0,1	20	35	8	20	23	1	960	1015	303	-180	483	30	9	21	9	8	1	21	13	8	0.300000000000	0.110000000000	0.380000000000	960	0,372670807453416
nt_st_deals_v02__16_21, param_DealTimeInMinutesFirst = (17*60)
0,762	0,498	0,298	20	35	8	20	20	1	1020	1075	180	-80	260	17	4	13	0	0	0	17	13	4	0.240000000000	NULL	0.240000000000	1020	0,307692307692308
nt_st_deals_v02__16_21, param_DealTimeInMinutesFirst = (18*60)
0,564	0,432	0,298	15	35	12	20	20	1	1080	1135	200	-40	240	14	2	12	8	7	1	6	5	1	0.140000000000	0.130000000000	0.170000000000	1080	0,166666666666667
nt_st_deals_v02__16_21, param_DealTimeInMinutesFirst = (19*60)
0,432	0,498	0,298	20	25	8	15	21	1	1140	1195	315	-105	420	27	7	20	22	16	6	5	4	1	0.260000000000	0.270000000000	0.200000000000	1140	0,25
nt_st_deals_v02__16_21, param_DealTimeInMinutesFirst = (20*60)
0,3	0,63	0,232	15	15	12	21	18	1	1200	1255	165	-105	270	20	5	15	19	14	5	1	1	0	0.250000000000	0.260000000000	0.000000000000	1200	0,388888888888889


idn	idn_chart
394255	54736

-- сохраняем результаты расчетов (лучше переименовывать таблицу nt_st_deals и создавать ее заново)
-- select * into nt_st_deals_v01__1_5 from nt_st_deals
-- select * into nt_st_deals_v02__1_5 from nt_st_deals -- 12-13, sl=tp=20
-- select * into nt_st_deals_v02__12_13 from nt_st_deals -- 12-13, окончательный подбор sl и tp
-- exec sp_rename 'nt_st_deals', 'nt_st_deals_v02__13_14' -- 13-14, окончательный подбор sl и tp
-- exec sp_rename 'nt_st_deals', 'nt_st_deals_v02__14_15' -- 14-15, окончательный подбор sl и tp
-- exec sp_rename 'nt_st_deals', 'nt_st_deals_v02__15_16' -- 15-16, окончательный подбор sl и tp
-- exec sp_rename 'nt_st_deals', 'nt_st_deals_v02__16_21' -- 16-21, окончательный подбор sl и tp
-- exec sp_rename 'nt_st_deals', 'nt_st_deals_v02__06_12' -- 06-12, окончательный подбор sl и tp
-- exec sp_rename 'nt_st_deals', 'nt_st_deals_v02__05_06' -- 05-06, окончательный подбор sl и tp

-- exec sp_rename 'ntAverageValuesResults', 'ntAverageValuesResults_20150611_previousday_DeltaMinutesCalcCorr_30'
-- exec sp_rename 'ntAverageValuesResults_DeltaMinutesCalcCorr_120', 'ntAverageValuesResults'



-- nt_st_deals_v02__05_06
-- nt_st_deals_v02__06_12
-- nt_st_deals_v02__12_13
-- nt_st_deals_v02__13_14
-- nt_st_deals_v02__14_15
-- nt_st_deals_v02__15_16
-- nt_st_deals_v02__16_21







-- truncate table nt_st_deals




select * from nt_st_deals with (nolock)
select * from nt_st_deals_v02__06_12 (nolock) where param_TakeProfit <> 20
select * from nt_st_deals_v02__16_21 (nolock) where param_TakeProfit <> 20
param_StopLoss	param_TakeProfit
20	20

	
*/






--------------------------------------------
-- анализируем сделки
If object_ID('tempdb..#nt_st_deals') Is not Null drop table #nt_st_deals



select d.idn, cf.idn as cf_idn, cl.idn as cl_idn, cl.cdatetime as cl_cdatetime, 
	(select MIN(clow) from nt_st_chart where idn >= cf.idn and idn <= cl.idn) as clow_min,
	(select MAX(chigh) from nt_st_chart where idn >= cf.idn and idn <= cl.idn) as chigh_max,
	--(select MAX(chigh) from nt_st_chart where idn >= cf.idn and idn <= cl.idn) - (select MIN(clow) from nt_st_chart where idn >= cf.idn and idn <= cl.idn) as chart_range,
	d.deal_profit, 
	--cf.ctime as cf_ctime,
	cl.ctime as cl_ctime,
	left(cl.ctime,2) as cl_chour,
	right(cl.ctime,2) as cl_cminutes,
	v.CcorrMax, v.CcorrAvg,
	v.CcorrMax as StDev_cclose, v.CcorrMax as StDevP_cclose, v.CcorrMax as Var_cclose, v.CcorrMax as VarP_cclose,
	cl.Volume as Volume
--	*
	--d.*
into #nt_st_deals
from nt_st_deals d with (nolock)
left outer join nt_st_chart cl with (nolock) on cl.idn = d.idn_chart and cl.ParamsIdentifyer = d.ParamsIdentifyer -- последняя запись на графике
left outer join ntAverageValuesResults v with (nolock) on v.idn = d.idn_AverageValues
left outer join nt_st_chart cf with (nolock) on cf.cdatetime = v.cdatetime_first and cf.copen = v.copen_first and cf.chigh = v.chigh_first and cf.clow = v.clow_first and cf.cclose = v.cclose_first -- первая запись на графике
	and cf.ParamsIdentifyer = d.ParamsIdentifyer
--where round(d.limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) = 0.598
--	and round(d.limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) = 0.598
--	and round(d.limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3) = 0.232
--	and d.limit_ChighMax_AtOnce_Avg = 30
--	and d.limit_ClowMin_AtOnce_Avg = 35
--	and d.limit_ChighMax_ClowMin_AtOnce_Avg_delta = 10
--	and d.param_cntSignalsBeforeDeal = 1
--	and d.ParamsIdentifyer = '1_5_20150611'
--	and d.idn >= 2854955 --394123 --394255
where round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) = 0.432
	and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) = 0.366
	and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3) = 0.2
	and limit_ChighMax_AtOnce_Avg = 19
	and limit_ClowMin_AtOnce_Avg = 19
	and limit_ChighMax_ClowMin_AtOnce_Avg_delta = 8
	and param_StopLoss	= 38
	and param_TakeProfit = 15
	and param_cntSignalsBeforeDeal = 1
	and d.ParamsIdentifyer = '1_5_20150611'
	and param_DealTimeInMinutesLast = (14*60)-5
order by d.idn --(select MAX(chigh) from nt_st_chart where idn >= cf.idn and idn <= cl.idn) - (select MIN(clow) from nt_st_chart where idn >= cf.idn and idn <= cl.idn), d.idn


-- select * from #nt_st_deals


declare @idn int, @cf_idn int, @cl_idn int
declare @cclose_min real, @cclose_max real
declare @StDev_cclose real, @StDevP_cclose real, @Var_cclose real, @VarP_cclose real
declare @Volume int

-- делаем курсор по следкам для вычисдения дополнительных показателей
	DECLARE cDealsCursor CURSOR FOR
	-- выбираем все цены и рассчитанные общие показатели
	SELECT  idn, cf_idn, cl_idn
	from #nt_st_deals
	order by idn


	OPEN cDealsCursor

	-- запоминаем все цены и рассчитанные общие показатели
	FETCH NEXT FROM cDealsCursor 
	INTO @idn, @cf_idn, @cl_idn
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- строим график цены с начала дня до сделки
		If object_ID('tempdb..#nt_st_DealChart') Is not Null drop table #nt_st_DealChart
		
		select *, cclose as cclose_changed
		into #nt_st_DealChart
		from nt_st_chart with (nolock)
		where idn >= @cf_idn and idn <= @cl_idn
		order by idn

		
		select @cclose_min = MIN(cclose) from #nt_st_DealChart
		select @cclose_max = MAX(cclose) from #nt_st_DealChart
		select @Volume = SUM(Volume)  from #nt_st_DealChart
		
		-- приводим cclose к диапазону от 0 до 1
		update #nt_st_DealChart set cclose_changed = (cclose-@cclose_min)*1.0/(@cclose_max-@cclose_min)

		-- считаем статистические показатели по графику цены текущей сделки
		select  @StDev_cclose = StDev(cclose_changed), 
				@StDevP_cclose = StDevP(cclose_changed), 
				@Var_cclose = Var(cclose_changed), 
				@VarP_cclose = VarP(cclose_changed)
		from #nt_st_DealChart
		
		update #nt_st_deals
		set StDev_cclose = @StDev_cclose, 
			StDevP_cclose = @StDevP_cclose, 
			Var_cclose = @Var_cclose, 
			VarP_cclose = @VarP_cclose,
			Volume = @Volume
		where idn = @idn
		
		-- select * from #nt_st_DealChart order by idn

	FETCH NEXT FROM cDealsCursor 
	INTO @idn, @cf_idn, @cl_idn
	END 

	CLOSE cDealsCursor;
	DEALLOCATE cDealsCursor;



-- зависимость от часа дня и минут
SET DATEFORMAT ymd
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
	cl_chour,
	cl_cminutes,
	chigh_max - clow_min, 
	--CcorrMax 
	VarP_cclose
	--chigh_max - clow_min
	

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



-- зависимость от chart_range
select idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour
from #nt_st_deals
order by (chigh_max - clow_min)

-- зависимость от часа дня и минут
select idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes
from #nt_st_deals
order by cl_chour, 
		 cl_cminutes,
		(chigh_max - clow_min)		

-- зависимость от часа дня и К
select idn, cf_idn, cl_idn, 
	clow_min,
	chigh_max,
	round((chigh_max - clow_min)*10000,0) as chart_range,
	deal_profit,
	cl_chour,
	cl_cminutes,
	CcorrMax, CcorrAvg
from #nt_st_deals
order by --cl_chour, 
		 --CcorrMax 
		 CcorrAvg desc






-- delete from ntAverageValuesResults
select * from nt_st_chart 
select * from #nt_st_deals



cl_idn
10230



--------------------------------------------


--/*

-- загружаем график цены
-- select * into _nt_st_chart_old from nt_st_chart order by cdatetime


-- очищаем график цены (не надо очищать)
-- truncate table nt_st_chart
-- delete from nt_st_chart where ...
select * from nt_st_chart order by cdatetime -- 17957 62822

-- в Access запускаем следующий запрос (заполняем график) 
-- (перед запуском задать параметры)
-- после записи выстроить записи по порядку (см.следующий запрос)
insert into nt_st_chart (cdate , ctime , cdatetime , copen , chigh , clow , cclose , Volume , ABV , ABVMini , ABMmPosition0 , ABMmPosition1,
	CurrencyIdCurrent,
	CurrencyIdHistory,
	DataSourceId,
	PeriodMinutes,
	PeriodMultiplicatorMin,
	PeriodMultiplicatorMax,
	ParamsIdentifyer)
select cdate , ctime , cdatetime , copen , chigh , clow , cclose , Volume , ABV , ABVMini , ABMmPosition0 , ABMmPosition1,
	1 as CurrencyIdCurrent,
	1 as CurrencyIdHistory,
	2 as DataSourceId,
	5 as PeriodMinutes,
	1 as PeriodMultiplicatorMin,
	1 as PeriodMultiplicatorMax,
	'1_5_20150611' as ParamsIdentifyer
from ntImport_6E_Minute_5_id1
where cdate >= '2016.05.01'
  and cdate <= '2016.05.26'
order by cdatetime

-- выстраиваем записи по порядку
-- select * from #nt_st_chart_temp
select *
into #nt_st_chart_temp
from nt_st_chart
order by cdatetime

truncate table nt_st_chart

insert into nt_st_chart (cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer)
select cdate, ctime, cdatetime, copen, chigh, clow, cclose, Volume, ABV, ABVMini, ABMmPosition0, ABMmPosition1, CurrencyIdCurrent, CurrencyIdHistory, DataSourceId, PeriodMinutes, PeriodMultiplicatorMin, PeriodMultiplicatorMax, ParamsIdentifyer
from #nt_st_chart_temp
order by cdatetime



-- 44865


-- select * from nt_st_chart order by idn
-- select * from ntAverageValuesResults order by idn desc -- рассчитанные общие показатели (за все время)

-- проверяем рассчитанные общие показатели
declare @CurrencyIdCurrent int, @CurrencyIdHistory int, @DataSourceId int, @PeriodMinutes int, @PeriodMultiplicatorMin int, @PeriodMultiplicatorMax int, @cntCharts int, @StopLoss int, @TakeProfit int, @OnePoint real, @ParamsIdentifyer VARCHAR(50),
		@cdatetime_first VARCHAR(16), @cdatetime_last VARCHAR(16)
select @CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5_20150611',
		@cdatetime_first = '2015.01.01 05:00', @cdatetime_last = '2015.01.26 21:00'

select * 
from nt_st_chart c
left outer join ntAverageValuesResults v on 
		v.CurrencyId_current = c.CurrencyIdCurrent
	and v.CurrencyId_history = c.CurrencyIdHistory
	and v.DataSourceId = c.DataSourceId
	and v.PeriodMinutes = c.PeriodMinutes
	and v.cdatetime_last = c.cdatetime
	and v.copen_last = c.copen
	and v.chigh_last = c.chigh
	and v.clow_last = c.clow
	and v.cclose_last = c.cclose
where
	    c.CurrencyIdCurrent = @CurrencyIdCurrent
	and c.CurrencyIdHistory = @CurrencyIdHistory
	and c.DataSourceId = @DataSourceId
	and c.PeriodMinutes = @PeriodMinutes
	and c.PeriodMultiplicatorMin = @PeriodMultiplicatorMin
	and c.PeriodMultiplicatorMax = @PeriodMultiplicatorMax
	and c.ParamsIdentifyer = @ParamsIdentifyer	
	and c.cdatetime >= @cdatetime_first
	and c.cdatetime <= @cdatetime_last	
	and v.cdatetime_last is not null -- на данное время рассчитаны общие показатели
order by c.idn
*/

----------------------------------------------
/*

truncate table nt_st_deals

exec ntp_st_MakeDeals 
	-- переменные для построения графика цены
	@CurrencyIdCurrent = 1, @CurrencyIdHistory = 1, @DataSourceId = 2, @PeriodMinutes = 5, @PeriodMultiplicatorMin = 1, @PeriodMultiplicatorMax = 1, @cntCharts = 15, @StopLoss = 10, @TakeProfit = 15, @OnePoint = 0.0001, @ParamsIdentifyer = '1_5',
	-- переменные для расчета сделок
	@limit_CcorrMax = 0, @limit_CcorrAvg = 0, @limit_TakeProfit_isOk_Daily_up_AvgCnt = 0, @limit_TakeProfit_isOk_Daily_down_AvgCnt = 0, @limit_TakeProfit_isOk_Daily_up_PrcBars = 0, @limit_TakeProfit_isOk_Daily_down_PrcBars = 0, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.6, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
	@limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.6, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
	@limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.3, 
	@limit_ChighMax_Daily_Avg = 0, @limit_ClowMin_Daily_Avg = 0, 
	@limit_ChighMax_AtOnce_Avg = 20, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	@limit_ClowMin_AtOnce_Avg = 20, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	@limit_ChighMax_ClowMin_AtOnce_Avg_delta = 10,
	-- прочие параметры стратегии
	@param_StopLoss = 20, 
	@param_TakeProfit = 20, 
	@param_cntSignalsBeforeDeal = 0, -- количество сигналов подряд, нужное для заключения сделки
	@param_volume = 10000



select * from nt_st_deals
select * from nt_st_chart where idn = 1188
select * from ntAverageValuesResults where cdatetime_last = '2015.10.30 08:05'



*/

/*
declare
	@limit_CcorrMax real, @limit_CcorrAvg real, @limit_TakeProfit_isOk_Daily_up_AvgCnt real, @limit_TakeProfit_isOk_Daily_down_AvgCnt real, @limit_TakeProfit_isOk_Daily_up_PrcBars real, @limit_TakeProfit_isOk_Daily_down_PrcBars real, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_down_AvgCnt real, @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta real, 
	@limit_ChighMax_Daily_Avg real, @limit_ClowMin_Daily_Avg real, 
	@limit_ChighMax_AtOnce_Avg real, @limit_ClowMin_AtOnce_Avg real, @limit_ChighMax_ClowMin_AtOnce_Avg_delta real
select
	@limit_CcorrMax = 0, @limit_CcorrAvg = 0, @limit_TakeProfit_isOk_Daily_up_AvgCnt = 0, @limit_TakeProfit_isOk_Daily_down_AvgCnt = 0, @limit_TakeProfit_isOk_Daily_up_PrcBars = 0, @limit_TakeProfit_isOk_Daily_down_PrcBars = 0, 
	@limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.5, -- кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
	@limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.5, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
	@limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.3, 
	@limit_ChighMax_Daily_Avg = 0, @limit_ClowMin_Daily_Avg = 0, 
	@limit_ChighMax_AtOnce_Avg = 40, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	@limit_ClowMin_AtOnce_Avg = 40, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
	@limit_ChighMax_ClowMin_AtOnce_Avg_delta = 20
		
select * from ntAverageValuesResults where 
				TakeProfit_isOk_AtOnce_down_AvgCnt >= @limit_TakeProfit_isOk_AtOnce_down_AvgCnt
			and (TakeProfit_isOk_AtOnce_down_AvgCnt - TakeProfit_isOk_AtOnce_up_AvgCnt) >= @limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta
			and ClowMin_AtOnce_Avg >= @limit_ClowMin_AtOnce_Avg
			and (ClowMin_AtOnce_Avg - ChighMax_AtOnce_Avg) >= @limit_ChighMax_ClowMin_AtOnce_Avg_delta
*/	

select * from nt_st_deals
select * from nt_st_chart
select * from ntAverageValuesResults where cdatetime_last = '2015.08.26 09:35'
select * 
-- delete
from ntAverageValuesResults where cdate_first	<>	cdate_last



select *
from nt_st_chart c 
left outer join ntAverageValuesResults v on v.cdatetime_last = c.cdatetime
where v.cdatetime_last is not null

select c.cdatetime, COUNT(*)
from nt_st_chart c 
left outer join ntAverageValuesResults v on v.cdatetime_last = c.cdatetime
where v.cdatetime_last is not null
group by c.cdatetime
having  COUNT(*)>1


select COUNT(*) from nt_st_deals where idn_AverageValues is null -- 392869

select d.idn_AverageValues, v.idn, *
-- update d set d.idn_AverageValues = v.idn
from nt_st_deals d
left outer join nt_st_chart c on c.idn = d.idn_chart
left outer join ntAverageValuesResults v on v.cdatetime_last = c.cdatetime
where d.idn_AverageValues is not null


-- 
select * from nt_st_deals




		


-- запускаем тестер стратегий с перебором параметров



select *
from nt_st_chart
where idn >= 51041 and idn <= 51280

select ChighMax_AtOnce_Avg - ClowMin_AtOnce_Avg, *
from ntAverageValuesResults
where cdatetime_last in ('2015.12.02 05:00','2015.12.02 05:05','2015.12.02 05:10','2015.12.02 05:15')

select *
-- into nt_st_deals_v02__1_5_20150611 -- 94742
-- delete
from nt_st_deals
where ParamsIdentifyer = '1_5_20150611'

select *
-- from nt_st_deals 
 from nt_st_deals_v02__1_5_20150611
where round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) = 0.4
	and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) = 0.4
	and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3) = 0.2
	and limit_ChighMax_AtOnce_Avg = 35
	and limit_ClowMin_AtOnce_Avg = 30
	and limit_ChighMax_ClowMin_AtOnce_Avg_delta = 15
	and param_cntSignalsBeforeDeal = 0
	and ParamsIdentifyer = '1_5_20150611'
order by idn_chart

select *
-- delete
 from nt_st_deals 
-- from nt_st_deals_v02__1_5_20150611
where round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3) = 0.4
	and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3) = 0.4
	and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3) = 0.2
	and limit_ChighMax_AtOnce_Avg = 35
	and limit_ClowMin_AtOnce_Avg = 30
	and limit_ChighMax_ClowMin_AtOnce_Avg_delta = 15
	and param_cntSignalsBeforeDeal = 1
	and ParamsIdentifyer = '1_5_20150611'
order by idn_chart


select *
-- delete
 from nt_st_deals 
where param_DealTimeInMinutesLast = (13*60)-5




select * from ntAverageValuesResults where idn in (81019,82785,82995,83377,85640,85705,85825,86001,86203,86784,86990,88150)
select * from ntAverageValuesResults where idn in (71828,72043,72032,72236,72431,72636,72630,72602)
select * from ntAverageValuesResults where idn = 93608


select 32.86666 - 18.8

--/*






-- select * from nt_st_deals

-- select * from nt_st_chart where idn in (3160,3350,3630,3695,3728,3908)
-- select * from ntAverageValuesResults where cdatetime_last = '2015.10.30 08:05'


--select  @limit_TakeProfit_isOk_AtOnce_up_AvgCnt = 0.6,
--		@limit_TakeProfit_isOk_AtOnce_down_AvgCnt = 0.6, -- кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
--		@limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta = 0.3, 
--		@limit_ChighMax_AtOnce_Avg = 20, -- среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
--		@limit_ClowMin_AtOnce_Avg = 21, -- среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
--		@limit_ChighMax_ClowMin_AtOnce_Avg_delta = 10,
--		-- прочие параметры стратегии
--		@param_StopLoss = 20, 
--		@param_TakeProfit = 20,
--		@cnt_variants = 0



--/*

select *
from nt_st_deals with (nolock)
where 
	round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3)	= 0.466
and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3)	= 0.532
and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3)	= 0.232
and limit_ChighMax_Daily_Avg	= 0
and limit_ClowMin_Daily_Avg	= 0
and limit_ChighMax_AtOnce_Avg	= 35
and limit_ClowMin_AtOnce_Avg	= 40
and limit_ChighMax_ClowMin_AtOnce_Avg_delta	= 10
and param_StopLoss	= 20
and param_TakeProfit	= 20
and param_cntSignalsBeforeDeal = 1
and ParamsIdentifyer = '1_5_20150611'
order by idn 

select *
from nt_st_deals with (nolock)
where 
	round(limit_TakeProfit_isOk_AtOnce_up_AvgCnt,3)	= 0.466
and round(limit_TakeProfit_isOk_AtOnce_down_AvgCnt,3)	= 0.532
and round(limit_TakeProfit_isOk_AtOnce_up_down_AvgCnt_delta,3)	= 0.232
and limit_ChighMax_Daily_Avg	= 0
and limit_ClowMin_Daily_Avg	= 0
and limit_ChighMax_AtOnce_Avg	= 35
and limit_ClowMin_AtOnce_Avg	= 40
and limit_ChighMax_ClowMin_AtOnce_Avg_delta	= 20
and param_StopLoss	= 20
and param_TakeProfit	= 20
and param_cntSignalsBeforeDeal = 1
and ParamsIdentifyer = '1_5_20150611'
order by idn 



