Attribute VB_Name = "mDeclare"
Option Explicit


Public arrDataHistory() ' ��������������� ������ � ������������� �������
Public arrCclose() 'As Double ' ������ � cclose �� ������������ ������
'Public arrIDN() 'As Double ' ������ � IDN �� ������������ ������
Public arrIDNSorted() ' ��������������� ������ � IDN �� ������������ ������
Public arrCORR() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (cclose)
Public arrCORRABV() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (ABV)
Public arrCORRABVMini() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (ABVMini)
Public arrCORREasy() 'As Double ' ������ � ������������ ����������� (KEasy) �� ������������ ������ (cclose)
Public arrCORREasyABV() 'As Double ' ������ � ������������ ����������� (KEasy) �� ������������ ������ (ABV)
Public arrCORREasyABVMini() 'As Double ' ������ � ������������ ����������� (KEasy) �� ������������ ������ (ABVMini)
Public arrCORRMAVolume() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (MAVolume)
Public arrCORRPreviousDay() 'As Double ' ������ � ������������ ����������� �� ���������� ����(cclose)
Public arrCORRTotal() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (�����)

Public arrABV() 'As Double ' ������ � ABV �� ������������ ������
Public arrABVIDN() ' ������ � IDN ABV �� ������������ ������
Public arrABVMini() 'As Double ' ������ � ABVMini �� ������������ ������
Public arrABVMiniIDN() ' ������ � IDN ABVMini �� ������������ ������
'Public arrVolume() ' ������ � Volume �� ������������ ������
Public arrMAVolume() ' ������ � MA(Volume) �� ������������ ������
Public arrMAVolumeIDN() ' ������ � IDN MA(Volume) �� ������������ ������
Public arrPreviousDay() ' ������ � cclose �� ���������� ���� �� ������������ ������
Public arrPreviousDayIDN() ' ������ � cclose �� ���������� ���� �� ������������ ������
Public arrCdate() 'As Double ' ������ � Cdate �� ������������ ������
Public arrCdateIDN() ' ������ � IDN Cdate �� ������������ ������



Public arrCclosePosition() 'As Double ' ������ � CclosePosition �� ������������ ������
'Public arrCcloseTimeInMinutes() 'As Double ' ������ � �������� cclose (���������� ����� � ������ ���)
Public arrCcloseDate() 'As Double ' ������ � ������ cclose

Public DB As DAO.Database
Public rstTemp As DAO.Recordset
Public rstTemp2 As DAO.Recordset
Public rstTemp3 As DAO.Recordset
Public rstTemp4 As DAO.Recordset
Public rstTemp5 As DAO.Recordset
Public rstPeriodsParameters As DAO.Recordset
Public StartTime As Long
Public TotalTime As Long
Public tblDataHistory As String
Public cntDataHistoryRows As Long




Public cDateTimeFirst As String ' ����� ������ ������� �
Public cDateTimeLast As String ' �����, �� ������� ������� � � ������ �������
Public cDateTimeFirstTemp As String ' ��������� ����������
Public cDateTimeLastTemp As String ' ��������� ����������
Public cDateTimeCalc As String ' ��������� ����������
Public cDateTimeCalcAsDate As Date ' ��������� ����������

Public cTimeFirstCalc As String ' ��������� ����������
Public cTimeLastCalc As String ' ��������� ����������
Public cTimeFirst As String ' ����� ������ ������� �
Public cTimeLast As String ' �����, �� ������� ������� � � ������ �������
Public cDateCalc As String ' ��������� ����������






Public arrDataCurrentAll() ' ��������������� ������ � �������� �������
Public arrDataCurrentCompare() As Double ' ������ � cclose �� ������� ������
Public arrDataHistoryCompare() As Double ' ������-���� � cclose �� ������������ ������
Public arrDataCurrentCompareABV() As Double ' ������ � ABV �� ������� ������
Public arrDataHistoryCompareABV() As Double ' ������-���� � ABV �� ������������ ������
Public arrDataCurrentCompareABVMini() As Double ' ������ � ABVMini �� ������� ������
Public arrDataHistoryCompareABVMini() As Double ' ������-���� � ABVMini �� ������������ ������
Public arrDataCurrentCompareMAVolume() As Double ' ������ � MAVolume �� ������� ������
Public arrDataHistoryCompareMAVolume() As Double ' ������-���� � MAVolume �� ������������ ������
Public arrDataCurrentComparePreviousDay() As Double ' ������ � cclose �� ���������� ���� �� ������� ������
Public arrDataHistoryComparePreviousDay() As Double ' ������-���� � cclose �� ���������� ���� �� ������������ ������

