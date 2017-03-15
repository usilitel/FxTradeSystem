Attribute VB_Name = "mCalendar"
'Option Compare Database
Option Explicit


Sub CalcCalendarIdnData()

' процедура для отбора данных по событиям календаря

Dim SQLString As String

Call WriteLog("Отбираем нужные события календаря")


'    SQLString = "delete from ntCalendarIdnData where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
'    DB.Execute SQLString, dbSeeChanges + dbFailOnError
 
'    SQLString = "insert into ntCalendarIdnData (idnDataEventdates, cdatetimeFromEventdates, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus, ParamsIdentifyer) "
'    SQLString = SQLString & " SELECT cidn, cdatetime, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus, '" & ParamsIdentifyer & "'"
'    SQLString = SQLString & " from ntImportEventdates where cName like  '" & strCalendarNewsName & "' and ccountry like '" & strCalendarCountryName & "' "
'    SQLString = SQLString & " order by cidn "
    
'Application.SetOption "Confirm Action Queries", False
'DoCmd.RunSQL SQLString
 

Call WriteLog("Начинаем вычисление idn баров, на которых происходили события календаря")

SQLString = "exec ntpCalcCalendarIdnDataCCLOSE '" & ParamsIdentifyer & "'"
Call ExecProcedureMSSQL(SQLString)

' теперь нужные нам idn и ccorr уже находятся в таблице tCorrResults
    
Call WriteLog("таблица " & tCorrResults & " на SQL Server заполнена (1)")


' заполняем таблицу tCorrResultsReport на SQL Server
'Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & 10000 & ",'" & ParamsIdentifyer & "'") ' не сортируем по DeltaMinutesCalcCorr
'Call WriteLog("конец exec " & pCorrResultsReport)
Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & 10000 & ",'" & ParamsIdentifyer & "' ,'" & ParamsIdentifyer & "'") ' НЕ сортируем по DeltaMinutesCalcCorr, т.к. уже отобрали только нужные данные
Call WriteLog("конец exec " & pCorrResultsReport)











    
End Sub


Sub CalcCalendar_quick()

' запуск расчета для вывода событий календаря
' список показателей календаря - см. таблицу ntCalendarIdnData (после выполнения процедуры CalcCalendarIdnData)

'---------------------
'не делать в реале
Set DB = Access.CurrentDb
DataSourceId = 2
CurrencyId_history = 5 ' CurrencyId валюты исторических данных (с которыми сравниваем)
PeriodMinutes = 5 ' период данных в минутах
PeriodMultiplicatorForCalendar = 1
tCorrResults = "ntCorrResults"

' список показателей календаря - см. таблицу ntCalendarIdnData (после выполнения процедуры CalcCalendarIdnData)
'strCalendarNewsName = "Fed Interest Rate Decision*" ' текст показателя в календаре
'strCalendarCountryName = "United States" ' страна, по которой выходит показатель в календаре

strCalendarNewsName = "BoC Interest Rate Decision*" ' текст показателя в календаре
strCalendarCountryName = "Canada" ' страна, по которой выходит показатель в календаре


'---------------------



Call CalcCalendarIdnData


End Sub

