Attribute VB_Name = "mCalcCclosePosition"
Option Explicit


Public Sub MakeArrayPlusAsDouble(ByRef ArrName() As Double, Optional isCalcArrValueFirstPrevious As Integer) ', _ ByVal n As Long)
'isCalcArrValueFirstPrevious: 1 -
Dim i As Long
Dim ArrValueMin As Double
        
        ' при расчете К по ABV/ABVMini обнуляем первый элемент (иначе  будет округление/переполнение)
        'If ((DataSourceId = 2) And (FieldNumCurrent_cn = 7 Or FieldNumCurrent_cn = 8 Or FieldNumCurrent_cn = 14 Or FieldNumCurrent_cn = 15)) Then
        If (DataSourceId = 2) Then
            'ArrValueFirstPrevious = ArrValueFirst ' запоминаем ArrValueFirst с предыдущего шага
            'ArrValueMinPrevious = ArrValueMin ' запоминаем ArrValueMin с предыдущего шага
            'ArrValueFirst = 0
            ArrValueMin = 0
            For i = 0 To UBound(ArrName)
                If i = 0 Then
                    ArrValueMin = fMinValue(ArrName)
                    'ArrValueFirst = ArrName(i) - ArrValueMin
                End If
                ArrName(i) = ArrName(i) - ArrValueMin '+ 1000000
            Next i
        End If
End Sub
        

Public Function fMinValueAsVariant(ByRef ArrName() As Variant)
' функция возвращает минимальный элемент массива

Dim i As Long
Dim vMinValue As Double

vMinValue = 1000000000

For i = 1 To UBound(ArrName) + 1
  If ArrName(i - 1) < vMinValue Then
    vMinValue = ArrName(i - 1)
  End If
Next i

fMinValueAsVariant = vMinValue

End Function

Public Function fMinValue(ByRef ArrName() As Double)
' функция возвращает минимальный элемент массива

Dim i As Long
Dim vMinValue As Double

vMinValue = 1000000000

For i = 1 To UBound(ArrName) + 1
  If ArrName(i - 1) < vMinValue Then
    vMinValue = ArrName(i - 1)
  End If
Next i

fMinValue = vMinValue

End Function

Public Function fMaxValue(ByRef ArrName() As Double)
' функция возвращает минимальный элемент массива

Dim i As Long
Dim vMaxValue As Double

vMaxValue = -1000000000

For i = 1 To UBound(ArrName) + 1
  If ArrName(i - 1) > vMaxValue Then
    vMaxValue = ArrName(i - 1)
  End If
Next i

fMaxValue = vMaxValue

End Function


Public Sub CalcvCclosePositionCurrent(ByRef arrCurrent() As Double) ', _ ByVal n As Long)
' расчет vCclosePositionCurrent

vCcloseMin = fMinValue(arrCurrent)
vCcloseMax = fMaxValue(arrCurrent)
vCcloseEnd = arrCurrent(UBound(arrCurrent))
vCclosePositionCurrent = (vCcloseEnd - vCcloseMin) / (vCcloseMax - vCcloseMin)
'MsgBox vCcloseMin & " " & vCcloseMax & " " & vCcloseEnd & " " & vCclosePositionCurrent


'Public vCcloseMin As Double ' минимальная cclose в окне данных
'Public vCcloseMax As Double ' максимальная cclose в окне данных
'Public vCcloseEnd As Double ' конечная cclose в окне данных
'Public vCclosePosition As Double ' положение cclose между vCcloseMin и vCcloseMax в окне данных (0 = vCcloseMin, 1 = vCcloseMax)
'Public vCclosePositionCurrent As Double ' положение cclose между vCcloseMin и vCcloseMax в текущих данных (0 = vCcloseMin, 1 = vCcloseMax)
'Public vCclosePositionDelta As Double ' допустимое отклонение положения cclose в процентах при расчете К
                                     
End Sub

Public Function fCalcCclosePosition(ByRef arrCclose() As Double) ', _ ByVal n As Long)
' расчет vCclosePositionCurrent

vCcloseMin = fMinValue(arrCclose)
vCcloseMax = fMaxValue(arrCclose)
vCcloseEnd = arrCclose(UBound(arrCclose))
fCalcCclosePosition = (vCcloseEnd - vCcloseMin) / (vCcloseMax - vCcloseMin)
'MsgBox vCcloseMin & " " & vCcloseMax & " " & vCcloseEnd & " " & vCclosePositionCurrent


