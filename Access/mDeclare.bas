Attribute VB_Name = "mDeclare"
Option Explicit


Public arrDataHistory() ' вспомогательный массив с историческими данными
Public arrCclose() 'As Double ' массив с cclose по историческим данным
'Public arrIDN() 'As Double ' массив с IDN по историческим данным
Public arrIDNSorted() ' отсортированный массив с IDN по историческим данным
Public arrCORR() 'As Double ' массив с рассчитанной корреляцией по историческим данным (cclose)
Public arrCORRABV() 'As Double ' массив с рассчитанной корреляцией по историческим данным (ABV)
Public arrCORRABVMini() 'As Double ' массив с рассчитанной корреляцией по историческим данным (ABVMini)
Public arrCORREasy() 'As Double ' массив с рассчитанной корреляцией (KEasy) по историческим данным (cclose)
Public arrCORREasyABV() 'As Double ' массив с рассчитанной корреляцией (KEasy) по историческим данным (ABV)
Public arrCORREasyABVMini() 'As Double ' массив с рассчитанной корреляцией (KEasy) по историческим данным (ABVMini)
Public arrCORRMAVolume() 'As Double ' массив с рассчитанной корреляцией по историческим данным (MAVolume)
Public arrCORRPreviousDay() 'As Double ' массив с рассчитанной корреляцией за предыдущий день(cclose)
Public arrCORRTotal() 'As Double ' массив с рассчитанной корреляцией по историческим данным (общая)

Public arrABV() 'As Double ' массив с ABV по историческим данным
Public arrABVIDN() ' массив с IDN ABV по историческим данным
Public arrABVMini() 'As Double ' массив с ABVMini по историческим данным
Public arrABVMiniIDN() ' массив с IDN ABVMini по историческим данным
'Public arrVolume() ' массив с Volume по историческим данным
Public arrMAVolume() ' массив с MA(Volume) по историческим данным
Public arrMAVolumeIDN() ' массив с IDN MA(Volume) по историческим данным
Public arrPreviousDay() ' массив с cclose за предыдущий день по историческим данным
Public arrPreviousDayIDN() ' массив с cclose за предыдущий день по историческим данным
Public arrCdate() 'As Double ' массив с Cdate по историческим данным
Public arrCdateIDN() ' массив с IDN Cdate по историческим данным



Public arrCclosePosition() 'As Double ' массив с CclosePosition по историческим данным
'Public arrCcloseTimeInMinutes() 'As Double ' массив с временем cclose (количество минут с начала дня)
Public arrCcloseDate() 'As Double ' массив с датами cclose

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




Public cDateTimeFirst As String ' время начала расчета К
Public cDateTimeLast As String ' время, на которое считаем К и строим графики
Public cDateTimeFirstTemp As String ' временная переменная
Public cDateTimeLastTemp As String ' временная переменная
Public cDateTimeCalc As String ' временная переменная
Public cDateTimeCalcAsDate As Date ' временная переменная

Public cTimeFirstCalc As String ' временная переменная
Public cTimeLastCalc As String ' временная переменная
Public cTimeFirst As String ' время начала расчета К
Public cTimeLast As String ' время, на которое считаем К и строим графики
Public cDateCalc As String ' временная переменная






Public arrDataCurrentAll() ' вспомогательный массив с текущими данными
Public arrDataCurrentCompare() As Double ' массив с cclose по текущим данным
Public arrDataHistoryCompare() As Double ' массив-окно с cclose по историческим данным
Public arrDataCurrentCompareABV() As Double ' массив с ABV по текущим данным
Public arrDataHistoryCompareABV() As Double ' массив-окно с ABV по историческим данным
Public arrDataCurrentCompareABVMini() As Double ' массив с ABVMini по текущим данным
Public arrDataHistoryCompareABVMini() As Double ' массив-окно с ABVMini по историческим данным
Public arrDataCurrentCompareMAVolume() As Double ' массив с MAVolume по текущим данным
Public arrDataHistoryCompareMAVolume() As Double ' массив-окно с MAVolume по историческим данным
Public arrDataCurrentComparePreviousDay() As Double ' массив с cclose за предыдущий день по текущим данным
Public arrDataHistoryComparePreviousDay() As Double ' массив-окно с cclose за предыдущий день по историческим данным

