unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TeeProcs, TeEngine, Chart, ExtCtrls, DB, ADODB, ComCtrls,
  StdCtrls, Grids, DBGrids, Series, TeeURL, TeeSeriesTextEd, OHLChart,
  CandleCh, Menus, Unit2, StrUtils, ComObj, DBTables, TeeStore, DateUtils;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ADOConnection1: TADOConnection;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    Chart2: TChart;
    DBGrid1: TDBGrid;
    ds_dpSelectNtSettingsFilesParameters_cn: TDataSource;
    SeriesTextSource1: TSeriesTextSource;
    Series2: TLineSeries;
    SeriesTextSource2: TSeriesTextSource;
    Series3: TLineSeries;
    SeriesTextSource3: TSeriesTextSource;
    Chart3: TChart;
    Series4: TLineSeries;
    SeriesTextSource4: TSeriesTextSource;
    Series5: TLineSeries;
    SeriesTextSource5: TSeriesTextSource;
    SeriesTextSource6: TSeriesTextSource;
    Chart4: TChart;
    Series6: TLineSeries;
    Chart1: TChart;
    Series1: TCandleSeries;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    StringGrid1: TStringGrid;
    btnLoadCharts: TButton;
    btnLoadAllCharts: TButton;
    sbAlphaBlend: TScrollBar;
    Label1: TLabel;
    lbAlphaBlend: TLabel;
    btnCalcCorr: TButton;
    btnCalcCorr_settings: TButton;
    sp_dpPrepareDataForCalc: TADOStoredProc;
    sp_dpSelectNtSettingsFilesParameters_cn: TADOStoredProc;
    DBGrid2: TDBGrid;
    sp_dpSelectNtSettingsPeriodsParameters_cn: TADOStoredProc;
    ds_dpSelectNtSettingsPeriodsParameters_cn: TDataSource;
    Button1: TButton;
    btnStartTimer: TButton;
    lblState: TLabel;
    btnCalcCorrThreadId: TButton;
    Timer1: TTimer;
    btnRefreshData: TButton;
    N21: TMenuItem;
    Button2: TButton;
    N4: TMenuItem;
    cbLoadChartsAfterCalc: TCheckBox;
    N22: TMenuItem;
    sp_dpSelectParamsByParamsIdentifyer: TADOStoredProc;
    btnLoadChartsByCurrencyId: TButton;
    btnLoadTotalChartsByCurrencyId: TButton;
    btnLoadAllTotalCharts: TButton;
    Chart5: TChart;
    Series7: TLineSeries;
    SeriesTextSource7: TSeriesTextSource;
    Series8: TLineSeries;
    SeriesTextSource8: TSeriesTextSource;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure CreateTabs;
    procedure pLoadCharts(PIPageIndex: integer; IsLoadOnlyTotalCharts: integer = 0);
    procedure pLoadChartsByCurrencyId(IsLoadOnlyTotalCharts: integer = 0);
    procedure btnLoadChartsClick(Sender: TObject);
    procedure btnLoadAllChartsClick(Sender: TObject);
    procedure pLoadAllCharts(IsLoadOnlyTotalCharts: integer = 0);
    procedure PageControl1Change(Sender: TObject);
    procedure sbAlphaBlendChange(Sender: TObject);
    procedure btnCalcCorrClick(Sender: TObject);
    procedure btnCalcCorr_settingsClick(Sender: TObject);
    procedure pCalcCorrAccess;
    procedure pPrepareDataForCalc;
    procedure Chart2Click(Sender: TObject);
    procedure sp_dpSelectNtSettingsFilesParameters_cnAfterScroll(
      DataSet: TDataSet);
    procedure DBGrid2KeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure pDefineThreadId;
    procedure pCalcCorrAllByThreadId;
    procedure btnStartTimerClick(Sender: TObject);
    procedure btnCalcCorrThreadIdClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnRefreshDataClick(Sender: TObject);
    procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N21Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N22Click(Sender: TObject);
    procedure btnLoadChartsByCurrencyIdClick(Sender: TObject);
    procedure btnLoadTotalChartsByCurrencyIdClick(Sender: TObject);
    procedure btnLoadAllTotalChartsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Form2: TForm2;
    ThreadId: integer;
    ExeFileName: String;
    iChartNumber: integer;
    iChartNumber1: integer;
    iChartNumber2: integer;
    DateTimeLastTimerStart: TDateTime;


  end;