'Public vCcloseMin As Double ' минимальная cclose в окне данных
'Public vCcloseMax As Double ' максимальная cclose в окне данных
'Public vCcloseEnd As Double ' конечная cclose в окне данных
'Public vCclosePosition As Double ' положение cclose между vCcloseMin и vCcloseMax в окне данных (0 = vCcloseMin, 1 = vCcloseMax)
'Public vCclosePositionCurrent As Double ' положение cclose между vCcloseMin и vCcloseMax в текущих данных (0 = vCcloseMin, 1 = vCcloseMax)
'Public vCclosePositionDelta As Double ' допустимое отклонение положения cclose в процентах при расчете К
                                     
End Function



Sub CalcCclosePosition()
' считаем положение cclose между vCcloseMin и vCcloseMax по историческим данным
' и записываем его в массив arrCclosePosition (он имеет ту же размерность, что и arrCORRTotal)

Dim SQLString As String
Dim i As Long
Dim j As Long
Dim n As Long

    


For i = 1 To (cntDataCurrentRows - 1)
  arrCclosePosition(i - 1) = 0
Next i


' считаем CclosePosition для первого элемента
For i = 1 To 1 ' цикл по большой таблице
  For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
    arrDataHistoryCompare(j - 1) = arrCclose(i + j - 2)
  Next j

  n = UBound(arrDataHistoryCompare)
  vCcloseMin = fMinValue(arrDataHistoryCompare)
  vCcloseMax = fMaxValue(arrDataHistoryCompare)
  vCcloseEnd = arrDataHistoryCompare(n)
  vCclosePosition = (vCcloseEnd - vCcloseMin) / (vCcloseMax - vCcloseMin)
  arrCclosePosition(i - 1 + cntDataCurrentRows - 1) = vCclosePosition
Next i





' считаем CclosePosition для всех остальных элементов
For i = 2 To (cntDataHistoryRows_cn - cntDataCurrentRows + 1) ' цикл по большой таблице

    '--------------------
    ' если убрали наименьший или наибольший элемент, то пересчитываем
    If ((arrCclose(i - 2) = vCcloseMin) Or (arrCclose(i - 2) = vCcloseMax)) Then
      GoTo RecalcvCcloseMinMax
    End If
    
    j = cntDataCurrentRows
    
    ' если добавили наименьший или наибольший элемент, то меняем их
    If arrCclose(i + j - 2) < vCcloseMin Then
      vCcloseMin = arrCclose(i + j - 2)
    End If
    
    If (arrCclose(i + j - 2) > vCcloseMax) Then
      vCcloseMax = arrCclose(i + j - 2)
    End If
    
    GoTo CalcvCcloseEnd
    '--------------------
    
RecalcvCcloseMinMax:
    
      For j = 1 To cntDataCurrentRows ' цикл по маленькой таблице
        arrDataHistoryCompare(j - 1) = arrCclose(i + j - 2)
      Next j
      vCcloseMin = fMinValue(arrDataHistoryCompare)
      vCcloseMax = fMaxValue(arrDataHistoryCompare)
      
CalcvCcloseEnd:
      vCcloseEnd = arrCclose(i + cntDataCurrentRows - 2) 'arrDataHistoryCompare(n)
      vCclosePosition = (vCcloseEnd - vCcloseMin) / (vCcloseMax - vCcloseMin)
      arrCclosePosition(i - 1 + cntDataCurrentRows - 1) = vCclosePosition
Next i


'Call ClearTable("ttemp")
'For i = 1 To 300
'        SQLString = "insert into ttemp(idn, f1, f2) values(" & arrIDN(i - 1) & "," & Replace(arrCclosePosition(i - 1), ",", ".") & "," & Replace(arrCclose(i + j - 2), ",", ".") _
'        & ")"
'        DoCmd.RunSQL SQLString
'Next i

End Sub


Sub DeleteWrongArrCORR()
' чистим массив arrCORR от неправильных данных (у которых CclosePosition > vCclosePositionCurrent +- vCclosePositionDelta)

Dim i As Long

For i = 1 To (cntDataHistoryRows_cn - cntDataCurrentRows + 1) ' цикл по большой таблице
      If Abs(arrCclosePosition(i - 1 + cntDataCurrentRows - 1) - vCclosePositionCurrent) > vCclosePositionDelta Then
        arrCORR(i - 1 + cntDataCurrentRows - 1) = -1
      End If
Next i



End Sub