'---------------------
'расчет KEasy (К по упрощенному алгоритму)

Public arrDataCurrentCompareEasy() As Double ' массив с cclose по текущим данным
Public arrDataCurrentCompareEasyRanges() As Double ' массив со значениями отклонений по текущими данными
Public arrDataHistoryCompareEasy() As Double ' массив-окно с cclose по историческим данным
Public arrDataHistoryCompareEasyRanges() As Double ' массив-окно со значениями отклонений cclose по историческим данным

'---------------------
'расчеты для вывода событий календаря

Public IsCalcCalendar As Integer ' 1 - ищем события в календаре, 0 - обычный расчет К
Public PeriodMultiplicatorForCalendar As Integer ' множитель периода, который берем для поиска событий в календаре

Public strCalendarNewsName As String ' текст показателя в календаре
Public strCalendarCountryName As String ' страна, по которой выходит показатель в календаре

'---------------------

' расчет алертов

Public CcorrMax As Double ' максимальное значение К
Public CcorrAvg As Double ' среднее значение К
Public TakeProfit_isOk_Daily_up_AvgCnt As Double ' кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций)
Public TakeProfit_isOk_Daily_down_AvgCnt As Double ' кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций)
Public TakeProfit_isOk_Daily_up_PrcBars As Double ' (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
Public TakeProfit_isOk_Daily_down_PrcBars As Double ' (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям)
Public TakeProfit_isOk_AtOnce_up_AvgCnt As Double ' кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций)
Public TakeProfit_isOk_AtOnce_down_AvgCnt As Double ' кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций)
Public ChighMax_Daily_Avg As Double ' среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов)
Public ClowMin_Daily_Avg As Double ' среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов)
Public ChighMax_AtOnce_Avg As Double ' среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов)
Public ClowMin_AtOnce_Avg As Double ' среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов)

'Public TakeProfit_isOk_Daily_up_AvgCnt_nd As Double ' кол-во срабатываний TakeProfit до конца дня вверх (процент ситуаций) с учетом СЛЕДУЮЩЕГО дня
'Public TakeProfit_isOk_Daily_down_AvgCnt_nd As Double ' кол-во срабатываний TakeProfit до конца дня вниз (процент ситуаций) с учетом СЛЕДУЮЩЕГО дня
'Public TakeProfit_isOk_Daily_up_PrcBars_nd As Double ' (кол-во баров за уровнем TakeProfit вверх)/(кол-во баров до конца дня) (среднее значение по всем ситуациям) с учетом СЛЕДУЮЩЕГО дня
'Public TakeProfit_isOk_Daily_down_PrcBars_nd As Double ' (кол-во баров за уровнем TakeProfit вниз)/(кол-во баров до конца дня) (среднее значение по всем ситуациям) с учетом СЛЕДУЮЩЕГО дня
Public TakeProfit_isOk_AtOnce_up_AvgCnt_nd As Double ' кол-во срабатываний TakeProfit сразу вверх (без стоп-лосса) (процент ситуаций) с учетом СЛЕДУЮЩЕГО дня
Public TakeProfit_isOk_AtOnce_down_AvgCnt_nd As Double ' кол-во срабатываний TakeProfit сразу вниз (без стоп-лосса) (процент ситуаций) с учетом СЛЕДУЮЩЕГО дня
'Public ChighMax_Daily_Avg_nd As Double ' среднее максимальное отклонение вверх от текущей цены до конца дня (кол-во пунктов) с учетом СЛЕДУЮЩЕГО дня
'Public ClowMin_Daily_Avg_nd As Double ' среднее максимальное отклонение вниз от текущей цены до конца дня (кол-во пунктов) с учетом СЛЕДУЮЩЕГО дня
Public ChighMax_AtOnce_Avg_nd As Double ' среднее максимальное отклонение вверх от текущей цены сразу (без стоп-лосса) (кол-во пунктов) с учетом СЛЕДУЮЩЕГО дня
Public ClowMin_AtOnce_Avg_nd As Double ' среднее максимальное отклонение вниз от текущей цены сразу (без стоп-лосса) (кол-во пунктов) с учетом СЛЕДУЮЩЕГО дня