var
  Form1: TForm1;


implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  sp_dpSelectNtSettingsFilesParameters_cn.Close;
  ADOConnection1.Connected:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin


  ADOConnection1.Connected:=true;
//  sp_dpSelectNtSettingsFilesParameters_cn.CommandText:= 'Select top 4 ParamsIdentifyer, pCountCharts From ntSettingsFilesParameters_cn';
//  sp_dpSelectNtSettingsFilesParameters_cn.CommandText:= 'Select top 15 * From ntSettingsFilesParameters_cn';
  sp_dpSelectNtSettingsFilesParameters_cn.Open;
  sp_dpSelectNtSettingsFilesParameters_cn.First;


  RegisterClass(TPageControl);
  RegisterClass(TPanel);
  RegisterClass(TSplitter);
  RegisterClass(TTabSheet);
  RegisterClass(TLineSeries);
  RegisterClass(TStringGrid);
  RegisterClass(TButton);
  RegisterClass(TAreaSeries);
  RegisterClass(TShape);

  Form2:=TForm2.Create(self);
  Form2.Show;
  form2.WindowState:=wsMaximized;

  form2.Panel2_f2.Left:=0;
  form2.Panel2_f2.Top:=5;
  form2.Panel2_f2.Height:=form2.Height-form2.Panel1_f2.Height-66;

  form2.Panel3_f2.Left:=Round(form2.Chart1_f2.Width/1400*1000)+2;
  form2.Panel3_f2.Top:=5;
  form2.Panel3_f2.Height:=form2.Height-form2.Panel1_f2.Height-66;

  Form2.CreateTabs(self);

  Form1.MainMenu1.Items[0].Visible:=false;
  form1.WindowState:=wsMaximized;
  CreateTabs;

  sp_dpSelectNtSettingsFilesParameters_cn.First;

  self.PageControl1.ActivePageIndex:=0;
  form2.PageControl1_f2.ActivePageIndex:=0;

  self.PageControl1.Pages[1].TabVisible:=false;
  form2.PageControl1_f2.Pages[1].TabVisible:=false;


  form1.alphablend:=true;
  sbAlphaBlend.Position:=((255*20) div 100); //52;

  pDefineThreadId; //  определили наш ThreadId (последний символ в имени exe-файла)
  btnCalcCorrThreadId.Caption:=btnCalcCorrThreadId.Caption + inttostr(ThreadId);
  btnStartTimer.Caption:=btnStartTimer.Caption + inttostr(ThreadId);
  form1.Caption:=ExeFileName+'_current';
  form2.Caption:=ExeFileName+'_history';

  iChartNumber:=0;

//  n21.ShortCut := menus.ShortCut(VK_NUMPAD7, []);
  n2.ShortCut := menus.ShortCut(VK_DIVIDE, []);
  n3.ShortCut := menus.ShortCut(VK_MULTIPLY, []);
  n21.ShortCut := menus.ShortCut(VK_ADD, []);
//  n4.ShortCut := menus.ShortCut(VK_TAB, []);
  n4.ShortCut := menus.ShortCut(VK_SUBTRACT, []);
  n22.ShortCut := menus.ShortCut(VK_TAB, []);
{
VK_NUMPAD0 - 0
VK_NUMPAD1 - 1
VK_NUMPAD2 - 2
VK_NUMPAD3 - 3
VK_NUMPAD4 - 4
VK_NUMPAD5 - 5
VK_NUMPAD6 - 6
VK_NUMPAD7 - 7
VK_NUMPAD8 - 8
VK_NUMPAD9 - 9
VK_MULTIPLY - Multiply (* Умножение)
VK_ADD - Add (+ плюс)
VK_SEPARATOR - Separator ()
VK_SUBTRACT - Subtract()
VK_DECIMAL - Decimal(- минус)
VK_DIVIDE - Divide (/ деление)
http://delphi-box.ru/kodi-klavish-delphi.html
}

  SetForegroundWindow(form1.Handle);

  DateTimeLastTimerStart:=IncDay(Now,-1);


end;


procedure TForm1.CreateTabs;
var i,i2,i3,i4: integer;
    TS: TTabSheet;
    TS2: TTabSheet;
    Stream: TFileStream ;
    Contr: array [0..100] of TControl;
    Stream2: TFileStream ;
    Contr2: array [0..100] of TControl;