'---------------------
'������ KEasy (� �� ����������� ���������)

Public arrDataCurrentCompareEasy() As Double ' ������ � cclose �� ������� ������
Public arrDataCurrentCompareEasyRanges() As Double ' ������ �� ���������� ���������� �� �������� �������
Public arrDataHistoryCompareEasy() As Double ' ������-���� � cclose �� ������������ ������
Public arrDataHistoryCompareEasyRanges() As Double ' ������-���� �� ���������� ���������� cclose �� ������������ ������

'---------------------
'������� ��� ������ ������� ���������

Public IsCalcCalendar As Integer ' 1 - ���� ������� � ���������, 0 - ������� ������ �
Public PeriodMultiplicatorForCalendar As Integer ' ��������� �������, ������� ����� ��� ������ ������� � ���������

Public strCalendarNewsName As String ' ����� ���������� � ���������
Public strCalendarCountryName As String ' ������, �� ������� ������� ���������� � ���������

'---------------------

' ������ �������

Public CcorrMax As Double ' ������������ �������� �
Public CcorrAvg As Double ' ������� �������� �
Public TakeProfit_isOk_Daily_up_AvgCnt As Double ' ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������)
Public TakeProfit_isOk_Daily_down_AvgCnt As Double ' ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������)
Public TakeProfit_isOk_Daily_up_PrcBars As Double ' (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
Public TakeProfit_isOk_Daily_down_PrcBars As Double ' (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������)
Public TakeProfit_isOk_AtOnce_up_AvgCnt As Double ' ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������)
Public TakeProfit_isOk_AtOnce_down_AvgCnt As Double ' ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������)
Public ChighMax_Daily_Avg As Double ' ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������)
Public ClowMin_Daily_Avg As Double ' ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������)
Public ChighMax_AtOnce_Avg As Double ' ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������)
Public ClowMin_AtOnce_Avg As Double ' ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������)

'Public TakeProfit_isOk_Daily_up_AvgCnt_nd As Double ' ���-�� ������������ TakeProfit �� ����� ��� ����� (������� ��������) � ������ ���������� ���
'Public TakeProfit_isOk_Daily_down_AvgCnt_nd As Double ' ���-�� ������������ TakeProfit �� ����� ��� ���� (������� ��������) � ������ ���������� ���
'Public TakeProfit_isOk_Daily_up_PrcBars_nd As Double ' (���-�� ����� �� ������� TakeProfit �����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������) � ������ ���������� ���
'Public TakeProfit_isOk_Daily_down_PrcBars_nd As Double ' (���-�� ����� �� ������� TakeProfit ����)/(���-�� ����� �� ����� ���) (������� �������� �� ���� ���������) � ������ ���������� ���
Public TakeProfit_isOk_AtOnce_up_AvgCnt_nd As Double ' ���-�� ������������ TakeProfit ����� ����� (��� ����-�����) (������� ��������) � ������ ���������� ���
Public TakeProfit_isOk_AtOnce_down_AvgCnt_nd As Double ' ���-�� ������������ TakeProfit ����� ���� (��� ����-�����) (������� ��������) � ������ ���������� ���
'Public ChighMax_Daily_Avg_nd As Double ' ������� ������������ ���������� ����� �� ������� ���� �� ����� ��� (���-�� �������) � ������ ���������� ���
'Public ClowMin_Daily_Avg_nd As Double ' ������� ������������ ���������� ���� �� ������� ���� �� ����� ��� (���-�� �������) � ������ ���������� ���
Public ChighMax_AtOnce_Avg_nd As Double ' ������� ������������ ���������� ����� �� ������� ���� ����� (��� ����-�����) (���-�� �������) � ������ ���������� ���
Public ClowMin_AtOnce_Avg_nd As Double ' ������� ������������ ���������� ���� �� ������� ���� ����� (��� ����-�����) (���-�� �������) � ������ ���������� ���


Public TakeProfit_isOk_AtOnce_AvgCnt_delta_alert As Double ' ����������� ������� ����� TakeProfit_isOk_AtOnce_up_AvgCnt � TakeProfit_isOk_AtOnce_down_AvgCnt, ��� ������� ��������� �����
Public TakeProfit_isOk_AtOnce_AvgCnt_limit_alert As Double ' ����������� �������� TakeProfit_isOk_AtOnce_up_AvgCnt ��� TakeProfit_isOk_AtOnce_down_AvgCnt, ��� ������� ��������� �����

Public CPoints_AtOnce_Avg_delta_alert As Double ' ����������� ������� ����� ChighMax_AtOnce_Avg � ClowMin_AtOnce_Avg, ��� ������� ��������� �����
Public CPoints_AtOnce_Avg_limit_alert As Double ' ����������� �������� ChighMax_AtOnce_Avg ��� ClowMin_AtOnce_Avg, ��� ������� ��������� �����

Public isCalcAverageValuesInPercents As Double ' 1 - ������� ����������� �������� � ��������� �� ����, 0 - ������� � �������

'---------------------

'Public tblDataCurrentRealTime As String
Public SourceFilePath As String
Public SourceFileNameCurrentRealTime As String
Public SourceFileNameCurrent As String
Public tblDataCurrent As String
Public tblDataCurrentChart As String
Public tblDataCurrentChartMSSQL As String
Public tblDataCurrentBufer As String ' �������� �������, � ������� ���������� ������ ������ ������� ������ (�.�. �� ������, �� ������� ������� �)
Public tblDataCurrentMSSQL As String
Public cntDataCurrentRows As Long
Public tblDataCurrentNoAverageValuesMSSQL As String
Public tblDataCurrentDDE As String
Public tblDataCurrentDDEBufer As String

Public v1 As Double
Public v2 As Double
Public v3 As Double
Public v4 As Double
Public v5 As Double
Public v6 As Double
Public v7 As Double
Public v8 As Double
Public v9 As Double
Public v10 As Double
Public v11 As Double
Public v12 As Double
Public v13 As Double
Public v14 As Double
Public v15 As Double
Public v16 As Double
Public v17 As Double
Public v18 As Double
Public v19 As Double
Public v20 As Double
Public v21 As Double
'Public v22 As Double
'Public v23 As Double

Public pCountCharts As Integer
Public pbarsBefore As Integer
Public pbarsTotal As Integer
Public strExcelFileExport As String

Public pCorrResultsReport As String
Public pCorrResultsPeriodsData As String
'Public pCorrResultsAverageValues As String
Public tCorrResultsPeriodsData As String
Public tCorrResults As String
Public tCorrResultsBufer As String
'Public pImportCurrentChartAverageValues As String

Public DataSourceId As Integer
'Public DataSourceIdLast As Integer ' ��������� ������������ DataSourceId
Public cntRowsCorr As Long
Public SortByABMmPosition1Prev As Integer
Public SortByABMmPosition1Curr As Integer
Public SortBack As Integer ' 0 - ���������� � � ������ �������, 1 - � ��������
Public IsInverse As Integer ' 0 - ������ ���� ������ (EURUSD), 1 - �������� (USDCAD)

'Public IsCalcCorrOnlyForSameTime As Integer ' 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
'Public DeltaMinutesCalcCorr As Integer ' ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �
Public CurrentBarTimeInMinutes As Integer ' ����� �������� ���� (� ������� � ������ ���)




Public CurrPathAccess As String
Public IsExportToExcelCurrent As Integer
Public IsExportToExcelHistory As Integer
Public IsOpenExcelCurrent As Integer
Public IsOpenExcelHistory As Integer

'Public idValueArray As Integer

Public WeightCORR As Double ' ��� �(cclose) � ����� �
Public WeightCORRABV As Double ' ��� �(ABV) � ����� �
Public WeightCORRABVMini As Double ' ��� �(ABVMini) � ����� �
Public WeightCORREasyCclose As Double ' ��� �Easy(cclose) (�, ������������ �� ����������� ���������), � ����� �
Public WeightCORREasyABV As Double ' ��� �(ABV) (�, ������������ �� ����������� ���������) � ����� �
Public WeightCORREasyABVMini As Double ' ��� �(ABVMini) (�, ������������ �� ����������� ���������) � ����� �
Public WeightCORRMAVolume As Double ' ��� �(MAVolume) � ����� �
Public WeightCORRPreviousDay As Double ' ��� �(cclose �� ���������� ����) � ����� �

Public MAVolumePeriod As Integer ' ������ MA(Volume) (�� ������� ������� �)

Public MACclosePeriod As Integer ' ������ MA(Cclose) (�� ������� ������� �)
Public MAABVPeriod As Integer ' ������ MA(ABV) (�� ������� ������� �)
Public MAABVMiniPeriod As Integer ' ������ MA(ABVMini) (�� ������� ������� �)
Public MACclosePreviousDayPeriod As Integer ' ������ MA(Cclose �� ���������� ����) (�� ������� ������� �)



Public ExcelFileNameHistory As String
Public ExcelFileNameCurrent As String

'Private Declare Function GetTickCount Lib "kernel32" () As Long
Public Declare Function GetTickCount Lib "kernel32" () As Long
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

'Public Declare Function RemoveDirectory& Lib "kernel32" Alias "RemoveDirectoryA" (ByVal lpPathName As String)
     
'Public Const INFINITE = &HFFFF
'Public Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
'Public Declare Function OpenProcess Lib "kernel32" (ByVal dwAccess As Long, ByVal fInherit As Integer, ByVal hObject As Long) As Long


Public vCcloseMin As Double ' ����������� cclose � ���� ������
Public vCcloseMax As Double ' ������������ cclose � ���� ������
Public vCcloseEnd As Double ' �������� cclose � ���� ������
Public vCclosePosition As Double ' ��������� cclose ����� vCcloseMin � vCcloseMax � ���� ������ (0 = vCcloseMin, 1 = vCcloseMax)
Public vCclosePositionCurrent As Double ' ��������� cclose ����� vCcloseMin � vCcloseMax � ������� ������ (0 = vCcloseMin, 1 = vCcloseMax)
Public vCclosePositionDelta As Double ' ���������� ���������� ��������� cclose � ��������� ��� ������� �
Public IsCalcCclosePosition As Integer ' 1 - ������� CclosePosition, 0 - �� �������

' ��������� ��� ������� ����� ����������� �� ������� ���������
Public cntCharts As Integer ' ���������� ������� ��������, ������� ����� ��� �������
Public StopLoss As Integer ' StopLoss � �������
Public TakeProfit As Integer ' TakeProfit � �������
Public OnePoint As Double ' �������� ������ ������ � ����
Public cDateTimeFirstCalc As String ' ����� ������ ������� ����� �����������
Public cDateTimeLastCalc As String ' ����� ��������� ������� ����� �����������
Public CurrencyId_current As Integer ' CurrencyId ������ ������� ������
Public CurrencyId_history As Integer ' CurrencyId ������ ������������ ������ (� �������� ����������)
Public PeriodMinutes As Integer
Public CurrencyNTName_current As String


Public objExcelCurrent As Object
Public objExcelHistory As Object

Public ParamsIdentifyer As String

Public isLogTables As Integer ' 1 - ���������� �������

Public CurrDBName As String ' ��� ������� ��

Public cntDaysPreviousShowABV As Integer ' ���������� ���������� ����, �� ������� ���������� ABV �� ������� (1 - ���������� ������ �� ������� ����)

Public cntBarsCalcCorr As Integer ' ���������� �����, �� ������� ������� � (0 - �������� ��������� ����-�����)
Public cntBarsCalcCorr_cn As Integer ' ���������� �����, �� ������� ������� � (0 - �������� ��������� ����-�����)

Public pExcelWindowState As Integer ' 1 = ������������� ���� Excel, 2 = ����������� ����, 3 = ������ �� ������, 4 = �����������, �� ��� ����������� ������ �������������

Public isSendEmailOnAlert As Integer ' 1 - �������� email ��� ������
Public isSendSmsOnAlert As Integer ' 1 - �������� sms ��� ������
Public isCountAverageValuesWithNextDay As Integer ' 1 - ������������ ����� ���������� (������������ ������, �����/����) � ������ ���������� ���, 0 - ������������ ����� ���������� ������ � �������� �������� ���

Public AlertStrBody As String ' ����� ��������� ��� ������ (���������� � email/sms)