Public TakeProfit_isOk_AtOnce_AvgCnt_delta_alert As Double ' минимальная разница между TakeProfit_isOk_AtOnce_up_AvgCnt и TakeProfit_isOk_AtOnce_down_AvgCnt, при которой возникает алерт
Public TakeProfit_isOk_AtOnce_AvgCnt_limit_alert As Double ' минимальное значение TakeProfit_isOk_AtOnce_up_AvgCnt или TakeProfit_isOk_AtOnce_down_AvgCnt, при котором возникает алерт

Public CPoints_AtOnce_Avg_delta_alert As Double ' минимальная разница между ChighMax_AtOnce_Avg и ClowMin_AtOnce_Avg, при которой возникает алерт
Public CPoints_AtOnce_Avg_limit_alert As Double ' минимальное значение ChighMax_AtOnce_Avg или ClowMin_AtOnce_Avg, при котором возникает алерт

Public isCalcAverageValuesInPercents As Double ' 1 - считать вычисляемые величины в процентах от цены, 0 - считать в пунктах

'---------------------

'Public tblDataCurrentRealTime As String
Public SourceFilePath As String
Public SourceFileNameCurrentRealTime As String
Public SourceFileNameCurrent As String
Public tblDataCurrent As String
Public tblDataCurrentChart As String
Public tblDataCurrentChartMSSQL As String
Public tblDataCurrentBufer As String ' буферная таблица, в которой содержатся только нужные текущие данные (т.е. те данные, по которым считаем К)
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
'Public DataSourceIdLast As Integer ' последний рассчитанный DataSourceId
Public cntRowsCorr As Long
Public SortByABMmPosition1Prev As Integer
Public SortByABMmPosition1Curr As Integer
Public SortBack As Integer ' 0 - сортировка К в прямом порядке, 1 - в обратном
Public IsInverse As Integer ' 0 - график цены прямой (EURUSD), 1 - обратный (USDCAD)

'Public IsCalcCorrOnlyForSameTime As Integer ' 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
'Public DeltaMinutesCalcCorr As Integer ' количество минут в ту и другую сторону относительно текущего бара, для которых считаем К
Public CurrentBarTimeInMinutes As Integer ' время текущего бара (в минутах с начала дня)




Public CurrPathAccess As String
Public IsExportToExcelCurrent As Integer
Public IsExportToExcelHistory As Integer
Public IsOpenExcelCurrent As Integer
Public IsOpenExcelHistory As Integer

'Public idValueArray As Integer

Public WeightCORR As Double ' вес К(cclose) в общей К
Public WeightCORRABV As Double ' вес К(ABV) в общей К
Public WeightCORRABVMini As Double ' вес К(ABVMini) в общей К
Public WeightCORREasyCclose As Double ' вес КEasy(cclose) (К, рассчитанной по упрощенному алгоритму), в общей К
Public WeightCORREasyABV As Double ' вес К(ABV) (К, рассчитанной по упрощенному алгоритму) в общей К
Public WeightCORREasyABVMini As Double ' вес К(ABVMini) (К, рассчитанной по упрощенному алгоритму) в общей К
Public WeightCORRMAVolume As Double ' вес К(MAVolume) в общей К
Public WeightCORRPreviousDay As Double ' вес К(cclose за предыдущий день) в общей К

Public MAVolumePeriod As Integer ' период MA(Volume) (по которой считаем К)

