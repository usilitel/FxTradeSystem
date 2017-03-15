
-- !!!!
-- ЛУЧШЕ отсоединять/присоединять БД, т.к. это быстрее

RESTORE DATABASE [forex]
     FROM DISK = N'E:\forex\MSSQL\forex.bak'
     WITH RECOVERY,
     FILE=1,
     MOVE 'forex' TO 'E:\forex\MSSQL\data\forex.mdf',
     MOVE 'forex_log' TO 'E:\forex\MSSQL\data\forex_log.ldf'
GO

/*
-- разрешить выполнение xp_cmdshell:
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO
*/





------------------------------
select * from forex..ntAverageValuesResults (nolock) order by idn desc -- рассчитанные общие показатели (за все время)

-- восстанавливаем БД (если помечена как suspect (подозрительная))
ALTER DATABASE forex SET EMERGENCY
ALTER DATABASE forex SET SINGLE_USER
DBCC CHECKDB ('forex', REPAIR_ALLOW_DATA_LOSS)
ALTER DATABASE forex SET MULTI_USER 
