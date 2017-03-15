Attribute VB_Name = "smsc_api"
' SMSC.RU API (www.smsc.ru) версия 1.0 (10.01.2011)

Public Const SMSC_DEBUG As Byte = 0         ' флаг отладки
Public Const SMSC_CHARSET As String = "utf-8"    ' кодировка сообщения (utf-8 или koi8-r), по умолчанию используется windows-1251

Public SMSC_LOGIN As String                 ' логин клиента
Public SMSC_PASSWORD As String              ' пароль клиента или MD5-хеш пароля в нижнем регистре
Public SMSC_HTTPS As Byte                   ' использовать HTTPS протокол

Public Const SMTP_SERVER As String = "smtp.mail.ru"        ' адрес SMTP сервера
Public Const SMTP_USERNAME As String = "<smtp_user_name>"  ' логин на SMTP сервере
Public Const SMTP_PASSWORD As String = "<smtp_password>"   ' пароль на SMTP сервере
Public Const SMTP_FROM As String = "smtp_user_name@mail.ru" ' e-mail адрес отправителя

Public CONNECT_MODE As Byte         ' режим соединения с интернетом: 0 - прямое, 1 - Proxy, 2 - настройки из Internet Exporer
Public PROXY_SERVER As String       ' адрес Proxy-сервера
Public PROXY_PORT As Integer        ' порт Proxy-сервера
Public PROXY_AUTORIZATION As Byte   ' флаг использования авторизации на Proxy-сервере
Public PROXY_USERNAME As String     ' логин на Proxy-сервере
Public PROXY_PASSWORD As String     ' пароль на Proxy-сервере

Public Connection As Object


Sub sendSMS(strBody As String)
    SMSC_LOGIN = ""******" ' логин клиента
    SMSC_PASSWORD = ""******" ' пароль клиента или MD5-хеш пароля в нижнем регистре

    Call SMSC_Initialize
    Call send_SMS("+79535775047", strBody)
End Sub


Public Function test1()
    SMSC_LOGIN = ""******" ' логин клиента
    SMSC_PASSWORD = "******" ' пароль клиента или MD5-хеш пароля в нижнем регистре

    Call SMSC_Initialize
    Call send_SMS("+79535775047", "1_5")
End Function


' Пауза в приложении
'
' Параметры:
'   PauseTime - время паузы в секундах
'
Private Sub Sleep(PauseTime As Integer)

    Start = Timer
    Do While Timer < Start + PauseTime
        DoEvents
    Loop
    
End Sub


Public Function URLEncode(ByVal Str As String) As String

    Dim Ret

    Ret = ""
    CharStr = " !""@№#;%:?*().,/$^&\+"
    
    Str = Trim(Str)
    For i = 1 To Len(Str)
        
        S = Mid(Str, i, 1)
        SymCode = Asc(S)
        
        ' Перевод из UNICODE в ASCII
        If ((SymCode > 1039) And (SymCode < 1104)) Then
            SymCode = SymCode - 848
        ElseIf SymCode = 8470 Then
            SymCode = 185
        ElseIf SymCode = 1105 Then
            SymCode = 184
        ElseIf SymCode = 1025 Then
            SymCode = 168
        End If
   
        fl_replace = 0
        If InStr(1, CharStr, S, vbBinaryCompare) > 0 Then
            Ret = Ret & "%" & Hex(Int(SymCode / 16)) & Hex(Int(SymCode Mod 16))
            fl_replace = 1
        End If

        If (SymCode <= 127) And (fl_replace = 0) Then
            Ret = Ret & S
        ElseIf fl_replace = 0 Then
            Ret = Ret + "%" + Hex(Int(SymCode / 16)) & Hex(Int(SymCode Mod 16))
        End If
    
    Next i

    URLEncode = Ret

End Function

' Функция чтения URL.
'
Private Function SMSC_Read_URL(URL As String, Params As String) As String

    Dim Ret As String
    
    On Error GoTo 0
    Connection.Open "POST", Trim(URL), 0
    Connection.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    Connection.Send Trim(Params)
    Ret = Connection.ResponseText()
    If Err.Number <> 0 Then
        MsgBox "Не удалось получить данные с сервера!", , "Ошибка"
        SMSC_Read_URL = ""
        Exit Function
    End If
    
    SMSC_Read_URL = Ret

End Function

' Функция вызова запроса. Формирует URL и делает 3 попытки чтения.
'
Private Function SMSC_Send_Cmd(Cmd As String, Optional Arg As String = "")
    
    Dim URL As String, Params As String, Ret As String
        
    URL = IIf(SMSC_HTTPS, "https", "http") & "://smsc.ru/sys/" & Cmd & ".php"
    Params = "login=" & SMSC_LOGIN & "&psw=" & SMSC_PASSWORD & "&fmt=1" _
            & IIf(SMSC_CHARSET = "", "", "&charset=" + SMSC_CHARSET) & "&" & Arg
    
    i = 0
    Do
        If i Then Sleep (2)
        If i = 2 Then URL = Replace(URL, "://smsc.ru/", "://www2.smsc.ru/")
        Ret = SMSC_Read_URL(URL, Params)
        i = i + 1
    Loop While (IsEmpty(Ret) And i < 3)

    If IsEmpty(Ret) Then
        If SMSC_DEBUG Then MsgBox "Ошибка чтения адреса: " & URL, , "Ошибка"
        Ret = ","  ' фиктивный ответ
    End If

    SMSC_Send_Cmd = Split(Ret, ",", -1, vbTextCompare)

