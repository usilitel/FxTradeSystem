unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, OHLChart, CandleCh, TeEngine, Series,
  TeeProcs, Chart, ComCtrls, TeeURL, TeeSeriesTextEd, ADODB;

type
  TForm2 = class(TForm)
    PageControl1_f2: TPageControl;
    SeriesTextSource1: TSeriesTextSource;
    SeriesTextSource2: TSeriesTextSource;
    SeriesTextSource3: TSeriesTextSource;
    SeriesTextSource4: TSeriesTextSource;
    SeriesTextSource5: TSeriesTextSource;
    SeriesTextSource6: TSeriesTextSource;
    SeriesTextSource7: TSeriesTextSource;
    SeriesTextSource8: TSeriesTextSource;
    SeriesTextSource9: TSeriesTextSource;
    SeriesTextSource10: TSeriesTextSource;
    SeriesTextSource11: TSeriesTextSource;
    SeriesTextSource12: TSeriesTextSource;
    SeriesTextSource13: TSeriesTextSource;
    SeriesTextSource14: TSeriesTextSource;
    SeriesTextSource15: TSeriesTextSource;
    SeriesTextSource16: TSeriesTextSource;
    SeriesTextSource17: TSeriesTextSource;
    SeriesTextSource18: TSeriesTextSource;
    SeriesTextSource19: TSeriesTextSource;
    SeriesTextSource20: TSeriesTextSource;
    SeriesTextSource21: TSeriesTextSource;
    TabSheet1: TTabSheet;
    SeriesTextSource22: TSeriesTextSource;
    SeriesTextSource23: TSeriesTextSource;
    SeriesTextSource24: TSeriesTextSource;
    SeriesTextSource25: TSeriesTextSource;
    SeriesTextSource26: TSeriesTextSource;
    SeriesTextSource27: TSeriesTextSource;
    SeriesTextSource28: TSeriesTextSource;
    SeriesTextSource29: TSeriesTextSource;
    SeriesTextSource30: TSeriesTextSource;
    SeriesTextSource31: TSeriesTextSource;
    SeriesTextSource32: TSeriesTextSource;
    TabSheet1_f2: TTabSheet;
    Splitter1_f2: TSplitter;
    Splitter2_f2: TSplitter;
    Splitter3_f2: TSplitter;
    Splitter4_f2: TSplitter;
    Splitter5_f2: TSplitter;
    Splitter6_f2: TSplitter;
    Chart2_f2: TChart;
    Series2: TLineSeries;
    Series3: TLineSeries;
    Chart4_f2: TChart;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series10: TLineSeries;
    Series11: TLineSeries;
    Chart1_f2: TChart;
    Series1: TCandleSeries;
    Chart3_f2: TChart;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series8: TLineSeries;
    Series9: TLineSeries;
    Panel1_f2: TPanel;
    Chart5_f2: TChart;
    LineSeries1: TLineSeries;
    LineSeries2: TLineSeries;
    Series12: TLineSeries;
    Series13: TLineSeries;
    Chart6_f2: TChart;
    LineSeries3: TLineSeries;
    LineSeries4: TLineSeries;
    Series14: TLineSeries;
    Series15: TLineSeries;
    Chart7_f2: TChart;
    Series16: TAreaSeries;
    Chart3_f2_nd: TChart;
    Series17: TLineSeries;
    Series18: TLineSeries;
    Chart4_f2_nd: TChart;
    Series19: TLineSeries;
    Series20: TLineSeries;
    Series21: TLineSeries;
    Series22: TLineSeries;
    Chart5_f2_nd: TChart;
    Series23: TLineSeries;
    Series24: TLineSeries;
    Series25: TLineSeries;
    Series26: TLineSeries;
    Splitter7_f2: TSplitter;
    Splitter8_f2: TSplitter;
    Splitter9_f2: TSplitter;
    btnLoadCharts_f2: TButton;
    btnLoadAllCharts_f2: TButton;
    Panel2_f2: TPanel;
    btnLoadChartsByCurrencyId_f2: TButton;
    Panel3_f2: TPanel;
    StringGrid1: TStringGrid;
    btnLoadTotalChartsByCurrencyId_f2: TButton;
    btnLoadAllTotalCharts_f2: TButton;
    eDateTime: TEdit;
    Chart8_f2: TChart;
    Series27: TLineSeries;
    SeriesTextSource33: TSeriesTextSource;
    Series28: TLineSeries;
    SeriesTextSource34: TSeriesTextSource;
    StringGrid2: TStringGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;

    procedure CreateTabs(Sender: TObject);
    procedure pLoadCharts(PIPageIndex: integer; pCountCharts: integer);
    procedure Chart1_f2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PageControl1_f2MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PageControl1_f2Change(Sender: TObject);
    procedure StringDelimit(s: string; sDelimiter: string; stringNumber: integer);

  private
    { Private declarations }
  public
    { Public declarations }
    //arrDataChart_cDateTime: array of double; // массив с датой-временем на графиках
    arrDataChart_values: array of array of string; // массив со значениями на графиках

  end;

