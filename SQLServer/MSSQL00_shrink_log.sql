
-- ������� ������ ����� ����
-- http://www.itworkroom.com/?p=9907

USE forex
ALTER DATABASE forex SET RECOVERY SIMPLE
DBCC SHRINKFILE ('forex_log', 1000); -- ������ ���� � MB (3 610 816 ��)
ALTER DATABASE forex SET RECOVERY FULL