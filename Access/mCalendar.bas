Attribute VB_Name = "mCalendar"
'Option Compare Database
Option Explicit


Sub CalcCalendarIdnData()

' ��������� ��� ������ ������ �� �������� ���������

Dim SQLString As String

Call WriteLog("�������� ������ ������� ���������")


'    SQLString = "delete from ntCalendarIdnData where ParamsIdentifyer = '" & ParamsIdentifyer & "'"
'    DB.Execute SQLString, dbSeeChanges + dbFailOnError
 
'    SQLString = "insert into ntCalendarIdnData (idnDataEventdates, cdatetimeFromEventdates, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus, ParamsIdentifyer) "
'    SQLString = SQLString & " SELECT cidn, cdatetime, cName, cCountry, cVolatility, cActual, cPrevious, cConsensus, '" & ParamsIdentifyer & "'"
'    SQLString = SQLString & " from ntImportEventdates where cName like  '" & strCalendarNewsName & "' and ccountry like '" & strCalendarCountryName & "' "
'    SQLString = SQLString & " order by cidn "
    
'Application.SetOption "Confirm Action Queries", False
'DoCmd.RunSQL SQLString
 

Call WriteLog("�������� ���������� idn �����, �� ������� ����������� ������� ���������")

SQLString = "exec ntpCalcCalendarIdnDataCCLOSE '" & ParamsIdentifyer & "'"
Call ExecProcedureMSSQL(SQLString)

' ������ ������ ��� idn � ccorr ��� ��������� � ������� tCorrResults
    
Call WriteLog("������� " & tCorrResults & " �� SQL Server ��������� (1)")


' ��������� ������� tCorrResultsReport �� SQL Server
'Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & 10000 & ",'" & ParamsIdentifyer & "'") ' �� ��������� �� DeltaMinutesCalcCorr
'Call WriteLog("����� exec " & pCorrResultsReport)
Call ExecProcedureMSSQL("exec " & pCorrResultsReport & " " & 10000 & ",'" & ParamsIdentifyer & "' ,'" & ParamsIdentifyer & "'") ' �� ��������� �� DeltaMinutesCalcCorr, �.�. ��� �������� ������ ������ ������
Call WriteLog("����� exec " & pCorrResultsReport)











    
End Sub


Sub CalcCalendar_quick()

' ������ ������� ��� ������ ������� ���������
' ������ ����������� ��������� - ��. ������� ntCalendarIdnData (����� ���������� ��������� CalcCalendarIdnData)

'---------------------
'�� ������ � �����
Set DB = Access.CurrentDb
DataSourceId = 2
CurrencyId_history = 5 ' CurrencyId ������ ������������ ������ (� �������� ����������)
PeriodMinutes = 5 ' ������ ������ � �������
PeriodMultiplicatorForCalendar = 1
tCorrResults = "ntCorrResults"

' ������ ����������� ��������� - ��. ������� ntCalendarIdnData (����� ���������� ��������� CalcCalendarIdnData)
'strCalendarNewsName = "Fed Interest Rate Decision*" ' ����� ���������� � ���������
'strCalendarCountryName = "United States" ' ������, �� ������� ������� ���������� � ���������

strCalendarNewsName = "BoC Interest Rate Decision*" ' ����� ���������� � ���������
strCalendarCountryName = "Canada" ' ������, �� ������� ������� ���������� � ���������


'---------------------



Call CalcCalendarIdnData


End Sub