//    CL: TControl;
//    l1:TLabel;

    PanelTmp: TPanel;
    PageControlTmp: TPageControl;
    ParamsIdentifyer: String;
    pCountCharts: integer;
    SourceFileName: String;
    DataFile : TextFile;
    StrTmp,StrVal1 : string;
    StrCnt1,StrCnt2: integer;
    ticks: dword;
    SeriesTextSourceTmp: TSeriesTextSource;

    CurrencyId_tab: integer;
    CurrencyName_tab: String;
begin


   ticks := GetTickCount;


  // сохраняем компоненты с TabSheet3
  Stream := TFileStream.Create( 'AFile', fmCreate ) ;
  try
    For i:=0 to TabSheet3.ControlCount-1 do begin
      Stream.WriteComponent(TabSheet3.Controls[i]);
    end ;
  finally
    Stream.Free ;
  end;

  // сохраняем компоненты с Panel1
  Stream2 := TFileStream.Create( 'AFilePanel1', fmCreate ) ;
  try
    For i:=0 to Panel1.ControlCount-1 do begin
      Stream2.WriteComponent(Panel1.Controls[i]);
    end ;
  finally
    Stream2.Free ;
  end;



  // делаем вкладки для всех ParamsIdentifyer
  sp_dpSelectNtSettingsFilesParameters_cn.First;
  While not sp_dpSelectNtSettingsFilesParameters_cn.Eof do
  begin
    if sp_dpSelectNtSettingsFilesParameters_cn.FieldByName('IsExportToExcelCurrent').Value=1 then
    begin
      // создаем новый лист с ParamsIdentifyer
      TS:=TTabSheet.Create(PageControl1);
      TS.PageControl:=PageControl1;
      ParamsIdentifyer:=sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['ParamsIdentifyer'];
      pCountCharts:=sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['pCountCharts'];
      TS.Caption:=ParamsIdentifyer;
      TS.OnShow:=TabSheet3.OnShow;

      // создаем новый набор графиков по данному ParamsIdentifyer
      PageControlTmp:=TPageControl.Create(TS);
      PageControlTmp.Parent:=TS;
      PageControlTmp.Visible:=true;
      PageControlTmp.Align:=alClient;
      PageControlTmp.Name:='PageControlTmp';
      PageControlTmp.TabPosition:=tpBottom;

      // создаем листы с графиками
      For i2:=1 to pCountCharts do begin

        TS2:=TTabSheet.Create(PageControlTmp);
        TS2.PageControl:=PageControlTmp;
        TS2.Caption:=inttostr(i2);

        // восстанавливаем компоненты с TabSheet3
        Stream := TFileStream.Create( 'AFile', fmOpenRead ) ;
        try
          For i:=0 to TabSheet3.ControlCount-1 do begin
            Contr[i]:= Stream.ReadComponent( nil ) as TControl;
            Contr[i].Parent:=TS2;





            // обновляем DataSource для графиков (если это не сделать сразу, то тормозит)
            if Contr[i].ClassNameIs('TChart') then
            begin
                SourceFileName:='G:\forex\Access\ForexChartsHistoryData_' + ParamsIdentifyer + '\ForexChartsHistoryData' + inttostr(i2) + '.txt';

                For i4:=0 to (Contr[i] as TChart).SeriesCount-1 do begin
                    SeriesTextSourceTmp:=(Contr[i] as TChart).Series[i4].DataSource as TSeriesTextSource; // получили нужный SeriesTextSource
                    SeriesTextSourceTmp.Series:=((Contr[i] as TChart).Series[i4]);
                    SeriesTextSourceTmp.FileName:=SourceFileName;
                    {if ((FileExists(SourceFileName)) and (1=2)) then
                    begin
                      SeriesTextSourceTmp.Load;
                    end;  }
                end;

                (Contr[i] as TChart).OnMouseMove:=form2.Chart1_f2.OnMouseMove;

            end;



            // восстанавливаем компоненты на Panel1
            if Contr[i].ClassNameIs('TPanel') then
            begin
                (Contr[i] as TPanel).Caption:='';

                Stream2 := TFileStream.Create( 'AFilePanel1', fmOpenRead ) ;
                try
                  For i3:=0 to Panel1.ControlCount-1 do begin
                    Contr2[i3]:= Stream2.ReadComponent( nil ) as TControl;
                    Contr2[i3].Parent:=(Contr[i] as TPanel);

                    if Contr2[i3].ClassNameIs('TButton') then
                    begin
                      if (Contr2[i3] as TButton).Name='btnLoadCharts' then
                      begin
                        (Contr2[i3] as TButton).OnClick:=btnLoadCharts.OnClick;
                      end;
                      if (Contr2[i3] as TButton).Name='btnCalcCorr' then
                      begin
                        (Contr2[i3] as TButton).OnClick:=btnCalcCorr.OnClick;
                      end;
                      if (Contr2[i3] as TButton).Name='btnLoadChartsByCurrencyId' then
                      begin
                        (Contr2[i3] as TButton).OnClick:=btnLoadChartsByCurrencyId.OnClick;

                        sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
                        sp_dpSelectParamsByParamsIdentifyer.Open;
                        sp_dpSelectParamsByParamsIdentifyer.First;
                        CurrencyId_tab:=sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyId_current'];
                        CurrencyName_tab:=sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyName_current'];
                        sp_dpSelectParamsByParamsIdentifyer.Close;

                        (Contr2[i3] as TButton).Caption:= 'загрузить графики по CurrencyId = ' + inttostr(CurrencyId_tab) + ' (' + CurrencyName_tab + ')';

                      end;

                      if (Contr2[i3] as TButton).Name='btnLoadTotalChartsByCurrencyId' then
                      begin
                        (Contr2[i3] as TButton).OnClick:=btnLoadTotalChartsByCurrencyId.OnClick;

                        sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
                        sp_dpSelectParamsByParamsIdentifyer.Open;
                        sp_dpSelectParamsByParamsIdentifyer.First;
                        CurrencyId_tab:=sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyId_current'];
                        CurrencyName_tab:=sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyName_current'];
                        sp_dpSelectParamsByParamsIdentifyer.Close;

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


    end;
    sp_dpSelectNtSettingsFilesParameters_cn.MoveBy(1);
  end;

  ticks := GetTickCount - ticks;
  //showmessage(floattostr(ticks));