var
  Form2: TForm2;

implementation
uses Unit1;

{$R *.dfm}


procedure TForm2.CreateTabs(Sender: TObject);
var i,i2,i3,i4,i5,i6: integer;
    TS: TTabSheet;
    TS2: TTabSheet;
    Stream: TFileStream ;
    Stream2: TFileStream ;
    Stream3: TFileStream ;
    Contr: array [0..100] of TControl;
    Contr2: array [0..100] of TControl;
    Contr3: array [0..100] of TControl;

    PanelTmp: TPanel;
    PageControlTmp: TPageControl;
    ParamsIdentifyer: String;
    pCountCharts: integer;
    SourceFileName: String;
    DataFile : TextFile;
    StrTmp,StrVal1 : string;
    StrTmp2 : string;
    ChartTmp : TChart;
    StrCnt1,StrCnt2: integer;
//    ticks: dword;
//    sp_dpSelectNtSettingsFilesParameters_cn_f1: TADODataSet;
    sp_dpSelectNtSettingsFilesParameters_cn_f1: TADOStoredProc;
    SeriesTextSourceTmp: TSeriesTextSource;

    CurrencyId_tab: integer;
    CurrencyName_tab: String;
begin

  arrDataChart_values := nil;
  setlength(arrDataChart_values,10000,100);
  


  sp_dpSelectNtSettingsFilesParameters_cn_f1:=(Sender as TForm1).sp_dpSelectNtSettingsFilesParameters_cn;

  // сохраняем компоненты с TabSheet3
  Stream := TFileStream.Create( 'AFile_f2', fmCreate ) ;
  try
    For i:=0 to TabSheet1_f2.ControlCount-1 do begin
      Stream.WriteComponent(TabSheet1_f2.Controls[i]);
    end ;
  finally
    Stream.Free ;
  end;

  // сохраняем компоненты с Panel1
  Stream2 := TFileStream.Create( 'AFilePanel1_f2', fmCreate ) ;
  try
    For i:=0 to Panel1_f2.ControlCount-1 do begin
      Stream2.WriteComponent(Panel1_f2.Controls[i]);
    end ;
  finally
    Stream2.Free ;
  end;

  {
  // сохраняем компоненты с Chart1_f2
  Stream3 := TFileStream.Create( 'AChart1_f2', fmCreate ) ;
  try
    For i:=0 to Chart1_f2.ControlCount-1 do begin
        Stream3.WriteComponent(Chart1_f2.Controls[i]);
    end ;
  finally
    Stream3.Free ;
  end;
    }



  {
  For i:=0 to TabSheet1_f2.ControlCount-1 do begin
    if TabSheet1_f2.Controls[i].ClassNameIs('TChart') then
    begin
      ChartTmp:=TabSheet1_f2.Controls[i] as TChart;
      Stream3 := TFileStream.Create( 'A' + ChartTmp.Name, fmCreate);
      try
        For i6:=0 to ChartTmp.ControlCount-1 do begin
            Stream3.WriteComponent(ChartTmp.Controls[i6]);
        end ;
      finally
        Stream3.Free ;
      end;

    end;
  end;
   }
   













  // делаем вкладки для всех ParamsIdentifyer
  sp_dpSelectNtSettingsFilesParameters_cn_f1.First;
  While not sp_dpSelectNtSettingsFilesParameters_cn_f1.Eof do
  begin
    if sp_dpSelectNtSettingsFilesParameters_cn_f1.FieldByName('IsExportToExcelCurrent').Value=1 then
    begin
      // создаем новый лист с ParamsIdentifyer
      TS2:=TTabSheet.Create(PageControl1_f2);
      TS2.PageControl:=PageControl1_f2;
      ParamsIdentifyer:=sp_dpSelectNtSettingsFilesParameters_cn_f1.FieldValues['ParamsIdentifyer'];
      pCountCharts:=sp_dpSelectNtSettingsFilesParameters_cn_f1.FieldValues['pCountCharts'];
      TS2.Caption:=ParamsIdentifyer;
      TS2.OnShow:=TabSheet1_f2.OnShow;


        // восстанавливаем компоненты с TabSheet1_f2
        Stream := TFileStream.Create( 'AFile_f2', fmOpenRead ) ;
        try
          For i:=0 to TabSheet1_f2.ControlCount-1 do begin
            Contr[i]:= Stream.ReadComponent( nil ) as TControl;
            Contr[i].Parent:=TS2;

            if Contr[i].ClassNameIs('TChart') then
            begin
                SourceFileName:='G:\forex\Access\ForexChartsHistoryData_' + ParamsIdentifyer + '\ForexChartsHistoryData' + inttostr(pCountCharts+1) + '.txt';
                For i4:=0 to (Contr[i] as TChart).SeriesCount-1 do begin
                    SeriesTextSourceTmp:=(Contr[i] as TChart).Series[i4].DataSource as TSeriesTextSource; // получили нужный SeriesTextSource
                    SeriesTextSourceTmp.Series:=((Contr[i] as TChart).Series[i4]);
                    SeriesTextSourceTmp.FileName:=SourceFileName;
                    {if ((FileExists(SourceFileName)) and (1=1)) then
                    begin
                      SeriesTextSourceTmp.Load;
                    end;  }
                end;


                {
                // восстанавливаем компоненты с Chart1_f2
                if Contr[i].Name='Chart1_f2' then
                begin
                  Stream3 := TFileStream.Create( 'AChart1_f2', fmOpenRead ) ;
                  try
                    For i5:=0 to Chart1_f2.ControlCount-1 do begin
                      Contr3[i5]:= Stream3.ReadComponent( nil ) as TControl;
                      Contr3[i5].Parent:=(Contr[i] as TChart);
                      (Contr3[i5] as Tshape).Height:=(Contr[i] as TChart).Height;
                    end;
                  finally
                    Stream3.Free ;
                  end ;

                  (Contr[i] as TChart).OnMouseMove:=self.Chart1_f2.OnMouseMove;
                  //(Contr[i] as TChart).OnMouseMove:=form2.Chart1_f2MouseMove((Contr[i] as TChart),(Contr[i] as TChart).
                  //(Sender: TObject; Shift: TShiftState; X,Y: Integer);
                end;
                }
                {
                // восстанавливаем компоненты с Chart1_f2
                Stream3 := TFileStream.Create( 'AChart1_f2', fmOpenRead ) ;
                try
                  For i5:=0 to Chart1_f2.ControlCount-1 do begin
                    Contr3[i5]:= Stream3.ReadComponent( nil ) as TControl;
                    Contr3[i5].Parent:=(Contr[i] as TChart);
                    (Contr3[i5] as Tshape).Height:=(Contr[i] as TChart).Height;
                  end;
                finally
                  Stream3.Free ;
                end ;
                (Contr[i] as TChart).OnMouseMove:=self.Chart1_f2.OnMouseMove;
                 }

                (Contr[i] as TChart).OnMouseMove:=self.Chart1_f2.OnMouseMove;
            end;


            // восстанавливаем компоненты на Panel1_f2
            if Contr[i].ClassNameIs('TPanel') then
            begin
              (Contr[i] as TPanel).Caption:='';

              Stream2 := TFileStream.Create( 'AFilePanel1_f2', fmOpenRead ) ;
              try
                For i3:=0 to Panel1_f2.ControlCount-1 do begin
                  Contr2[i3]:= Stream2.ReadComponent( nil ) as TControl;
                  Contr2[i3].Parent:=(Contr[i] as TPanel);

                  if Contr2[i3].ClassNameIs('TButton') then
                  begin
                    if (Contr2[i3] as TButton).Name='btnLoadCharts_f2' then
                    begin
                      (Contr2[i3] as TButton).OnClick:=form1.btnLoadCharts.OnClick;
                    end;

                    if (Contr2[i3] as TButton).Name='btnLoadAllCharts_f2' then
                    begin
                      (Contr2[i3] as TButton).OnClick:=form1.btnLoadAllCharts.OnClick;
                    end;

                    if (Contr2[i3] as TButton).Name='btnLoadAllTotalCharts_f2' then
                    begin
                      (Contr2[i3] as TButton).OnClick:=form1.btnLoadAllTotalCharts.OnClick;
                    end;



                    if (Contr2[i3] as TButton).Name='btnLoadChartsByCurrencyId_f2' then
                    begin
                      (Contr2[i3] as TButton).OnClick:=form1.btnLoadChartsByCurrencyId.OnClick;

                      form1.sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
                      form1.sp_dpSelectParamsByParamsIdentifyer.Open;
                      form1.sp_dpSelectParamsByParamsIdentifyer.First;
                      CurrencyId_tab:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyId_current'];
                      CurrencyName_tab:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyName_current'];
                      form1.sp_dpSelectParamsByParamsIdentifyer.Close;

                      (Contr2[i3] as TButton).Caption:= 'загрузить графики по CurrencyId = ' + inttostr(CurrencyId_tab) + ' (' + CurrencyName_tab + ')';
                    end;


                    if (Contr2[i3] as TButton).Name='btnLoadTotalChartsByCurrencyId_f2' then
                    begin
                      (Contr2[i3] as TButton).OnClick:=form1.btnLoadTotalChartsByCurrencyId.OnClick;

                      form1.sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
                      form1.sp_dpSelectParamsByParamsIdentifyer.Open;
                      form1.sp_dpSelectParamsByParamsIdentifyer.First;
                      CurrencyId_tab:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyId_current'];
                      CurrencyName_tab:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyName_current'];
                      form1.sp_dpSelectParamsByParamsIdentifyer.Close;

                      (Contr2[i3] as TButton).Caption:= 'загрузить общие графики по CurrencyId = ' + inttostr(CurrencyId_tab) + ' (' + CurrencyName_tab + ')';
                    end;




                  end;

                end;
              finally
                Stream2.Free ;
              end ;
            end;



          end;
        finally
          Stream.Free ;
        end ;

    end;
    sp_dpSelectNtSettingsFilesParameters_cn_f1.MoveBy(1);
  end;

