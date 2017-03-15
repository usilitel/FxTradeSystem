


/*


select 'idn'

 select top 1 'idn' from forex..ntCorrResultsPeriodsData
  union all 
 select top 1 
 convert(varchar,idn)
 from forex..ntCorrResultsPeriodsData





declare @sql as varchar(5000)

select @sql = ''
select @sql = @sql + 'select ''idn'''
select @sql = @sql + ' union all '
select @sql = @sql + ' select top 1 '
select @sql = @sql + ' idn '
select @sql = @sql + ' from forex..ntCorrResultsPeriodsData'

exec (@sql)

*/

-- Exec master..xp_cmdshell 'bcp "forex..ntCorrResultsPeriodsData" out "D:\forex\Access\Test4.csv" -c -t ; -T'

declare @sql as varchar(5000)
declare @sql_all as varchar(5000)

select @sql = ''
--select @sql = @sql + 'select ''idn'', ''idnData'', ''cdate'', ''ctime'', ''cdatetime'', ''copen'', ''chigh'', ''clow'', ''cclose'', ''cperiodResult'', ''cdateResult'', ''ctimeResult'', ''deltaMinutesResult'', ''ccorrResult'', ''cperiodsAll'', ''is_replaced'', ''deltaKmaxPercent'', ''ccorrmax_replaced'', ''cperiodMax_replaced'', ''deltaMinutesMax_replaced'', ''Volume'', ''ABV'', ''ABVMini'', ''ABMmPosition0'', ''ABMmPosition1'''
select @sql = @sql + ' select top 1 '
select @sql = @sql + ' idn, idnData, CONVERT(VARCHAR, cdate, 102), ctime, CONVERT(VARCHAR, cdatetime, 102), '
select @sql = @sql + ' replace(copen,''.'',''.''), replace(chigh,''.'',''.''), replace(clow,''.'',''.''), replace(cclose,''.'',''.''), '
select @sql = @sql + ' cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, replace(ccorrResult,''.'',''.''), cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, replace(ABMmPosition0,''.'',''.''), replace(ABMmPosition1,''.'',''.'') '
--select @sql = @sql + ' replace(copen,''.'','',''), replace(chigh,''.'','',''), replace(clow,''.'','',''), replace(cclose,''.'','',''), '
--select @sql = @sql + ' cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, replace(ccorrResult,''.'','',''), cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, replace(ABMmPosition0,''.'','',''), replace(ABMmPosition1,''.'','','') '
select @sql = @sql + ' from forex..ntCorrResultsPeriodsData'
select @sql = @sql + ' union all '
--select @sql = @sql + ' select top 2600 '
select @sql = @sql + ' select top 60000 '
select @sql = @sql + ' idn, idnData, CONVERT(VARCHAR, cdate, 102), ctime, CONVERT(VARCHAR, cdatetime, 102), '
select @sql = @sql + ' replace(copen,''.'',''.''), replace(chigh,''.'',''.''), replace(clow,''.'',''.''), replace(cclose,''.'',''.''), '
select @sql = @sql + ' cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, replace(ccorrResult,''.'',''.''), cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, replace(ABMmPosition0,''.'',''.''), replace(ABMmPosition1,''.'',''.'') '
--select @sql = @sql + ' replace(copen,''.'','',''), replace(chigh,''.'','',''), replace(clow,''.'','',''), replace(cclose,''.'','',''), '
--select @sql = @sql + ' cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, replace(ccorrResult,''.'','',''), cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, replace(ABMmPosition0,''.'','',''), replace(ABMmPosition1,''.'','','') '
select @sql = @sql + ' from forex..ntCorrResultsPeriodsData'

--exec (@sql)




declare @i int

select @i=1

while @i<=1
begin
--select @i

  select @sql_all = 'bcp "' + @sql + '" queryout "D:\forex\Access\ForexChartsHistoryData\ForexChartsHistoryData' + CONVERT(VARCHAR, @i) + '.csv" -c -t , -T'
  --select @sql
  Exec master..xp_cmdshell @sql_all


select @i=@i+1
end





/*
select top 2600 
idn, idnData, CONVERT(VARCHAR, cdate, 102), ctime, CONVERT(VARCHAR, cdatetime, 102), 
replace(copen,'.',','), replace(chigh,'.',','), replace(clow,'.',','), replace(cclose,'.',',') 
cperiodResult, cdateResult, ctimeResult, deltaMinutesResult, replace(ccorrResult,'.',','), cperiodsAll, is_replaced, deltaKmaxPercent, ccorrmax_replaced, cperiodMax_replaced, deltaMinutesMax_replaced, Volume, ABV, ABVMini, replace(ABMmPosition0,'.',','), replace(ABMmPosition1,'.',',') 
from forex..ntCorrResultsPeriodsData

select top 2600 idn, idnData, CONVERT(VARCHAR, cdate, 102) as cdate
from forex..ntCorrResultsPeriodsData
*/


/*

/*

SET NOCOUNT ON;

DECLARE @T TABLE(	[idn] [int] NULL,
	[cclose] [real] NOT NULL,
	[ABV] [int] NULL,
	[ABVMini] [int] NULL,
	ident int IDENTITY(1,1) PRIMARY KEY)
	--unique(ident))

--CREATE UNIQUE CLUSTERED INDEX [idnindex] ON [dbo].[@T] ([idn] ASC)


INSERT INTO @T select top 200000 * from ntPeriodsDataCCLOSE

-- select * from @T

/*
DECLARE @idn int
DECLARE @cclose [real]

select @idn = 1

while @idn <= (400000) begin
	select @cclose = cclose from @T where ident = @idn
	select @idn = @idn+1
end
*/







DECLARE @cclose [real]

DECLARE vendor_cursor CURSOR --LOCAL  
READ_ONLY 
FAST_FORWARD 
--OPTIMISTIC
FOR 
SELECT cclose  
FROM @T
order by ident



OPEN vendor_cursor

FETCH NEXT FROM vendor_cursor 
INTO @cclose

WHILE @@FETCH_STATUS = 0
BEGIN

    FETCH NEXT FROM vendor_cursor 
    INTO @cclose
END 
CLOSE vendor_cursor;
DEALLOCATE vendor_cursor;






*/