'Public DeltaCcloseRangeMaxLimit As Single ' ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
'Public DeltaCcloseRangeMinLimit As Single ' ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)

Public cdatePreviousDay As String '  ���������� ����
Public cTimePreviousDayFirst As String ' �����, ������� � �������� ������� � �� ���������� ����
Public cTimePreviousDayLast As String '  �����, ���������� ������� ������� � �� ���������� ����
Public cTimeInMinutesPreviousDayFirst As String ' ����� � �������, ������� � �������� ������� � �� ���������� ����
Public cTimeInMinutesPreviousDayLast As String '  ����� � �������, ���������� ������� ������� � �� ���������� ����
Public cDateTimePreviousDayFirst As String ' ����-�����, ������� � ������� ������� � �� ���������� ����
Public cDateTimePreviousDayLast As String '  ����-�����, ���������� ������� ������� � �� ���������� ����

Public cntDataPreviousDayRows As Long

Public CcorrPreviousDayMax As Single
Public CcorrCurrentDayMax As Single
Public cDateLastStep As String

Public CurrentDayCntBarsMinLimit As Single ' ����������� ���������� �����, ������� ����� ���� � ��������� ���




'------------------------
Public PeriodMinutes_cn As Integer    ' ������ ������ � �������, �� �������� ���� ������� �
    
Public FieldNumCurrent_cn As Integer    ' ����� ������� (������� � 0) � ������� tblDataCurrent, �� �������� ������� �
Public FieldNumHistory_cn As Integer    ' ����� ������� (������� � 0) � ������� � ��������, �� �������� ������� �
    
Public idAlgorithmCalcCorr_cn As Integer    ' �������� ������� �: 1 - �������, 2 - ���������� (CalcCorrelationEasy)
    

    ' ��������� ��� ����������� �������� ����� ������� �
Public cTimeLast_cn As String    ' �����, �� ������� ������� � (���� �� �������, �� ����� ntSettingsFilesParameters_cn.cDateTimeLast)
Public cntDaysAgoLast_cn As Integer    ' ���������� ���� ����� �� ���� ntSettingsFilesParameters_cn.cDateTimeCalc

    ' ��������� ��� ����������� ��������� ����� ������� �
Public cTimeFirst_cn As String    ' �����, ������� � �������� ������� � (���� �� �������, �� ����� ntSettingsFilesParameters_cn.cDateTimeFirst)
Public cntDaysAgoFirst_cn As Integer    ' ���������� ���� ����� �� �������� ����� ������� �


Public WeightCORR_cn As Double     ' ��� � �� ������� ������� � ����� �
Public WeightCORR_cn_sum As Double     ' ��� � �� ������� ������� � ����� �

Public MAPeriod_cn As Integer    ' ������ MA (�� ������� ������� �)
    
Public DeltaCcloseRangeMaxLimit_cn As Single    ' ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
Public DeltaCcloseRangeMinLimit_cn As Single    ' ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)

Public IsCalcCorrOnlyForSameTime_cn As Integer    ' 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
Public DeltaMinutesCalcCorr_cn As Integer    ' ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �

Public IsCalcCclosePosition_cn As Integer    ' 1 - ������� CclosePosition, 0 - �� �������
Public vCclosePositionDelta_cn As Double    ' ���������� ���������� ��������� cclose � ��������� ��� ������� �


Public CntBarsMinLimit_cn As Integer    ' ����������� ���������� �����, ������� ����� ���� � ��������� ���

'--


Public tblDataHistory_cn As String
Public tblDataCurrent_cn As String
Public arrDataHistory_cn() ' ��������������� ������ � ������������� �������
Public arrDataCurrent_cn() ' ��������������� ������ � �������� �������
Public cntDataHistoryRows_cn As Long
Public cntDataCurrentRows_cn As Long
    
Public arrCclose_cn() As Double ' ������ � cclose �� ������� ������
Public arrCorr_cn() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (cclose)
Public arrCorrMaxForDates_cn() 'As Double ' ������ � ������������ � �� ���� (1-� ������� - ����, 2-� ������� - ������������ �)

Public cDateTimeFirst_cn As String ' ����� ������ ������� �
Public cDateTimeLast_cn As String ' ����� ��������� ������� �
Public cDateCalcFirst_cn As String ' ��������� ����������
Public cDateCalcLast_cn As String ' ��������� ����������

Public SourceFileNameCurrentRealTime_cn As String
Public SourceFileNameCurrent_cn As String

Public arrCcloseTimeInMinutes_cn() 'As Double ' ������ � �������� cclose (���������� ����� � ������ ���)


Public arrCdateTime() 'As Double ' ������ � CdateTime �� ������������ ������ (��� �������)
Public arrCdateTime_cn() 'As Double ' ������ � CdateTime �� ������������ ������ (��� n-�� ������� �)



Public IsExportToTxtCurrent As Integer
Public IsExportToTxtHistory As Integer
Public strTxtFileExport As String

Public iNum As Double

Public ctime_CalcAverageValuesWithNextDay As String ' �����, ������� � �������� ������������ ����� ���������� � ������ ���������� ��������� ���
Public CntBarsMinLimit As Integer ' ����������� ���������� �����, ������� ����� ���� � �������� ��� (����� ��� ���������� ���������� ��������� ���)

Public arrDataHistory_cn_filled As Integer ' 1 - ������������ ������� ��� ������� _cn ���������
Public tblDataHistory_cn_previous As String

Public MdbFileId As String ' MdbFileId = ��������� ������ � ����� mdb-�����





Public DeltaCcloseRangeMaxLimit As Single ' ������������ ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)
Public DeltaCcloseRangeMinLimit As Single ' ����������� ������� � ��������� ���� ������� � ������������ ������ (0 - �� ��������� ��� �������)

Public IsCalcCorrOnlyForSameTime As Integer ' 1 - ������� � ������ ��� �����, � ������� ����� ����� ������� �������� ���� +- DeltaMinutesCalcCorr, 0 - ������� � ��� ���� �����
Public DeltaMinutesCalcCorr As Integer ' ���������� ����� � �� � ������ ������� ������������ �������� ����, ��� ������� ������� �

Public CalcCorrParamsId As String ' ������������� ���������� ������� �

    
    
Public isCalcCorr1 As Integer ' 1 = ������� �, 0 = �� ������� � (�.�. ��� ��������� �� ������� ParamsIdentifyer)
    
Public cdate_current As String ' ����, �� ������� ��������� �
    
Public is_makeDeals_RealTrade As Integer ' 1 - ��������� ������

Public cntSourceFiles As Integer ' ���������� �������� ��������� ������

    
'Public ArrValueFirst As Double
'Public ArrValueFirstPrevious As Double
'Public ArrValueMin As Double
'Public ArrValueMinPrevious As Double
'Public arrHistoryRemoved As Double

'Public arrIDNSorted_cn() ' ��������������� ������ � IDN �� ������������ ������
'Public arrIDN_cn() 'As Double ' ������ � IDN �� ������������ ������

'Public arrIDN_cn() 'As Double ' ������ � IDN �� ������� ������
'Public arrCdate_cn() 'As Double ' ������ � Cdate �� ������� ������

'Public rstCurrentData_cn As DAO.Recordset

'-------------------
'���������:
'Public WeightCORRMAVolume As Double ' ��� �(MAVolume) � ����� �
'Public MAVolumePeriod As Integer ' ������ MA(Volume) (�� ������� ������� �)


'Public arrCORRMAVolume() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (MAVolume)
'Public arrMAVolume() ' ������ � MA(Volume) �� ������������ ������
'Public arrMAVolumeIDN() ' ������ � IDN MA(Volume) �� ������������ ������
'Public arrDataCurrentCompareMAVolume() As Double ' ������ � MAVolume �� ������� ������
'Public arrDataHistoryCompareMAVolume() As Double ' ������-���� � MAVolume �� ������������ ������


'Public arrCORRABVMini() 'As Double ' ������ � ������������ ����������� �� ������������ ������ (ABVMini)
'Public arrABVMini() 'As Double ' ������ � ABVMini �� ������������ ������
'Public arrABVMiniIDN() ' ������ � IDN ABVMini �� ������������ ������
'Public arrDataCurrentCompareABVMini() As Double ' ������ � ABVMini �� ������� ������
'Public arrDataHistoryCompareABVMini() As Double ' ������-���� � ABVMini �� ������������ ������

