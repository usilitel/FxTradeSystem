Attribute VB_Name = "mCorrEasy"
'Option Compare Database
Option Explicit



Public Sub CorrelationEasyPrepare(ByRef arrCurrentCompare() As Double, ByRef arrCurrentCompareRanges() As Double)
' предварительный расчет показателей для дальнейшего расчета КEasy
' вычисляем отклонения в массиве arrCurrentCompare и запиываем их в массив arrCurrentCompareRanges
  
Dim i As Long
Dim SQLString As String


' вычисляем минимальную и максимальную cclose по текущим данным
vCcloseMin = fMinValue(arrCurrentCompare)
vCcloseMax = fMaxValue(arrCurrentCompare)

' заполняем массив arrDataCurrentCompareEasyRanges (массив со значениями отклонений по текущим данным)
For i = 1 To cntDataCurrentRows
  arrCurrentCompareRanges(i - 1) = (arrCurrentCompare(i - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
Next i


' проверка (запись массива в таблицу)
'Call ClearTable("_test1")
'Application.SetOption "Confirm Action Queries", False
'For i = 1 To cntDataCurrentRows
'  arrDataCurrentCompareEasyRanges(i - 1) = (arrDataCurrentCompare(i - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
'  SQLString = "insert into _test1(cdate, ctime, cclose, crange) select """ & arrDataCurrentAll(1, i - 1) & """, """ & arrDataCurrentAll(2, i - 1) & """, """ & arrDataCurrentCompare(i - 1) & """, """ & arrDataCurrentCompareEasyRanges(i - 1) & """"
'  DoCmd.RunSQL SQLString
'Next i

End Sub




'Call CalcCorrelationEasy(arrDataHistoryCompareEasy, arrDataHistoryCompareEasyRanges, arrDataCurrentCompareEasy, arrDataCurrentCompareEasyRanges, arrCORREasy, arrCclose)


Sub CalcCorrelationEasy(ByRef arrHistoryCompare() As Double, ByRef arrHistoryCompareRanges() As Double, ByRef arrCurrentCompare() As Double, ByRef arrCurrentCompareRanges() As Double, arrCorrelationValues() As Variant, arrHistoryAll() As Variant)
' расчет КEasy:
' двигаем окно по массиву arrHistoryAll и считаем КEasy с массивом arrCurrentCompareRanges


'описание параметров:
'arrHistoryCompare() - массив-окно с историческими данными (рассчитывается в процедуре)
'arrHistoryCompareRanges() - массив-окно с историческими данными по отклонениям (по которым считаем К) (рассчитывается в процедуре)
'arrCurrentCompare() - массив с текущими данными (должен быть заполнен)
'arrCurrentCompareRanges() - массив с текущими данными по отклонениям (по которым считаем К) (рассчитывается в процедуре)
'arrCorrelationValues() - массив, в который записываем рассчитанные значения К (рассчитывается в процедуре)
'arrHistoryAll() - массив со всеми историческими данными (по нему двигаем массив-окно) (должен быть заполнен)



Dim SQLString As String
Dim i As Long
Dim j As Long

Call WriteLog("--1--")

' предварительный расчет показателей
Call CorrelationEasyPrepare(arrCurrentCompare(), arrCurrentCompareRanges())

Call WriteLog("--2--")

For i = 1 To (cntDataCurrentRows - 1)
  arrCorrelationValues(i - 1) = 0
Next i

' считаем КEasy для первого элемента
For i = 1 To 1 ' цикл по большой таблице
  For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
  Next j
  
  ' вычисляем отклонения в массиве arrHistoryCompare и запиываем их в массив arrHistoryCompareRanges:
  ' вычисляем минимальную и максимальную cclose в окне
  vCcloseMin = fMinValue(arrHistoryCompare)
  vCcloseMax = fMaxValue(arrHistoryCompare)
  ' заполняем массив arrHistoryCompareRanges (массив со значениями отклонений по историческим данным)
  For j = 1 To cntDataCurrentRows
    If vCcloseMax = vCcloseMin Then
      arrHistoryCompareRanges(j - 1) = 0
    Else
      arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
    End If
  Next j
  
  arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)

'------------------------
        'SQLString = "insert into ttemp(idn, f1) values(" & arrABVIDN(i - 1) & "," & Replace(arrCorrelationValues(i - 1), ",", ".") & ")"
        'DoCmd.RunSQL SQLString
'------------------------

Next i

Call WriteLog("--3--")



' считаем КEasy для всех баров
If IsCalcCorrOnlyForSameTime_cn = 0 Then

    For i = 2 To (cntDataHistoryRows - cntDataCurrentRows + 1) ' цикл по большой таблице
      For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
        arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
      Next j
      
      ' вычисляем отклонения в массиве arrHistoryCompare и запиываем их в массив arrHistoryCompareRanges:
      ' обновляем минимальные/максимальные cclose в окне:
      If arrHistoryAll(i - 2) = vCcloseMin Then ' если удаленный элемент массива был минимальным, то пересчитываем минимальный элемент
        vCcloseMin = fMinValue(arrHistoryCompare)
      End If
      
      If arrHistoryAll(i - 2) = vCcloseMax Then ' если удаленный элемент массива был максимальным, то пересчитываем максимальный элемент
        vCcloseMax = fMaxValue(arrHistoryCompare)
      End If
      
      If arrHistoryCompare(j - 2) < vCcloseMin Then ' если новый элемент массива меньше минимального, то обновляем минимальный элемент
        vCcloseMin = arrHistoryCompare(j - 2)
      End If
      
      If arrHistoryCompare(j - 2) > vCcloseMax Then ' если новый элемент массива больше максимального, то обновляем максимальный элемент
        vCcloseMax = arrHistoryCompare(j - 2)
      End If
    
      ' заполняем массив arrHistoryCompareRanges (массив со значениями отклонений по историческим данным)
      For j = 1 To cntDataCurrentRows
        If vCcloseMax = vCcloseMin Then
          arrHistoryCompareRanges(j - 1) = 0
        Else
          arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
        End If
      Next j
      
      arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)
    
    Next i
End If



' считаем К только для баров, близких по времени к текущему
If IsCalcCorrOnlyForSameTime_cn = 1 Then
    For i = 2 To (cntDataHistoryRows - cntDataCurrentRows + 1) ' цикл по большой таблице
        
        ' если время последнего исторического бара попадает в рассчитываемый промежуток, то заполняем массив для сравнения и считаем К (плюс захватываем один лишний бар для предварительного расчета)
        If ((arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) >= (CurrentBarTimeInMinutes - DeltaMinutesCalcCorr_cn - PeriodMinutes_cn)) And (arrCcloseTimeInMinutes_cn(i + cntDataCurrentRows - 2) <= (CurrentBarTimeInMinutes + DeltaMinutesCalcCorr_cn))) Then
                For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
                    arrHistoryCompare(j - 1) = arrHistoryAll(i + j - 2)
                Next j
              
                ' если К считается для первого элемента из рассчитываемого промежутка, то считаем К заново (чтобы рассчитать заново все переменные)
                If arrCorrelationValues(i - 1 + cntDataCurrentRows - 2) = 0 Then
                    'Call CorrelationEasyPrepare(arrCurrentCompare(), arrCurrentCompareRanges())
                    
                    ' вычисляем отклонения в массиве arrHistoryCompare и запиываем их в массив arrHistoryCompareRanges:
                    ' вычисляем минимальную и максимальную cclose в окне
                    vCcloseMin = fMinValue(arrHistoryCompare)
                    vCcloseMax = fMaxValue(arrHistoryCompare)
                    ' заполняем массив arrHistoryCompareRanges (массив со значениями отклонений по историческим данным)
                    For j = 1 To cntDataCurrentRows
                      If vCcloseMax = vCcloseMin Then
                        arrHistoryCompareRanges(j - 1) = 0
                      Else
                        arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
                      End If
                    Next j
                    
                    arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)
                Else
                    ' вычисляем отклонения в массиве arrHistoryCompare и запиываем их в массив arrHistoryCompareRanges:
                    ' обновляем минимальные/максимальные cclose в окне:
                    If arrHistoryAll(i - 2) = vCcloseMin Then ' если удаленный элемент массива был минимальным, то пересчитываем минимальный элемент
                        vCcloseMin = fMinValue(arrHistoryCompare)
                    End If
                      
                    If arrHistoryAll(i - 2) = vCcloseMax Then ' если удаленный элемент массива был максимальным, то пересчитываем максимальный элемент
                        vCcloseMax = fMaxValue(arrHistoryCompare)
                    End If
                      
                    If arrHistoryCompare(j - 2) < vCcloseMin Then ' если новый элемент массива меньше минимального, то обновляем минимальный элемент
                        vCcloseMin = arrHistoryCompare(j - 2)
                    End If
                      
                    If arrHistoryCompare(j - 2) > vCcloseMax Then ' если новый элемент массива больше максимального, то обновляем максимальный элемент
                        vCcloseMax = arrHistoryCompare(j - 2)
                    End If
                    
                      ' заполняем массив arrHistoryCompareRanges (массив со значениями отклонений по историческим данным)
                    For j = 1 To cntDataCurrentRows
                        If vCcloseMax = vCcloseMin Then
                            arrHistoryCompareRanges(j - 1) = 0
                        Else
                            arrHistoryCompareRanges(j - 1) = (arrHistoryCompare(j - 1) - vCcloseMin) / (vCcloseMax - vCcloseMin)
                        End If
                    Next j
                      
                        arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = CorrelationEasyAll(arrHistoryCompareRanges, arrCurrentCompareRanges, cntDataCurrentRows)
                    End If
        Else
              'если время последнего исторического бара не попадает в рассчитываемый промежуток, то ставим К = 0
              arrCorrelationValues(i - 1 + cntDataCurrentRows - 1) = 0
        End If
    Next i

End If

    Call WriteLog("--4--")
End Sub


Public Function CorrelationEasyAll(ByRef arrHistoryRanges() As Double, _
                                   ByRef arrCurrentRanges() As Double, _
                                   ByVal n As Long) _
                                   As Double

'расчет KEasy между массивами arrHistoryRanges и arrCurrentRanges

Dim i As Long

CorrelationEasyAll = 1

For i = 1 To n
  CorrelationEasyAll = CorrelationEasyAll - (Abs(arrHistoryRanges(i - 1) - arrCurrentRanges(i - 1)) / n)
Next i

'CorrelationEasyAll = CorrelationEasyAll / n

End Function