end;



procedure TForm2.StringDelimit(s: string; sDelimiter: string; stringNumber: integer);
// процедура:
// 1) разделяет строку на части и записывает их в массив arrDataChart_values

// stringNumber - номер строки в файле
var s1:string;
    SL:TStringList;
    cntValues:integer; // количество данных в строке
    i:integer;
begin

    if (s[Length(s)]=sDelimiter) then s:=s+sDelimiter; // если последнее значение - пустое

    SL := TStringList.Create;
    s1 := StringReplace(s, sDelimiter, sLineBreak, [rfReplaceAll]);  // <-- Вот оно, решение
    SL.Text := s1;
    cntValues := SL.Count;

    For i:=0 to (cntValues-1) do begin
      arrDataChart_values[stringNumber,i] := sl.Strings[i];
    end;


    {
    if sl.Strings[3] = 'Buy' then DealDirection := 1;
    if sl.Strings[3] = 'Sell' then DealDirection := 2;
    DealVolume := StrToFloat(sl.Strings[5]); // объем сделки
    //ExchTimeCurrent := Copy(sl.Strings[1], 1, 16); // время биржи
    ExchTimeCurrent := Copy(sl.Strings[1], 7, 4) + '.' + Copy(sl.Strings[1], 4, 2) + '.' + Copy(sl.Strings[1], 1, 2) + ' ' + Copy(sl.Strings[1], 12, 5) ; // время биржи
    DealPrice := StrToCurr(sl.Strings[4]); // цена сделки
    //DealCDate := Copy(sl.Strings[1], 7, 4) + '-' + Copy(sl.Strings[1], 4, 2) + '-' + Copy(sl.Strings[1], 1, 2);
    }