end;

procedure TForm1.N2Click(Sender: TObject);
var PageControlTmp2 :TPageControl;
begin
//  showmessage(screen.ActiveForm.Caption);

    if screen.ActiveForm.ClassNameIs('TForm1') then
    begin
      if form1.PageControl1.ActivePageIndex>1 then
      begin
        PageControlTmp2:=(form1.PageControl1.ActivePage.Controls[0] as TPageControl);
        if PageControlTmp2.ActivePageIndex=-1 then
          PageControlTmp2.ActivePageIndex:=PageControlTmp2.PageCount-1
        else
          PageControlTmp2.ActivePageIndex:=PageControlTmp2.ActivePageIndex-1;
      end;
    end
    else
    begin
      //if form2.PageControl1_f2.ActivePageIndex>1 then
      //begin
        PageControlTmp2:=(form2.PageControl1_f2 as TPageControl);
        if PageControlTmp2.ActivePageIndex=-1 then
          PageControlTmp2.ActivePageIndex:=PageControlTmp2.PageCount-1
        else
          PageControlTmp2.ActivePageIndex:=PageControlTmp2.ActivePageIndex-1;
        PageControlTmp2.OnChange(PageControlTmp2);
     // end;
    end;



end;

procedure TForm1.N3Click(Sender: TObject);
var PageControlTmp2 :TPageControl;
begin
  if screen.ActiveForm.ClassNameIs('TForm1') then
  begin
    if form1.PageControl1.ActivePageIndex>1 then
    begin
      PageControlTmp2:=(form1.PageControl1.ActivePage.Controls[0] as TPageControl);
      PageControlTmp2.ActivePageIndex:=PageControlTmp2.ActivePageIndex+1;
  //    showmessage(inttostr(PageControlTmp2.ActivePageIndex));
    end;
  end
  else
  begin
      PageControlTmp2:=(form2.PageControl1_f2 as TPageControl);
      PageControlTmp2.ActivePageIndex:=PageControlTmp2.ActivePageIndex+1;
      PageControlTmp2.OnChange(PageControlTmp2);
  end;
end;