Public MACclosePeriod As Integer ' период MA(Cclose) (по которой считаем К)
Public MAABVPeriod As Integer ' период MA(ABV) (по которой считаем К)
Public MAABVMiniPeriod As Integer ' период MA(ABVMini) (по которой считаем К)
Public MACclosePreviousDayPeriod As Integer ' период MA(Cclose за предыдущий день) (по которой считаем К)



Public ExcelFileNameHistory As String
Public ExcelFileNameCurrent As String

'Private Declare Function GetTickCount Lib "kernel32" () As Long
Public Declare Function GetTickCount Lib "kernel32" () As Long
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

'Public Declare Function RemoveDirectory& Lib "kernel32" Alias "RemoveDirectoryA" (ByVal lpPathName As String)
     
'Public Const INFINITE = &HFFFF
'Public Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
'Public Declare Function OpenProcess Lib "kernel32" (ByVal dwAccess As Long, ByVal fInherit As Integer, ByVal hObject As Long) As Long


Public vCcloseMin As Double ' минимальная cclose в окне данных
Public vCcloseMax As Double ' максимальная cclose в окне данных
Public vCcloseEnd As Double ' конечная cclose в окне данных
Public vCclosePosition As Double ' положение cclose между vCcloseMin и vCcloseMax в окне данных (0 = vCcloseMin, 1 = vCcloseMax)
Public vCclosePositionCurrent As Double ' положение cclose между vCcloseMin и vCcloseMax в текущих данных (0 = vCcloseMin, 1 = vCcloseMax)
Public vCclosePositionDelta As Double ' допустимое отклонение положения cclose в процентах при расчете К
Public IsCalcCclosePosition As Integer ' 1 - считать CclosePosition, 0 - не считать

' параметры для расчета общих показателей по похожим ситуациям
Public cntCharts As Integer ' количество похожих графиков, которые берем для анализа
Public StopLoss As Integer ' StopLoss в пунктах
Public TakeProfit As Integer ' TakeProfit в пунктах
Public OnePoint As Double ' значение одного пункта в цене
Public cDateTimeFirstCalc As String ' время начала расчета общих показателей
Public cDateTimeLastCalc As String ' время окончания расчета общих показателей
Public CurrencyId_current As Integer ' CurrencyId валюты текущих данных
Public CurrencyId_history As Integer ' CurrencyId валюты исторических данных (с которыми сравниваем)
Public PeriodMinutes As Integer
Public CurrencyNTName_current As String


Public objExcelCurrent As Object
Public objExcelHistory As Object

Public ParamsIdentifyer As String

Public isLogTables As Integer ' 1 - логировать таблицы

Public CurrDBName As String ' имя текущей БД

Public cntDaysPreviousShowABV As Integer ' количество предыдущих дней, за которое показывать ABV на графике (1 - показывать только за текущий день)

Public cntBarsCalcCorr As Integer ' количество баров, по которым считать К (0 - задается начальная дата-время)
Public cntBarsCalcCorr_cn As Integer ' количество баров, по которым считать К (0 - задается начальная дата-время)

Public pExcelWindowState As Integer ' 1 = разворачивать окно Excel, 2 = сворачивать окно, 3 = ничего не делать, 4 = сворачивать, но при наступлении алерта разворачивать

Public isSendEmailOnAlert As Integer ' 1 - посылать email при алерте
Public isSendSmsOnAlert As Integer ' 1 - посылать sms при алерте
Public isCountAverageValuesWithNextDay As Integer ' 1 - рассчитывать общие показатели (срабатывание стопов, верхи/низы) с учетом следующего дня, 0 - рассчитывать общие показатели только в пределах текущего дня

Public AlertStrBody As String ' текст сообщения при алерте (отсылается в email/sms)



'Public DeltaCcloseRangeMaxLimit As Single ' максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
'Public DeltaCcloseRangeMinLimit As Single ' минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)