end;



procedure TForm2.pLoadCharts(PIPageIndex: integer; pCountCharts: integer);
var ControlTmp, ControlTmp2: TControl;
    PageControlCharts :TPageControl;
    TabSheetCharts :TTabSheet;
    ChartTmp: TChart;
    i,i2,i3,i4: integer;
    ParamsIdentifyer: String;
    SeriesTextSourceTmp: TSeriesTextSource;
    SourceFileName: String;
    DataFile : TextFile;
    StrTmp,StrVal1 : string;
    StrCnt1,StrCnt2: integer;
    PanelTmp: TPanel;

    StrListTmp : Tstringlist;
    SourceFileName2: String;
    letter : char;

begin

  ParamsIdentifyer:=self.PageControl1_f2.Pages[PIPageIndex].Caption;
  TabSheetCharts:=self.PageControl1_f2.Pages[PIPageIndex];


        //------------------------------------------
        // заполняем массив с данными графиков
        // arrDataChart_values: array of array of string; // массив со значениями на графиках

        SourceFileName:='G:\forex\Access\ForexChartsHistoryData_' + ParamsIdentifyer + '\ForexChartsHistoryData' + inttostr(pCountCharts+1) + '.txt';

        if FileExists(SourceFileName) then
        begin
          arrDataChart_values := nil;
          setlength(arrDataChart_values,10000,100);

          AssignFile(DataFile, SourceFileName);
          Reset(DataFile);

          StrTmp := '';
          i2:=0;
          while not Eof(DataFile) do
          begin
            {if i2=999 then
            begin
              StrTmp := StrTmp;
            end; }
            Read(DataFile, letter);
            if ord(letter)<>13 then
            begin
              if letter<>#$A then StrTmp := StrTmp + letter;
            end
            else
            begin
              if StrTmp<>'' then
              begin
                StringDelimit(StrTmp,';',i2);
                StrTmp := '';
                i2:=i2+1;
              end
            end;
          end;

          closefile(DataFile);
        end;

        //------------------------------------------




        // перебираем все компоненты на листе с графиками
        For i:=0 to TabSheetCharts.ControlCount-1 do begin

          // обновляем DataSource для графиков
          if TabSheetCharts.Controls[i].ClassNameIs('TChart') then
          begin
              SourceFileName:='G:\forex\Access\ForexChartsHistoryData_' + ParamsIdentifyer + '\ForexChartsHistoryData' + inttostr(pCountCharts+1) + '.txt';
              For i4:=0 to (TabSheetCharts.Controls[i] as TChart).SeriesCount-1 do begin
                  SeriesTextSourceTmp:=(TabSheetCharts.Controls[i] as TChart).Series[i4].DataSource as TSeriesTextSource; // получили нужный SeriesTextSource
                  SeriesTextSourceTmp.Series:=((TabSheetCharts.Controls[i] as TChart).Series[i4]);
                  SeriesTextSourceTmp.FileName:=SourceFileName;
                  if ((FileExists(SourceFileName)) and (1=1)) then
                  begin
                    SeriesTextSourceTmp.Load;
                  end;
              end;
          end;










          // перебираем все компоненты на panel
          if TabSheetCharts.Controls[i].ClassNameIs('TPanel') then
          begin
            PanelTmp:=TabSheetCharts.Controls[i] as TPanel;
            For i4:=0 to PanelTmp.ControlCount-1 do begin

              // записываем общие показатели в StringGrid
              if ((PanelTmp.Controls[i4].ClassNameIs('TStringGrid')) and (PanelTmp.Controls[i4].Name='StringGrid1')) then
              begin

                  //(PanelTmp.Controls[i4] as TStringGrid).Cells[0,0]:='cperiodResult';
                  //(PanelTmp.Controls[i4] as TStringGrid).Cells[0,1]:='222';


                  form1.sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
                  form1.sp_dpSelectParamsByParamsIdentifyer.Open;
                  form1.sp_dpSelectParamsByParamsIdentifyer.First;

                  (PanelTmp.Controls[i4] as TStringGrid).Width := 66*(PanelTmp.Controls[i4] as TStringGrid).ColCount; //Panel1_f2.Width - (PanelTmp.Controls[i4] as TStringGrid).Left - 10;

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[0,0]:='cTimeFirst';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[0,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['cTimeFirst'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[1,0]:='cntCharts';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[1,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['cntCharts'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[2,0]:='DeltaMinutesCalcCorr';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[2,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['DeltaMinutesCalcCorr'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[3,0]:='StopLoss';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[3,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['StopLoss'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[4,0]:='TakeProfit';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[4,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['TakeProfit'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[5,0]:='isCalcAverageValuesInPercents';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[5,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['isCalcAverageValuesInPercents'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[6,0]:='DeltaCcloseRangeMaxLimit';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[6,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['DeltaCcloseRangeMaxLimit'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[7,0]:='DeltaCcloseRangeMinLimit';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[7,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['DeltaCcloseRangeMinLimit'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[8,0]:='IsCalcCorrOnlyForSameTime';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[8,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['IsCalcCorrOnlyForSameTime'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[9,0]:='CalcCorrParamsId';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[9,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['CalcCorrParamsId'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[10,0]:='CntBarsMinLimit';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[10,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['CntBarsMinLimit'];

                  (PanelTmp.Controls[i4] as TStringGrid).Cells[11,0]:='cntBarsCalcCorr';
                  (PanelTmp.Controls[i4] as TStringGrid).Cells[11,1]:=form1.sp_dpSelectParamsByParamsIdentifyer.FieldValues['cntBarsCalcCorr'];

                  form1.sp_dpSelectParamsByParamsIdentifyer.Close;

              end;

            end;
          end;










        end;

end;




procedure TForm2.Chart1_f2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i,j: Integer;
//  Shape1: TShape;
//  String1: String;
begin

  //(Sender as TChart).Hint:=inttostr(i);
  //(Sender as TChart).Hint:=inttostr(X);
  //(Sender as TChart).ShowHint:=true;
  //eDateTime.Text:=inttostr(X);
  {
  Shape1:=(Sender as TChart).Controls[0] as TShape;
  Shape1.Left:=X;
  }

  i:=Round((Sender as TChart).Series[0].XScreenToValue(X));
  //eDateTime.Text:=inttostr(i);
  if i>=0 then eDateTime.Text:=arrDataChart_values[i,4];

  Panel2_f2.Left:=X+4;


  // выводим данные во вспомогательную таблицу
  if ((TComponent(Sender).Name = 'Chart3_f2') and (i>=0)) then
  begin
    StringGrid2.Cells[0,0]:='CcorrMax';
    StringGrid2.Cells[1,0]:='CcorrAvg';
    StringGrid2.Cells[2,0]:='TakeProfit_isOk_Daily_up_AvgCnt';
    StringGrid2.Cells[3,0]:='TakeProfit_isOk_Daily_down_AvgCnt';

    StringGrid2.Cells[0,1]:=arrDataChart_values[i,14];
    StringGrid2.Cells[1,1]:=arrDataChart_values[i,15];
    StringGrid2.Cells[2,1]:=arrDataChart_values[i,16];
    StringGrid2.Cells[3,1]:=arrDataChart_values[i,17];
  end;
  if ((TComponent(Sender).Name = 'Chart4_f2') and (i>=0)) then
  begin
    StringGrid2.Cells[0,0]:='TakeProfit_isOk_Daily_up_PrcBars';
    StringGrid2.Cells[1,0]:='TakeProfit_isOk_Daily_down_PrcBars';
    StringGrid2.Cells[2,0]:='TakeProfit_isOk_AtOnce_up_AvgCnt';
    StringGrid2.Cells[3,0]:='TakeProfit_isOk_AtOnce_down_AvgCnt';

    StringGrid2.Cells[0,1]:=arrDataChart_values[i,18];
    StringGrid2.Cells[1,1]:=arrDataChart_values[i,19];
    StringGrid2.Cells[2,1]:=arrDataChart_values[i,20];
    StringGrid2.Cells[3,1]:=arrDataChart_values[i,21];
  end;
  if ((TComponent(Sender).Name = 'Chart5_f2') and (i>=0)) then
  begin
    StringGrid2.Cells[0,0]:='ChighMax_Daily_Avg';
    StringGrid2.Cells[1,0]:='ClowMin_Daily_Avg';
    StringGrid2.Cells[2,0]:='ChighMax_AtOnce_Avg';
    StringGrid2.Cells[3,0]:='ClowMin_AtOnce_Avg';

    StringGrid2.Cells[0,1]:=arrDataChart_values[i,22];
    StringGrid2.Cells[1,1]:=arrDataChart_values[i,23];
    StringGrid2.Cells[2,1]:=arrDataChart_values[i,24];
    StringGrid2.Cells[3,1]:=arrDataChart_values[i,25];
  end;



  if ((TComponent(Sender).Name = 'Chart3_f2_nd') and (i>=0)) then
  begin
    StringGrid2.Cells[0,0]:='';
    StringGrid2.Cells[1,0]:='';
    StringGrid2.Cells[2,0]:='TakeProfit_isOk_Daily_up_AvgCnt_nd';
    StringGrid2.Cells[3,0]:='TakeProfit_isOk_Daily_down_AvgCnt_nd';

    StringGrid2.Cells[0,1]:='';
    StringGrid2.Cells[1,1]:='';
    StringGrid2.Cells[2,1]:=arrDataChart_values[i,26];
    StringGrid2.Cells[3,1]:=arrDataChart_values[i,27];
  end;
  if ((TComponent(Sender).Name = 'Chart4_f2_nd') and (i>=0)) then
  begin
    StringGrid2.Cells[0,0]:='TakeProfit_isOk_Daily_up_PrcBars_nd';
    StringGrid2.Cells[1,0]:='TakeProfit_isOk_Daily_down_PrcBars_nd';
    StringGrid2.Cells[2,0]:='TakeProfit_isOk_AtOnce_up_AvgCnt_nd';
    StringGrid2.Cells[3,0]:='TakeProfit_isOk_AtOnce_down_AvgCnt_nd';

    StringGrid2.Cells[0,1]:=arrDataChart_values[i,28];
    StringGrid2.Cells[1,1]:=arrDataChart_values[i,29];
    StringGrid2.Cells[2,1]:=arrDataChart_values[i,30];
    StringGrid2.Cells[3,1]:=arrDataChart_values[i,31];
  end;
  if ((TComponent(Sender).Name = 'Chart5_f2_nd') and (i>=0)) then
  begin
    StringGrid2.Cells[0,0]:='ChighMax_Daily_Avg_nd';
    StringGrid2.Cells[1,0]:='ClowMin_Daily_Avg_nd';
    StringGrid2.Cells[2,0]:='ChighMax_AtOnce_Avg_nd';
    StringGrid2.Cells[3,0]:='ClowMin_AtOnce_Avg_nd';

    StringGrid2.Cells[0,1]:=arrDataChart_values[i,32];
    StringGrid2.Cells[1,1]:=arrDataChart_values[i,33];
    StringGrid2.Cells[2,1]:=arrDataChart_values[i,34];
    StringGrid2.Cells[3,1]:=arrDataChart_values[i,35];
  end;

end;

procedure TForm2.PageControl1_f2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if ssDouble in Shift then
  if (Sender is TPageControl) then
    SetForegroundWindow(form1.Handle);
end;

procedure TForm2.PageControl1_f2Change(Sender: TObject);
begin
  form1.iChartNumber1:=form1.iChartNumber2;
  form1.iChartNumber2:=PageControl1_f2.ActivePageIndex;
  form1.PageControl1.ActivePageIndex:=self.PageControl1_f2.ActivePageIndex;
end;






end.