procedure TForm1.pLoadChartsByCurrencyId(IsLoadOnlyTotalCharts: integer = 0);
var PIPageIndex: integer;
    i: integer;
    ParamsIdentifyer_active: String;
    CurrencyId_active: integer;
    ParamsIdentifyer_tab: String;
    CurrencyId_tab: integer;

begin
  //PageControlCharts:=form1.PageControl1.Pages[PIPageIndex].Controls[0] as TPageControl;
  //pCountCharts:=PageControlCharts.PageCount;

  // определяем нужный нам CurrencyId
  PIPageIndex:=form1.PageControl1.ActivePageIndex;
  ParamsIdentifyer_active:=form1.PageControl1.Pages[PIPageIndex].Caption;
  sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer_active;
  sp_dpSelectParamsByParamsIdentifyer.Open;
  sp_dpSelectParamsByParamsIdentifyer.First;
//    showmessage(sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyName']);
  CurrencyId_active:=sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyId_current'];
  sp_dpSelectParamsByParamsIdentifyer.Close;

  // перебираем все вкладки, ищем совпадающие CurrencyId
  For i:=2 to PageControl1.PageCount-1 do begin
    ParamsIdentifyer_tab:=form1.PageControl1.Pages[i].Caption;
    sp_dpSelectParamsByParamsIdentifyer.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer_tab;
    sp_dpSelectParamsByParamsIdentifyer.Open;
    sp_dpSelectParamsByParamsIdentifyer.First;
    CurrencyId_tab:=sp_dpSelectParamsByParamsIdentifyer.FieldValues['CurrencyId_current'];
    sp_dpSelectParamsByParamsIdentifyer.Close;

    if CurrencyId_tab = CurrencyId_active then
    begin
      //showmessage(inttostr(i) + '-' + inttostr(CurrencyId_tab));
      pLoadCharts(i,IsLoadOnlyTotalCharts);
    end;

    //pLoadCharts(i);
  end;

end;




procedure TForm1.pLoadCharts(PIPageIndex: integer; IsLoadOnlyTotalCharts: integer = 0);
var ControlTmp, ControlTmp2: TControl;
    PageControlCharts :TPageControl;
    TabSheetCharts :TTabSheet;
    ChartTmp: TChart;
    i,i2,i3,i4: integer;
    ParamsIdentifyer: String;
    pCountCharts: integer;
    SeriesTextSourceTmp: TSeriesTextSource;
    SourceFileName: String;
    DataFile : TextFile;
    StrTmp,StrVal1 : string;
    StrCnt1,StrCnt2: integer;
    PanelTmp: TPanel;

begin

  ParamsIdentifyer:=form1.PageControl1.Pages[PIPageIndex].Caption;
  PageControlCharts:=form1.PageControl1.Pages[PIPageIndex].Controls[0] as TPageControl;
  pCountCharts:=PageControlCharts.PageCount;


  if IsLoadOnlyTotalCharts = 0 then
  begin
    // перебираем все листы с графиками
    For i3:=0 to pCountCharts-1 do begin // i3 = индекс листа с графиком, i3+1 = номер графика
      TabSheetCharts:=PageControlCharts.Pages[i3];
          // перебираем все компоненты на листе с графиками
          For i:=0 to TabSheetCharts.ControlCount-1 do begin

            // обновляем DataSource для графиков
            if TabSheetCharts.Controls[i].ClassNameIs('TChart') then
            begin
                SourceFileName:='G:\forex\Access\ForexChartsHistoryData_' + ParamsIdentifyer + '\ForexChartsHistoryData' + inttostr(i3+1) + '.txt';
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
                if PanelTmp.Controls[i4].ClassNameIs('TStringGrid') then
                begin
                  SourceFileName:='G:\forex\Access\ForexChartsHistoryData_' + ParamsIdentifyer + '\ForexChartsHistoryDataTotal' + inttostr(i3+1) + '.txt';
                  if FileExists(SourceFileName) then
                  begin
                    AssignFile(DataFile, SourceFileName);
                    Reset(DataFile);
                    ReadLn(DataFile, StrTmp);

                    StrCnt1:=PosEx(';',StrTmp,0);
                    StrVal1:=MidStr(StrTmp,0,StrCnt1-1);
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[0,0]:='cperiodResult';
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[0,1]:=StrVal1;

                    StrCnt2:=PosEx(';',StrTmp,StrCnt1+1);
                    StrVal1:=MidStr(StrTmp,StrCnt1+1,StrCnt2-StrCnt1-1);
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[1,0]:='cdateResult';
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[1,1]:=StrVal1;
                    StrCnt1:=StrCnt2;

                    StrCnt2:=PosEx(';',StrTmp,StrCnt1+1);
                    StrVal1:=MidStr(StrTmp,StrCnt1+1,StrCnt2-StrCnt1-1);
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[2,0]:='ctimeResult';
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[2,1]:=StrVal1;
                    StrCnt1:=StrCnt2;

                    StrCnt2:=PosEx(';',StrTmp,StrCnt1+1);
                    StrVal1:=MidStr(StrTmp,StrCnt1+1,StrCnt2-StrCnt1-1);
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[3,0]:='deltaMinutesResult';
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[3,1]:=StrVal1;
                    StrCnt1:=StrCnt2;

                    StrCnt2:=PosEx(';',StrTmp,StrCnt1+1);
                    StrVal1:=MidStr(StrTmp,StrCnt1+1,StrCnt2-StrCnt1-1);
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[4,0]:='ccorrResult';
                    (PanelTmp.Controls[i4] as TStringGrid).Cells[4,1]:=StrVal1;
                    StrCnt1:=StrCnt2;

                    CloseFile(DataFile);
                  end;
                end;

              end;
            end;
          end;
    end;
  end;


  form2.pLoadCharts(PIPageIndex,pCountCharts);