Public cdatePreviousDay As String '  предыдущий день
Public cTimePreviousDayFirst As String ' время, начиная с которого считаем К за предыдущий день
Public cTimePreviousDayLast As String '  время, заканчивая которым считаем К за предыдущий день
Public cTimeInMinutesPreviousDayFirst As String ' время в минутах, начиная с которого считаем К за предыдущий день
Public cTimeInMinutesPreviousDayLast As String '  время в минутах, заканчивая которым считаем К за предыдущий день
Public cDateTimePreviousDayFirst As String ' дата-время, начиная с которой считаем К за предыдущий день
Public cDateTimePreviousDayLast As String '  дата-время, заканчивая которой считаем К за предыдущий день

Public cntDataPreviousDayRows As Long

Public CcorrPreviousDayMax As Single
Public CcorrCurrentDayMax As Single
Public cDateLastStep As String

Public CurrentDayCntBarsMinLimit As Single ' минимальное количество баров, которое может быть в расчетном дне




'------------------------
Public PeriodMinutes_cn As Integer    ' период данных в минутах, по которому надо считать К
    
Public FieldNumCurrent_cn As Integer    ' номер столбца (начиная с 0) в таблице tblDataCurrent, по которому считаем К
Public FieldNumHistory_cn As Integer    ' номер столбца (начиная с 0) в таблице с историей, по которому считаем К
    
Public idAlgorithmCalcCorr_cn As Integer    ' алгоритм расчета К: 1 - обычный, 2 - упрощенный (CalcCorrelationEasy)
    

    ' параметры для определения конечной точки расчета К
Public cTimeLast_cn As String    ' время, на которое считаем К (если не указано, то равно ntSettingsFilesParameters_cn.cDateTimeLast)
Public cntDaysAgoLast_cn As Integer    ' количество дней назад от даты ntSettingsFilesParameters_cn.cDateTimeCalc

    ' параметры для определения начальной точки расчета К
Public cTimeFirst_cn As String    ' время, начиная с которого считаем К (если не указано, то равно ntSettingsFilesParameters_cn.cDateTimeFirst)
Public cntDaysAgoFirst_cn As Integer    ' количество дней назад от конечной точки расчета К


Public WeightCORR_cn As Double     ' вес К по данному расчету в общей К
Public WeightCORR_cn_sum As Double     ' вес К по данному расчету в общей К

Public MAPeriod_cn As Integer    ' период MA (по которой считаем К)
    
Public DeltaCcloseRangeMaxLimit_cn As Single    ' максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
Public DeltaCcloseRangeMinLimit_cn As Single    ' минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)

Public IsCalcCorrOnlyForSameTime_cn As Integer    ' 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
Public DeltaMinutesCalcCorr_cn As Integer    ' количество минут в ту и другую сторону относительно текущего бара, для которых считаем К

Public IsCalcCclosePosition_cn As Integer    ' 1 - считать CclosePosition, 0 - не считать
Public vCclosePositionDelta_cn As Double    ' допустимое отклонение положения cclose в процентах при расчете К


Public CntBarsMinLimit_cn As Integer    ' минимальное количество баров, которое может быть в расчетном дне

'--


Public tblDataHistory_cn As String
Public tblDataCurrent_cn As String
Public arrDataHistory_cn() ' вспомогательный массив с историческими данными
Public arrDataCurrent_cn() ' вспомогательный массив с текущими данными
Public cntDataHistoryRows_cn As Long
Public cntDataCurrentRows_cn As Long
    
Public arrCclose_cn() As Double ' массив с cclose по текущим данным
Public arrCorr_cn() 'As Double ' массив с рассчитанной корреляцией по историческим данным (cclose)
Public arrCorrMaxForDates_cn() 'As Double ' массив с максимальной К за день (1-й столбец - дата, 2-й столбец - максимальная К)

Public cDateTimeFirst_cn As String ' время начала расчета К
Public cDateTimeLast_cn As String ' время окончания расчета К
Public cDateCalcFirst_cn As String ' временная переменная
Public cDateCalcLast_cn As String ' временная переменная

