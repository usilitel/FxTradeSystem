
-- если запросы отваливаются по таймауту (в Access выдается ошибка "истекло время ожидания запроса")

-- во время выполнения запросы выполнить:

sp_who2
go
sp_lock


1    	BACKGROUND                    	sa	  .	  .	NULL	RESOURCE MONITOR	15	0	07/11 09:00:51	                                                     	1    	0    
2    	BACKGROUND                    	sa	  .	  .	NULL	XE TIMER        	0	0	07/11 09:00:51	                                                     	2    	0    
3    	BACKGROUND                    	sa	  .	  .	NULL	XE DISPATCHER   	0	0	07/11 09:00:51	                                                     	3    	0    
4    	BACKGROUND                    	sa	  .	  .	NULL	LOG WRITER      	1500	0	07/11 09:00:51	                                                     	4    	0    
5    	BACKGROUND                    	sa	  .	  .	NULL	LOCK MONITOR    	62	0	07/11 09:00:51	                                                     	5    	0    
6    	BACKGROUND                    	sa	  .	  .	NULL	LAZY WRITER     	406	0	07/11 09:00:51	                                                     	6    	0    
7    	BACKGROUND                    	sa	  .	  .	master	SIGNAL HANDLER  	0	0	07/11 09:00:51	                                                     	7    	0    
8    	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	8    	0    
9    	BACKGROUND                    	sa	  .	  .	master	TRACE QUEUE TASK	62	0	07/11 09:00:51	                                                     	9    	0    
10   	BACKGROUND                    	sa	  .	  .	master	BRKR TASK       	93	0	07/11 09:00:51	                                                     	10   	0    
11   	BACKGROUND                    	sa	  .	  .	tempdb	CHECKPOINT      	12156	11706	07/11 09:00:51	                                                     	11   	0    
12   	BACKGROUND                    	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	12   	0    
13   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	13   	0    
14   	BACKGROUND                    	sa	  .	  .	master	BRKR EVENT HNDLR	0	33	07/11 09:00:51	                                                     	14   	0    
15   	BACKGROUND                    	sa	  .	  .	master	BRKR TASK       	0	0	07/11 09:00:51	                                                     	15   	0    
16   	BACKGROUND                    	sa	  .	  .	master	BRKR TASK       	0	0	07/11 09:00:51	                                                     	16   	0    
17   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	17   	0    
18   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	18   	0    
19   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	19   	0    
20   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	89	07/11 09:00:51	                                                     	20   	0    
21   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	1	07/11 09:00:51	                                                     	21   	0    
22   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	22   	0    
23   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	23   	0    
24   	sleeping                      	sa	  .	  .	master	TASK MANAGER    	0	0	07/11 09:00:51	                                                     	24   	0    
51   	sleeping                      	sa	MNIKOLAEV79	  .	master	AWAITING COMMAND	172	68	07/11 11:49:29	Microsoft SQL Server Management Studio               	51   	0    
52   	sleeping                      	sa	MNIKOLAEV79	  .	forex	AWAITING COMMAND	0	0	07/13 08:59:46	Среда Microsoft SQL Server Management Studio - запрос	52   	0    
53   	sleeping                      	MNIKOLAEV79\user1	MNIKOLAEV79	  .	forex	AWAITING COMMAND	452	5	07/13 09:00:10	                                                     	53   	0    
54   	SUSPENDED                     	MNIKOLAEV79\user1	MNIKOLAEV79	  .	forex	SELECT          	172	513	07/13 09:21:42	Microsoft Office 2003                                	54   	0    
54   	SUSPENDED                     		MNIKOLAEV79	  .	forex	SELECT          	2147483647	686	07/13 09:21:42	Microsoft Office 2003                                	54   	0    
54   	SUSPENDED                     		MNIKOLAEV79	  .	forex	SELECT          	2147483647	549	07/13 09:21:42	Microsoft Office 2003                                	54   	0    
54   	SUSPENDED                     		MNIKOLAEV79	  .	forex	SELECT          	2147483647	641	07/13 09:21:42	Microsoft Office 2003                                	54   	0    
54   	SUSPENDED                     		MNIKOLAEV79	  .	forex	SELECT          	2147483647	810	07/13 09:21:42	Microsoft Office 2003                                	54   	0    
57   	RUNNABLE                      	sa	MNIKOLAEV79	  .	forex	SELECT INTO     	857	95	07/13 09:21:38	Среда Microsoft SQL Server Management Studio - запрос	57   	0    

52	5	0	0	DB	                                	S	GRANT
53	5	0	0	DB	                                	S	GRANT
54	5	0	0	DB	                                	S	GRANT
54	5	1906105831	1	PAG	1:2055229                       	S	GRANT
54	5	1906105831	1	PAG	1:2083525                       	S	GRANT
54	5	1906105831	0	TAB	                                	IS	GRANT
54	5	1906105831	0	TAB	                                	IS	GRANT
54	5	1906105831	0	TAB	                                	IS	GRANT
54	5	1906105831	0	TAB	                                	IS	GRANT
54	5	1906105831	0	TAB	                                	IS	GRANT
57	5	0	0	DB	                                	S	GRANT
57	2	0	0	DB	[ENCRYPTION_SCAN]               	S	GRANT
57	1	1131151075	0	TAB	                                	IS	GRANT

select OBJECT_NAME(1557580587)

select * from ntCorrResultsPeriodsData_DataChart --where ParamsIdentifyer = '6E_15_120_PA211'
select ParamsIdentifyer, count(*) from ntCorrResultsPeriodsData_DataChart group by ParamsIdentifyer order by count(*)


-- truncate table ntCorrResultsPeriodsData_DataChart
-- truncate table ntCorrResultsPeriodsData_DataTotal

-- exec ntpCorrResultsAverageValuesParamRanges  '6E_15_120_PA211'

exec sp_spaceused