end;


procedure TForm1.btnLoadChartsClick(Sender: TObject);
begin
  pLoadCharts(PageControl1.ActivePageIndex);
end;

procedure TForm1.btnLoadAllChartsClick(Sender: TObject);
begin
  pLoadAllCharts;
end;



procedure TForm1.pLoadAllCharts(IsLoadOnlyTotalCharts: integer = 0);
var i: integer;
begin
  For i:=2 to PageControl1.PageCount-1 do begin
    pLoadCharts(i,IsLoadOnlyTotalCharts);
  end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin
  form2.PageControl1_f2.ActivePageIndex:=self.PageControl1.ActivePageIndex;
end;

procedure TForm1.sbAlphaBlendChange(Sender: TObject);
begin
  form1.AlphaBlendValue:=255-sbAlphaBlend.Position; //{0-255}
  lbAlphaBlend.Caption:=floattostr((sbAlphaBlend.Position*100) div 255);
end;

procedure TForm1.btnCalcCorrClick(Sender: TObject);
begin
  pCalcCorrAccess;
end;

procedure TForm1.btnCalcCorr_settingsClick(Sender: TObject);
begin
  pCalcCorrAccess;
end;

procedure TForm1.pCalcCorrAccess;
var Access: Variant;
begin

  lblState.Caption:='Состояние: идет расчет К по ParamsIdentifyer = ' + sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['ParamsIdentifyer'];
  lblState.Font.Style := lblState.Font.Style + [fsbold];

  pPrepareDataForCalc;

  Access := CreateOleObject('Access.Application');
//  Access.Visible := True;
  Access.OpenCurrentDatabase('G:\forex\Access\forexAcc_calc' + inttostr(ThreadId) + '.mdb', True);
//  Access.DoCmd.Minimize;

  Access.Run('ProcStart'); //Имя макроса.
  Access.CloseCurrentDatabase;
  Access.Quit($00000001);

  if PageControl1.ActivePageIndex=0 then begin
    PageControl1.ActivePageIndex:=sp_dpSelectNtSettingsFilesParameters_cn.RecNo+1;
    PageControl1.OnChange(PageControl1);
  end;


  if cbLoadChartsAfterCalc.Checked then
    pLoadCharts(PageControl1.ActivePageIndex);


  lblState.Caption:='Состояние: расчет К закончен.';
  lblState.Font.Style := lblState.Font.Style - [fsbold];

end;

procedure TForm1.pDefineThreadId;
begin
  ExeFileName:=ExtractFileName(GetModuleName(0));
  ExeFileName:=MidStr(ExeFileName,1,Length(ExeFileName)-4);
  ThreadId:=strtoint(MidStr(ExeFileName,Length(ExeFileName),1)); // ThreadId = последний символ в имени exe-файла
end;