End Function

' Функция получения баланса
'
' без параметров
'
' возвращает баланс в виде строки или CVErr(N_Ошибки) в случае ошибки
'
Public Function Get_Balance()

    Dim m
    
    m = SMSC_Send_Cmd("balance")  ' (balance) или (0, -error)

    If UBound(m) = 0 Then
        Get_Balance = m(0)
    Else
        Get_Balance = CVErr(-m(1))
    End If

End Function

' Функция отправки SMS
'
' обязательные параметры:
'
' Phones - список телефонов через запятую или точку с запятой
' Message - отправляемое сообщение
'
' необязательные параметры:
'
' Translit - переводить или нет в транслит (1 или 0)
' Time - необходимое время доставки в виде строки (DDMMYYhhmm, h1-h2, 0ts, +m)
' Id - идентификатор сообщения
' Format - формат сообщения (0 - обычное sms, 1 - flash-sms, 2 - wap-push, 3 - hlr, 4 - bin, 5 - bin-hex, 6 - ping-sms)
' Sender - имя отправителя (Sender ID)
' Query - дополнительные параметры
'
' возвращает массив (<id>, <количество sms>, <стоимость>, <баланс>) в случае успешной отправки
' либо массив (<id>, -<код ошибки>) в случае ошибки
'
Public Function send_SMS(Phones As String, Message As String, Optional Translit = 0, Optional Time = 0, Optional Id = 0, Optional Format = 0, Optional sender = "", Optional Query = "")
    
    Dim Formats As Variant
    Dim m
    
    Formats = Array("flash=1", "push=1", "hlr=1", "bin=1", "bin=2", "ping=1")
    FormatStr = ""
    If (Format > 0) Then
        FormatStr = Formats(Format - 1)
    End If
  
    m = SMSC_Send_Cmd("send", "cost=3&phones=" & URLEncode(Phones) & "&mes=" & Message _
                    & "&translit=" & Translit & "&id=" & Id & IIf(Format > 0, "&" & FormatStr, "") _
                    & IIf(sender = "", "", "&sender=" & URLEncode(sender)) _
                    & "&charset=" & SMSC_CHARSET & IIf(Time = "", "", "&time=" & URLEncode(Time)) _
                    & IIf(Query = "", "", "&" & Query))

    ' (id, cnt, cost, balance) или (id, -error)

    send_SMS = m
    
End Function


' Функция получения стоимости SMS
'
' обязательные параметры:
'
' Phones - список телефонов через запятую или точку с запятой
' Message - отправляемое сообщение
'
' необязательные параметры:
'
' Translit - переводить или нет в транслит (1 или 0)
' Sender - имя отправителя (Sender ID)
' Query - дополнительные параметры
'
' возвращает массив (<стоимость>, <количество sms>) либо массив (0, -<код ошибки>) в случае ошибки
'
Public Function Get_SMS_Cost(Phones As String, Message As String, Optional Translit = 0, Optional sender = "", Optional Query = "")

    Dim m
    
    m = SMSC_Send_Cmd("send", "cost=1&phones=" & URLEncode(Phones) & "&mes=" & Message & IIf(sender = "", "", "&sender=" & URLEncode(sender)) _
                    & "&translit=" & Translit & IIf(Query = "", "", "&" & Query))


    '(cost, cnt) или (0, -error)

    Get_SMS_Cost = m

End Function

' Функция проверки статуса отправленного SMS
'
' Id - ID cообщения
' Phone - номер телефона
'
' возвращает массив
' для отправленного SMS (<статус>, <время изменения>, <код ошибки sms>)
' для HLR-запроса (<статус>, <время изменения>, <код ошибки sms>, <код страны регистрации>, <код оператора абонента>,
' <название страны регистрации>, <название оператора абонента>, <название роуминговой страны>, <название роумингового оператора>,
' <код IMSI SIM-карты>, <номер сервис-центра>)
' либо список (0, -<код ошибки>) в случае ошибки
'
Public Function Get_Status(Id, Phone)

    Dim m

    m = SMSC_Send_Cmd("status", "phone=" & URLEncode(Phone) & "&id=" & Id)

    ' (status, time, err) или (0, -error)

    Get_Status = m
    
End Function

' Инициализация подключения
'
Public Function SMSC_Initialize()

    On Error GoTo 0
    Set Connection = CreateObject("WinHttp.WinHttpRequest.5.1")
    Connection.Option 9, 80
    
    If Err.Number = 440 Or Err.Number = 432 Then
       MsgBox "Не удалось создать объект ""WinHttp.WinHttpRequest.5.1""!" & Chr(13) & "Проверьте наличие системной библиотеки ""WinHttp.dll""", , "Ошибка"
       Err.Clear
    End If

End Function