Public SourceFileNameCurrentRealTime_cn As String
Public SourceFileNameCurrent_cn As String

Public arrCcloseTimeInMinutes_cn() 'As Double ' массив с временем cclose (количество минут с начала дня)


Public arrCdateTime() 'As Double ' массив с CdateTime по историческим данным (для графика)
Public arrCdateTime_cn() 'As Double ' массив с CdateTime по историческим данным (для n-го расчета К)



Public IsExportToTxtCurrent As Integer
Public IsExportToTxtHistory As Integer
Public strTxtFileExport As String

Public iNum As Double

Public ctime_CalcAverageValuesWithNextDay As String ' время, начиная с которого рассчитываем общие показатели с учетом СЛЕДУЮЩЕГО торгового дня
Public CntBarsMinLimit As Integer ' минимальное количество баров, которое может быть в торговом дне (нужно для вычисления СЛЕДУЮЩЕГО торгового дня)

Public arrDataHistory_cn_filled As Integer ' 1 - исторические массивы для расчета _cn заполнены
Public tblDataHistory_cn_previous As String

Public MdbFileId As String ' MdbFileId = последний символ в имени mdb-файла





Public DeltaCcloseRangeMaxLimit As Single ' максимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)
Public DeltaCcloseRangeMinLimit As Single ' минимальная разница в диапазоне цены текущих и исторических данных (0 - не учитывать эту разницу)

Public IsCalcCorrOnlyForSameTime As Integer ' 1 - считать К только для баров, у которых время равно времени текущего бара +- DeltaMinutesCalcCorr, 0 - считать К для всех баров
Public DeltaMinutesCalcCorr As Integer ' количество минут в ту и другую сторону относительно текущего бара, для которых считаем К

Public CalcCorrParamsId As String ' идентификатор параметров расчета К

    
    
Public isCalcCorr1 As Integer ' 1 = считать К, 0 = не считать К (д.б. уже посчитана по другому ParamsIdentifyer)
    
Public cdate_current As String ' дата, на которую считается К
    
Public is_makeDeals_RealTrade As Integer ' 1 - совершать сделки

Public cntSourceFiles As Integer ' количество исходных текстовых файлов

    
'Public ArrValueFirst As Double
'Public ArrValueFirstPrevious As Double
'Public ArrValueMin As Double
'Public ArrValueMinPrevious As Double
'Public arrHistoryRemoved As Double

'Public arrIDNSorted_cn() ' отсортированный массив с IDN по историческим данным
'Public arrIDN_cn() 'As Double ' массив с IDN по историческим данным

'Public arrIDN_cn() 'As Double ' массив с IDN по текущим данным
'Public arrCdate_cn() 'As Double ' массив с Cdate по текущим данным

'Public rstCurrentData_cn As DAO.Recordset

'-------------------
'добавлено:
'Public WeightCORRMAVolume As Double ' вес К(MAVolume) в общей К
'Public MAVolumePeriod As Integer ' период MA(Volume) (по которой считаем К)


'Public arrCORRMAVolume() 'As Double ' массив с рассчитанной корреляцией по историческим данным (MAVolume)
'Public arrMAVolume() ' массив с MA(Volume) по историческим данным
'Public arrMAVolumeIDN() ' массив с IDN MA(Volume) по историческим данным
'Public arrDataCurrentCompareMAVolume() As Double ' массив с MAVolume по текущим данным
'Public arrDataHistoryCompareMAVolume() As Double ' массив-окно с MAVolume по историческим данным


'Public arrCORRABVMini() 'As Double ' массив с рассчитанной корреляцией по историческим данным (ABVMini)
'Public arrABVMini() 'As Double ' массив с ABVMini по историческим данным
'Public arrABVMiniIDN() ' массив с IDN ABVMini по историческим данным
'Public arrDataCurrentCompareABVMini() As Double ' массив с ABVMini по текущим данным
'Public arrDataHistoryCompareABVMini() As Double ' массив-окно с ABVMini по историческим данным