procedure TForm1.pPrepareDataForCalc;
var ParamsIdentifyer: String;
begin
// -- в таблице ntSettingsFilesParameters_cn для нужного ParamsIdentifyer меняем название БД Access (которую нужно запускать для расчета)

  if PageControl1.ActivePageIndex=0 then
    ParamsIdentifyer:=sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['ParamsIdentifyer']
  else
    ParamsIdentifyer:=PageControl1.ActivePage.Caption;

  sp_dpPrepareDataForCalc.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
  sp_dpPrepareDataForCalc.Parameters.ParamByName('@ThreadId').Value:=ThreadId;
  sp_dpPrepareDataForCalc.ExecProc;

  sp_dpSelectNtSettingsFilesParameters_cn.Refresh;

end;

procedure TForm1.Chart2Click(Sender: TObject);
begin
end;

      {
// экспорт графика в текстовый файл:
  chart2.Series[0].AddNull();
  With     TSeriesDataText.Create(chart2,chart2.Series[0]) do
  Begin
    IncludeHeader:=True;
    SaveToFile('G:\forex\Access\ForexChartsHistoryData_1_5\12.txt');
  end;
   }

procedure TForm1.sp_dpSelectNtSettingsFilesParameters_cnAfterScroll(DataSet: TDataSet);
var ParamsIdentifyer: String;
begin
  ParamsIdentifyer:=sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['ParamsIdentifyer'];


  sp_dpSelectNtSettingsPeriodsParameters_cn.Close;

  sp_dpSelectNtSettingsPeriodsParameters_cn.Parameters.ParamByName('@ParamsIdentifyer').Value:=ParamsIdentifyer;
  sp_dpSelectNtSettingsPeriodsParameters_cn.Open;
  sp_dpSelectNtSettingsPeriodsParameters_cn.First;

end;



 //i:=sp_dpSelectNtSettingsFilesParameters_cn.state;
//j:=i.
//showmessage();
  //if ((key =#13) and (sp_dpSelectNtSettingsFilesParameters_cn.State in [dsInsert,dsEdit])) then sp_dpSelectNtSettingsFilesParameters_cn.Post;

procedure TForm1.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if ((key =#13) and (sp_dpSelectNtSettingsFilesParameters_cn.State in [dsInsert,dsEdit])) then
  begin
    sp_dpSelectNtSettingsFilesParameters_cn.Post;
  end;
end;

procedure TForm1.DBGrid2KeyPress(Sender: TObject; var Key: Char);
begin
  if ((key =#13) and (sp_dpSelectNtSettingsPeriodsParameters_cn.State in [dsInsert,dsEdit])) then
  begin
    sp_dpSelectNtSettingsPeriodsParameters_cn.Post;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  pPrepareDataForCalc;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  todayTime : TDateTime;
begin
  todayTime := Time;
  if ((DayOfTheWeek(Today) in [1,2,3,4,5]) and ((SecondOf(todayTime) >= 10) and (SecondOf(todayTime) <= 15))) then
  begin
    if ((MinuteOf(todayTime) in [0,5,10,15,20,25,30,35,40,45,50,55]) and (SecondsBetween(DateTimeLastTimerStart,Now)>5) ) then
    begin
      DateTimeLastTimerStart:=Now;
      //ShowMessage(inttostr(SecondOf(Time)));
      sp_dpSelectNtSettingsFilesParameters_cn.Refresh;
      Timer1.Enabled:=false;
      pCalcCorrAllByThreadId;
      Timer1.Enabled:=true;
    end;
  end;
end;


procedure TForm1.pCalcCorrAllByThreadId;
var
  todayTime : TDateTime;
  MinuteOfTheDay_today: integer;
  MinuteOfTheDay_first: integer;
  MinuteOfTheDay_last: integer;
begin
  // рассчитываем К по всем инструментам с данным ThreadId

  // идем по таблице NtSettingsFilesParameters_cn и для записей с нашим ThreadId запускаем расчет К
  todayTime := Time;
  MinuteOfTheDay_today:=MinuteOfTheDay(todayTime); // время в минутах с начала дня
  form1.BringToFront;
  PageControl1.ActivePageIndex:=0;
  PageControl1.OnChange(PageControl1);
  sp_dpSelectNtSettingsFilesParameters_cn.Refresh;
  sp_dpSelectNtSettingsFilesParameters_cn.First;
  While not sp_dpSelectNtSettingsFilesParameters_cn.Eof do
  begin
    if (sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['ThreadId']=ThreadId) then
    begin
        MinuteOfTheDay_first:=strtoint(LeftStr(sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['cTimeFirstCalc'],2))*60 + strtoint(RightStr(sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['cTimeFirstCalc'],2)); // минимальное расчетное время в минутах
        MinuteOfTheDay_last:=strtoint(LeftStr(sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['cTimeLast'],2))*60 + strtoint(RightStr(sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['cTimeLast'],2)); // максимальное расчетное время в минутах
        if ((MinuteOfTheDay_today >= MinuteOfTheDay_first) and (MinuteOfTheDay_today <= MinuteOfTheDay_last)) then // проверяем, чтобы текущее время попадало в заданный расчетный диапазон
        begin
            //showmessage(sp_dpSelectNtSettingsFilesParameters_cn.FieldValues['ParamsIdentifyer']);
            pCalcCorrAccess;
            PageControl1.ActivePageIndex:=0;
            PageControl1.OnChange(PageControl1);
        end;
    end;
    sp_dpSelectNtSettingsFilesParameters_cn.MoveBy(1);
  end;
end;

procedure TForm1.btnStartTimerClick(Sender: TObject);
begin
  if Timer1.Enabled=false then
  begin
    Timer1.Enabled:=true;
    DateTimeLastTimerStart:=IncDay(Now,-1);
    btnStartTimer.Caption:='Остановить таймер по ThreadId = ' + inttostr(ThreadId);
    btnStartTimer.Font.Style := btnStartTimer.Font.Style + [fsbold];
  end
  else
  begin
    Timer1.Enabled:=false;
    btnStartTimer.Caption:='Запустить таймер по ThreadId = ' + inttostr(ThreadId);
    btnStartTimer.Font.Style := btnStartTimer.Font.Style - [fsbold];
    //lblState.Caption:='Состояние: расчет К закончен.';
    lblState.Font.Style := lblState.Font.Style - [fsbold];

  end;

end;

procedure TForm1.btnCalcCorrThreadIdClick(Sender: TObject);
begin
  pCalcCorrAllByThreadId;
end;



procedure TForm1.btnRefreshDataClick(Sender: TObject);
begin
  sp_dpSelectNtSettingsFilesParameters_cn.Refresh;
  sp_dpSelectNtSettingsFilesParameters_cnAfterScroll(sp_dpSelectNtSettingsFilesParameters_cn);
end;

procedure TForm1.PageControl1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if ssDouble in Shift then
  if (Sender is TPageControl) then
    SetForegroundWindow(form2.Handle);
end;

procedure TForm1.N21Click(Sender: TObject);
begin
  if screen.ActiveForm.ClassNameIs('TForm2') then
  begin
    if form2.PageControl1_f2.ActivePageIndex=iChartNumber1 then
      form2.PageControl1_f2.ActivePageIndex:=iChartNumber2
    else
      form2.PageControl1_f2.ActivePageIndex:=iChartNumber1;
{
    if iChartNumber=0 then
    begin
      form2.PageControl1_f2.ActivePageIndex:=form2.PageControl1_f2.ActivePageIndex+1;
      iChartNumber:=iChartNumber+1;
    end
    else
    begin
      form2.PageControl1_f2.ActivePageIndex:=form2.PageControl1_f2.ActivePageIndex-1;
      iChartNumber:=iChartNumber-1;
    end;
   }
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  sp_dpSelectNtSettingsFilesParameters_cn.Close;
  sp_dpSelectNtSettingsFilesParameters_cn.Open;
  sp_dpSelectNtSettingsFilesParameters_cn.First;
  sp_dpSelectNtSettingsFilesParameters_cnAfterScroll(sp_dpSelectNtSettingsFilesParameters_cn);
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  if form1.Active then
    SetForegroundWindow(form2.Handle)
  else
    SetForegroundWindow(form1.Handle);
end;



procedure TForm1.N22Click(Sender: TObject);
begin
  Form1.N4Click(self);
end;

procedure TForm1.btnLoadChartsByCurrencyIdClick(Sender: TObject);
begin
  pLoadChartsByCurrencyId;
end;

procedure TForm1.btnLoadTotalChartsByCurrencyIdClick(Sender: TObject);
begin
  pLoadChartsByCurrencyId(1);
end;

procedure TForm1.btnLoadAllTotalChartsClick(Sender: TObject);
begin
  pLoadAllCharts(1);
end;

end.
