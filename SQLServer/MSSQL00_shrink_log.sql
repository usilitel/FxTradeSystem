
-- урезаем размер файла лога
-- http://www.itworkroom.com/?p=9907

USE forex
ALTER DATABASE forex SET RECOVERY SIMPLE
DBCC SHRINKFILE ('forex_log', 1000); -- размер лога в MB (3 610 816 КБ)
ALTER DATABASE forex SET RECOVERY FULL