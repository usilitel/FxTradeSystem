


-- 1) импортируем файл Futures_typeB (Все сделки и лучшие заявки - Тип B)

-- проверка:
SELECT * from Futures_typeB where [#symbol] = 'SiH4' and type = 'B' order by moment

-- 2)

-- суммируем объемы заявок по минутам
SELECT left(moment,12) as mm, type, sum(CONVERT(int,replace(volume,'null','0'))) as volume_buy  into #Futures_typeB_SiH4_type_B from Futures_typeB where [#symbol] = 'SiH4' and type = 'B' group by left(moment,12) , type 
SELECT left(moment,12) as mm, type, sum(CONVERT(int,replace(volume,'null','0'))) as volume_sell into #Futures_typeB_SiH4_type_S from Futures_typeB where [#symbol] = 'SiH4' and type = 'S' group by left(moment,12) , type 

-- рассчитываем ABV
SELECT isnull(b.mm,s.mm) as mm, isnull(b.volume_buy,0) as volume_buy, isnull(s.volume_sell,0) as volume_sell
from #Futures_typeB_SiH4_type_B as b
full outer join  #Futures_typeB_SiH4_type_S as s on s.mm=b.mm
order by isnull(b.mm,s.mm)


--------------------------------
-- drop table SiU4_converted

-- 1) импортируем файл SiU4.txt (Все сделки и все заявки - Тип А)

SELECT TYPE, convert(bigint,left(moment,12)) as moment, convert(bigint,ID) as ID, convert(int,ACTION) as ACTION, PRICE, convert(int,VOLUME) as VOLUME, convert(bigint,ID_DEAL) as ID_DEAL, PRICE_DEAL
into SiU4_converted
from SiU4 

CREATE CLUSTERED INDEX [idnindex] ON [dbo].[SiU4_converted] 
([ID] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


-- 2)

-- суммируем объемы заявок по минутам

-- заявки выставленные и не снятые сразу
SELECT b1.moment as mm, 
	   b1.type, 
	   sum(b1.VOLUME) as sum_volume
into #SiU4_placed
from SiU4_converted b1
left outer join SiU4_converted b0 on b0.ID = b1.ID and b0.[ACTION] = 0 and b0.moment = b1.moment -- снятые сразу заявки
where b1.[ACTION] = 1
  and b0.ID is null -- заявка не снята сразу
group by  b1.moment, b1.type


-- заявки снятые не сразу
SELECT b0.moment as mm, 
	   b0.type, 
	   sum(b0.VOLUME) as sum_volume
into #SiU4_removed
from SiU4_converted b0
left outer join SiU4_converted b1 on b1.ID = b0.ID and b1.[ACTION] = 1 and b1.moment = b0.moment -- снятые сразу заявки
where b0.[ACTION] = 0
  and b1.ID is null -- заявка снята не сразу
group by  b0.moment, b0.type

-- select * from #SiU4_placed order by mm
-- select * from #SiU4_removed order by mm



SELECT * into #SiU4_placed_B from #SiU4_placed where [type] = 'B'
SELECT * into #SiU4_placed_S from #SiU4_placed where [type] = 'S'
SELECT * into #SiU4_removed_B from #SiU4_removed where [type] = 'B'
SELECT * into #SiU4_removed_S from #SiU4_removed where [type] = 'S'

-- объемы заявок по минутам
select coalesce(pb.mm,ps.mm,rb.mm,rs.mm) as mm, isnull(pb.sum_volume,0) - isnull(rb.sum_volume,0) - isnull(ps.sum_volume,0) + isnull(rs.sum_volume,0) as delta_sum_volume
from #SiU4_placed_B pb
full outer join #SiU4_placed_S ps on ps.mm=pb.mm
full outer join #SiU4_removed_B rb on rb.mm=isnull(pb.mm,ps.mm)
full outer join #SiU4_removed_S rs on rs.mm=coalesce(pb.mm,ps.mm,rb.mm)
order by coalesce(pb.mm,ps.mm,rb.mm,rs.mm)



  



