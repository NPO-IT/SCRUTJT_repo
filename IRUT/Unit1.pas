unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xpman, ExtCtrls, StdCtrls, Series, TeEngine, TeeProcs, Chart,
  ComCtrls,DateUtils, Math, FileCtrl, Unit2, IniFiles;
const
POCKETSIZE=28;//������ ������ �������
//TRACK_SIZE_KOEF=224;//����. ��������������� ��� ��������
RTPOCKETNUM=31;// ���������� ���. ������� �� 10 �� ������� � ���������
MAXNUMINDOUBLE=1.79E25;
MAXFORERROR=1.7E10;//������ ��� ������ ����� ��� ����� �������
//�����. ����� ��� �������� �������
MAX_POINT_IN_SPECTR=512;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    changeFile: TButton;
    StartButton: TButton;
    Chart1: TChart;
    Series1: TBarSeries;
    Chart2: TChart;
    Series2: TLineSeries;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Label2: TLabel;
    timeLabel: TLabel;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    StopButton: TButton;
    Splitter1: TSplitter;
    Panel2: TPanel;
    TrackBar1: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    LabelLat: TLabel;
    LabelLon: TLabel;
    Panel3: TPanel;
    Label7: TLabel;
    Label9: TLabel;
    TrackBar2: TTrackBar;
    Label5: TLabel;
    FileNumTrack: TTrackBar;
    Label6: TLabel;
    Label1: TLabel;
    Button4: TButton;
    spectrDia: TChart;
    Series3: TBarSeries;
    procedure changeFileClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure Series1Click(Sender: TChartSeries; ValueIndex: Integer;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar2Change(Sender: TObject);
    procedure FileNumTrackChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;
  // ��� ��� �������� �������� ���������� � �����-������ �������
  TfileMiniInfo=record
    path:string;
    size:integer;
  end;

  //��� ��� �������� ���������� ��� ���������� ������ � ����
  TrecInfo=record
    fileNumber:integer;
    fileOffset:int64;
  end;

  //��� ��� �������� ������� ������� � �������� ���������
  TMyArrayOfString=array of TfileMiniInfo;
  //������� ��� ��� ���������� ����. �������
  TByteArr=array [1..MAX_POINT_IN_SPECTR] of byte;
  //������������ ��� �������
  TIntArr=array [1..MAX_POINT_IN_SPECTR] of integer;
var
  Form1: TForm1;

  fileSCRUTJT:file;
  stream: TFileStream;
  iGist:integer;
  chanelIndex:integer;
  graphFlag:boolean;
  
  //������ - ����� �������
  pocketSCRUTJT: array[1..POCKETSIZE] of byte;

  //---time
  timeGeosArr :array [1..8] of byte;
  skT,cT:integer;

  //---latitude
  latArr :array [1..8] of byte;
  cS,skS :integer;

  //---longtitude
  lonArr:array [1..8] of byte;
  cD,skD :integer;

  //���������� ���. ������� �� 10 �� �������
  numPocketSp:integer;

  //���������� ������� ��� ��������������� ��������
  countTrack:integer;

  trackSizeKoef:integer;//����. ��������������� ��� ��������
  //������ ������
  SCRUTfileArr:TMyArrayOfString;
  fileIndex:integer;

  //������ ����������� ������ � ������
  allRecordSize:Int64;

  changeFileFlag:boolean;

  kkkk:integer;

  deltaInFileForBack:Int64;
  //��� ������ ��� ������ ������� �����. � ����
  recordInfoMas:array of TrecInfo;
  iRecordInfoMas:integer;

  //���������� ��� �������� ������� ��������� � ��������� ����
  beginInterval:string;
  endInterval:string;

  //���������� ��� ������ � ������ ������������
  confIni:TIniFile;
  //������� ����� �� ������� ������� ��� ���������� �������
  countPointInSpArr:integer;
  //������� ������ ��� ���. �������
  spArrayIn:TByteArr;
   //�������� ������ �������
  spArrayOut:TIntArr;
procedure openFileForIndex(ind:integer);
function TestTime(time:string):boolean; //���������� ��� ����������� ������� �� ��. �����
procedure WriteInterval(numF:integer;offsetF:int64;timeBegStr:string;timeEndStr:string);
procedure WriteIntervalMax(numF:integer;offsetF:int64;
  timeBegStr:string;timeEndStr:string;unInterval:integer);
implementation

uses Unit3;
{$R *.dfm}
//��������� ��������
//==============================================================================
procedure Wait(value:integer);
var
  i:integer;
begin
  for i:=1 to value do
  begin
    sleep(3);
    application.ProcessMessages;
  end;
end;
//==============================================================================

//==============================================================================
//��������� ���������� �� ����� � ����
//==============================================================================

//��������� ��� ������ � ���� ����� 
procedure SaveResultToFile(var outF:text;str:string);
begin
Writeln(outF,str);
//exit
end;
//==============================================================================

//==============================================================================
//������� ����������� ������ ������(������ ����) � ������ ������ ������. ��� �����������.
//==============================================================================
function FillFileArray(var treeDirPath:string;
  var SCRUTfileArr:TMyArrayOfString;var allRecordSize:Int64):boolean;
var
//������ ���������� � �������� �����
searchResult : TSearchRec;
iSCRUTfileArr:integer;

begin

allRecordSize:=0;
SCRUTfileArr:=nil;
iSCRUTfileArr:=0;

//-----------
//������� \ � ����� �������� ���� ��� ���
if treeDirPath[length(treeDirPath)]<>'\' then
  begin
    treeDirPath:=treeDirPath+'\';
  end;
//-----------

//������� ������ ���������� ����� ������ �� �������
if FindFirst(treeDirPath+'SKRUTZHT *',faAnyFile,searchResult)=0 then
  begin
    SetLength(SCRUTfileArr,iSCRUTfileArr+1);
    //������ ���� � �����
    SCRUTfileArr[iSCRUTfileArr].path:=treeDirPath+searchResult.Name;
    //������ ����� � ������
    SCRUTfileArr[iSCRUTfileArr].size:=searchResult.Size;
    inc(iSCRUTfileArr);
    allRecordSize:=allRecordSize+searchResult.Size;
    //���� ��������� ���������� ���� �� ������ ���
    while FindNext(searchResult) = 0 do
      begin
        SetLength(SCRUTfileArr,iSCRUTfileArr+1);
        //������ ���� � �����
        SCRUTfileArr[iSCRUTfileArr].path:=treeDirPath+searchResult.Name;
        //������ ����� � ������
        SCRUTfileArr[iSCRUTfileArr].size:=searchResult.Size;
        inc(iSCRUTfileArr);
        allRecordSize:=allRecordSize+searchResult.Size;
      end;
    FindClose(searchResult);
    result:=true;
  end
else
  begin
    //������ � ������ ������
    //����������� ��������� ������
    FindClose(searchResult);
    result:=false;
  end;
end;
//==============================================================================


//==============================================================================
//������ � ������ ������������. �������� ��������� ��� ������ ��
//==============================================================================
procedure WorkWithConfig(confPath:string);
begin
confIni:=TiniFile.Create(confPath);
confIni.Free;
end;
//==============================================================================

//==============================================================================
//������� ��� ����� �������� ������. ���������� ����� �������� �����. ������ �������
//==============================================================================
function CollectCounter(iByteDj:integer):word;
var
cSCRUTJT:word;
begin
cSCRUTJT:=0;
cSCRUTJT:=cSCRUTJT+pocketSCRUTJT[iByteDj+1];//�������� ������� ����
cSCRUTJT:=cSCRUTJT shl 8;
cSCRUTJT:=cSCRUTJT+pocketSCRUTJT[iByteDj];//�������� ������� ����
//form1.Memo1.Lines.Add('���������� �������� ������ ������� '+IntToStr(cSCRUTJT));
//form1.Memo1.Lines.Add('');
result:=cSCRUTJT;
end;
//==============================================================================

//==============================================================================
//���� ���������� ���������
//==============================================================================
function CollectSlowParam(iB:integer):word;
begin
result:=pocketSCRUTJT[iB]+pocketSCRUTJT[iB+1] shl 8;
end;
//==============================================================================


//==============================================================================
//�������� �������� �������
//==============================================================================
procedure CollectTime(iB:integer);
var
pTime:^double;
timeGEOS:double;
timeTime:{Extended}Int64;
timeGEOS_int:{Extended}Int64;
dT:TDateTime;
dtStr:string;
begin
timeGeosArr[skT]:=pocketSCRUTJT[iB];
timeGeosArr[skT+1]:=pocketSCRUTJT[iB+1];
skT:=skT+2;
cT:=cT+1;
if skT=9 then
  begin
    //���������� ������� ������ ������� �� 1..8
    skT:=1;
    //���������� ������� ��� �������
    cT:=1;
    //������������ 8 ���� � ��� double, ��� � ������� ��������� �����
    pTime:=@timeGeosArr[1];
    timeGEOS:=pTime^;//�������� ���������� ������ � 1 ������ 2008�.

    //� ������ ���� �������� �� ������������� �����
    if timeGEOS<0 then
      begin
        timeTime:=-1;
      end
    else
      begin
        //� ������ ������� �������� ����� � ������������ ��������� �����
        if  timeGEOS<={239578053.0}MAXNUMINDOUBLE then
          begin
            timeTime:=Trunc(timeGEOS);
          end
        else
          begin
            timeTime:=-1;
          end;
      end;

     //����� �������� �������� �� ������������ ����������� �������
     if  timeTime>=0 then
      begin
        timeGEOS_int:=timeTime+1199145600+14400;
        //�������� ����� � ������� Unix (����� ������ �� 1 ��� 1970 �.) � ��������� � ���� � �����
        dT:=UnixToDateTime(timeGEOS_int);
        //��� ������� �������� ��������� ���� ���� �������������� �������  ������
        if  dT<MAXFORERROR then
          begin
            //����� � ��������� ��������
            //dtStr:=DateTimeToStr(dT);
            //����� ������������
            DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);
            {if dtStr='24.08.2015 10:16:18' then
             begin
              form1.Memo1.Lines.Add('������');
             end; }
            //����� �������
            form1.timeLabel.Caption:=dtStr;
          end;
      end;
  end;
end;
//==============================================================================

//==============================================================================
//�������� �������� ������
//==============================================================================
procedure CollectLatitude(iB:integer);
var
pLat :^double;
lat :double;
gradLat,minLat,secLat :real;
latStr:string;
begin
latArr[skS]:=pocketSCRUTJT[iB];
latArr[skS+1]:=pocketSCRUTJT[iB+1];
skS:=skS+2;
cS:=cS+1;
if skS=9 then
  begin
    {if dtStr='24.07.2015 14:16:55' then
      begin
        form1.Memo1.Lines.Add('������');
      end;}
    skS:=1;
    cS:=1;
    //������������ 8 ���� � ��� double, ��� � ������� ��������� ������
    pLat:=@latArr[1];
    lat:=pLat^;
    //�������� �������
    lat:=lat*180/3.1415926535;
    //��������� ������ �������� �� ������. � ������ ����� ��������� 0..360
    if ((lat>=0.0) and (lat<=360.0)) {((lat>=-180.0) and (lat<=180.0))}  then
      begin
        gradLat:=trunc(lat);
        //�������� ������
        minLat:=frac(lat)*60;
        //�������
        secLat:=frac(minLat)*60;
        secLat:=round(secLat);
        minLat:=trunc(minLat);
        latStr:=FloatToStr(gradLat)+'� '+FloatToStr(minLat)+''' '+FloatToStr(secLat)+'"';
        form1.LabelLat.Caption:=latStr;
      end;
  end;
end;
//==============================================================================

//==============================================================================
//�������� �������� �������
//==============================================================================
procedure CollectLongtitude(iB:integer);
var
lon :double;
pLon :^double;
gradLon,minLon,secLon :real;
lonStr:string;
begin
lonArr[skD]:=pocketSCRUTJT[iB];
lonArr[skD+1]:=pocketSCRUTJT[iB+1];
skD:=skD+2;
cD:=cD+1;
if skD=9 then
  begin
    {if dtStr='24.07.2015 22:23:37' then
      begin
        form1.Memo1.Lines.Add('������');
      end;}
     skD:=1;
     cD:=1;
     //������������ 8 ���� � ��� double, ��� � ������� ��������� �������
     pLon:=@lonArr[1];
     lon:=pLon^;

     //��������� �� ���� �� ���?
     if ((lon<3.1415926535)and(lon>-3.1415926535)) then
      begin
        //�������� �������
        lon:=lon*180/3.1415926535;
      end
     else
      begin
        lon:=-100;
      end;

     //��������� ������ �������� �� ������. � ������ ����� ��������� 0..180
     if ((lon>=0.0) and (lon<=180.0)) {((lon>=-90.0) and (lon<=90.0))}  then
      begin
        gradLon:=trunc(lon);
        //�������� ������
        minLon:=frac(lon)*60;
        //�������
        secLon:=frac(minLon)*60;
        secLon:=round(secLon);
        minLon:=trunc(minLon);
        lonStr:=FloatToStr(gradLon)+'� '+FloatToStr(minLon)+''' '+FloatToStr(secLon)+'"';
        form1.LabelLon.Caption:=lonStr;
      end;
  end;
end;
//==============================================================================

//==============================================================================
//����� �� ��������� � �����������
//==============================================================================
procedure OutToDiaAndGist(var iB:integer);
begin
form1.Chart1.Series[0].Clear;
while iB<=POCKETSIZE-2 do
  begin
    //����� ������� �� ���������
    form1.Chart1.Series[0].AddXY(iB-2,pocketSCRUTJT[iB]);
    //����� ���������� �������� ����� �� �����������
    //==
    if (graphFlag) then
      begin
        if iB=chanelIndex+3 then
          begin
            form1.Chart2.Series[0].AddXY(iGist,pocketSCRUTJT[iB]);
            inc(iGist);
            if iGist>round(form1.Chart2.BottomAxis.Maximum) then
              begin
                iGist:=0;
                form1.Chart2.Series[0].Clear;
              end;
          end;
      end;
    //==
    inc(iB);
  end;
end;
//==============================================================================




//==============================================================================
// ��������� �������� ����� �� �������
//==============================================================================
procedure openFileForIndex(ind:integer);
begin
//if stream<>nil then
  //begin
    //���������� ���������� �������� ������� ���� �������
    //stream.Free;

    stream:=TFileStream.Create(SCRUTfileArr[ind].path,fmOpenRead);
  //end
//else
 // begin
   // stream:=TFileStream.Create(SCRUTfileArr[ind],fmOpenRead);
  //end;
end;
//==============================================================================

//==============================================================================
//���������� ������� �������
//==============================================================================
function WriteSpArr(var spArray:TByteArr;iB:integer;countWritePoint:integer):integer;
begin
//while iB<=POCKETSIZE-2 do
  //begin
    spArray[countWritePoint]:=pocketSCRUTJT[iB];
    inc(iB);
    inc(countWritePoint);
  //end;
result:=countWritePoint;
end;
//==============================================================================

//==============================================================================
//���������� ������� �������
//==============================================================================
function CalculateSpectr(spArray:TByteArr):TIntArr;
var
i:integer;
j:integer;
iPrev:integer;
Ere:array [1..round(length(spArray)/2)] of double;
Eim:array [1..round(length(spArray)/2)] of double;
Ore:array [1..round(length(spArray)/2)] of double;
Oim:array [1..round(length(spArray)/2)] of double;

XoutRe:array [1..length(spArray)] of double;
XoutIm:array [1..length(spArray)] of double;
Xout:TIntArr;

//����������� ����������� �������.
arrSize:integer;
//�������� ������� �������
arrSizeDiv2:integer;
begin
arrSize:=length(spArray);
arrSizeDiv2:=round(length(spArray)/2);

for i:=1 to  round(length(spArray)/2) do
  begin
    Ere[i]:=0.0;
    Eim[i]:=0.0;
    Ore[i]:=0.0;
    Oim[i]:=0.0;
  end;

for i:=1 to  length(spArray) do
  begin
    XoutRe[i]:=0;
    XoutIm[i]:=0;
    Xout[i]:=0;
  end;

for i:=1 to arrSizeDiv2 do
  begin
    iPrev:=i-1;
    for j:=1 to arrSizeDiv2-1 do
      begin
        Ere[i]:=Ere[i]+spArray[2*j]*cos(2*PI*j*iPrev/arrSizeDiv2);
        Eim[i]:=Eim[i]-spArray[2*j]*sin(2*PI*j*iPrev/arrSizeDiv2);

        Ore[i]:=Ore[i]+(spArray[2*j+1]*cos(2*PI*j*iPrev/arrSizeDiv2));
        Oim[i]:=Oim[i]-(spArray[2*j+1]*sin(2*PI*j*iPrev/arrSizeDiv2));
      end;
  end;
  
for i:=1 to arrSizeDiv2 do
  begin
    iPrev:=i-1;
    XoutRe[i]:=(Ere[i]+Oim[i]*sin(2*PI*iPrev/arrSize)+Ore[i]*cos(2*PI*iPrev/arrSize));
    XoutIm[i]:=(Eim[i]+Oim[i]*cos(2*PI*iPrev/arrSize)-Ore[i]*sin(2*PI*iPrev/arrSize));

    Xout[i]:=round(Sqrt(Sqr(XoutRe[i])+Sqr(XoutIm[i])));

    XoutRe[i+arrSizeDiv2]:=(Ere[i]-Oim[i]*sin(2*PI*iPrev/arrSize)-Ore[i]*cos(2*PI*iPrev/arrSize)) ;
    XoutIm[i+arrSizeDiv2]:=(Eim[i]-Oim[i]*cos(2*PI*iPrev/arrSize)+Ore[i]*sin(2*PI*iPrev/arrSize)) ;

    Xout[i+arrSizeDiv2]:=round(Sqrt(Sqr(XoutRe[i+arrSizeDiv2])+sqr(XoutIm[i+arrSizeDiv2])));
  end;

result:=Xout;
end;
//==============================================================================

//==============================================================================
//
//==============================================================================
procedure OutSpectr(spArrayOut:TIntArr);
var
i:integer;
begin
//��������� ������
form1.spectrDia.Series[0].Clear;
for i:=1 to round(length(spArrayOut)/2) do
  begin
    form1.spectrDia.Series[0].AddXY(i-1,spArrayOut[i]);
  end;

end;
//===============================================================================



//==============================================================================
//��������� �� ������� ������ �������. ���������� ���������� �������.
//==============================================================================
procedure ParsePocket(numberOfPocket:word;var bool:boolean);
var
i:integer;
iByte:integer;
//������� �������
countSCRUTJT:word;//0..65535
//��������� ��������
slowParamSCRUTJ:word;
//strPocket:string;
begin
i:=1;

//��� ������������ ����� �������
if (bool) then
  begin
    bool:=false;
    form1.TrackBar1.Position:=1;
  end;

//��������������� ������������ ������
while i<=numberOfPocket do
  begin
    try
      //������ �� ����� 28 ������
      Stream.Read(pocketSCRUTJT, SizeOf(pocketSCRUTJT));

      //������ 2 ����� ������� (0..59999)
      //������� ������(�����).�������� ���.
      iByte:=1;
      countSCRUTJT:=CollectCounter(iByte);

      iByte:=3;
      //����� ������� ���������� �� ��������� � ����� �� ������
      //1-24 ������� �� 1 �����
      OutToDiaAndGist(iByte);

      {if countPointInSpArr=101 then
        begin
          form1.Memo1.Lines.Add('1');
        end;}

      //��������� ������ ��� ���. �������. c 3 �����
      countPointInSpArr:=WriteSpArr(spArrayIn,iByte-(POCKETSIZE-4),countPointInSpArr);

      //��������� �� ������� �� ������ ���������� �����.
      if countPointInSpArr=MAX_POINT_IN_SPECTR+1 then
        begin
          //��������� ������
          countPointInSpArr:=1;
          //���������� �������
          spArrayOut:=CalculateSpectr(spArrayIn);
          //����� ������� �� ��������� �������
          OutSpectr(spArrayOut);
        end ;



      //����� ������� ���� ������ 200(200,400,600..), �� �������� �������� ����������
      //+1 �.� ������� � 0
      if ((countSCRUTJT+1) mod 200 =0) then
        begin
          //��������� �������� ���������� �����.
          slowParamSCRUTJ:=CollectSlowParam(iByte);
        end;

      //�������� �����. ���������� �� ���� ��������� ������ ������
      //����� �������� ��������� �� �������� ������ 2000 � �� 8 ���� � 4 �������
      if ((countSCRUTJT-cT+1) mod 2000 =0) then
        begin
          CollectTime(iByte);
        end;

      //�������� ������. ���������� �� ���� ��������� ������ ������
      if ((countSCRUTJT-cS-3) mod 2000 =0) then
        begin
          CollectLatitude(iByte);
        end;

      //�������� �������. ���������� �� ���� ��������� ������ ������ 
      if ((countSCRUTJT-cD-7) mod 2000 =0) then
        begin
          CollectLongtitude(iByte);
        end;


      if countTrack=trackSizeKoef then
        begin
           form1.TrackBar1.Position:=form1.TrackBar1.Position+form1.TrackBar1.PageSize;
           countTrack:=1;
        end
      else
        begin
          inc(countTrack);
        end;


      //form1.Memo1.Lines.Add('������� ������� � �����'+IntToStr(stream.Position)+' �� '+intToStr(stream.Size));
    finally
      //��������� ������ ��� ����� �� �� ����� �����. ����� ������ ����������� ������ � ������
      //form1.Memo1.Lines.Add(intToStr(stream.Position));
      if  stream.Position>=stream.Size then
        begin
          form1.Timer1.Enabled:=false;
          //��������� �� ����� �� ������
          if fileIndex<length(SCRUTfileArr)-1 then
            begin
              stream.Free;
              //wait(5);
              inc(fileIndex);
              openFileForIndex(fileIndex);
              //����������� ����� ����� � �������� �������
              form1.FileNumTrack.Position:=form1.FileNumTrack.Position+form1.FileNumTrack.PageSize;
              form1.TrackBar1.Position:=1;
            end
          else
            begin
              //�����
              //��������� ���� �� �����������
              form1.StartButton.Enabled:=false;
              form1.StopButton.Enabled:=false;
              form1.Chart1.Series[0].Clear;
              form1.Chart2.Series[0].Clear;
            end;
        end;
    //end try
    end;


    inc(i);
  end;

end;

//==============================================================================

//==============================================================================
//
//==============================================================================
function TestTime(time:string):boolean;
const
//���������� ���� � �������
BYTEINSEC=48000;
var
fileInd:integer;
fileStream: TFileStream;
pocket: array[1..POCKETSIZE] of byte;
//����� ����� � ������
iB:integer;
//������� �������
countS_T:word;//0..65535
//��� �������
timeGeosArr:array [1..8] of byte;
skT,cT:integer;
pTime:^double;
timeGEOS:double;
timeTime:{Extended}Int64;
timeGEOS_int:{Extended}Int64;
dT:TDateTime;
dtStr:string;
rezBool:boolean;
exitBool:boolean;
//������� ������� �� ������
strInDateTime:TDateTime;
strInUnixTime:Int64;
deltaTime:Int64;
deltaByte:Int64;
deltaInOpenFile:Int64;
sss:string;
byteAcum:int64;
deltaPrevF:int64;
iByteAcum:integer;
ii:integer;
flagSearch:boolean;

//��� ������� ������� ������
countBugByte:integer;
begin

countBugByte:=0;
flagSearch:=true;
//��������� ������ ������� �����
fileInd:=0;
//���.��������� ������ ������������
rezBool:=false;
exitBool:=false;
//���.���� ��������� ��� ����� �������
skT:=1;
cT:=1;

//��������� ��������� ������ ������� � unixTime
strInDateTime:=StrToDateTime(time);
//����� � unix
strInUnixTime:=DateTimeToUnix(strInDateTime);

//fileStream.free;
//������� ���� �� ������
fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);

while (not rezBool) do
  begin
    if (exitBool) then
      begin
        exitBool:=false;
        break;
      end;
    try
      //������ �����
      fileStream.Read(pocket, SizeOf(pocket));

      if (flagSearch) then
        begin
          countBugByte:=countBugByte+SizeOf(pocket);
        end;

      //���� ��������
      iB:=1;
      countS_T:=0;
      countS_T:=countS_T+pocket[iB+1];
      countS_T:=countS_T shl 8;
      countS_T:=countS_T+pocket[iB];

      if ((countS_T-cT+1) mod 2000 =0) then
      //����� ������� �� ��������
      //���� �������
        begin
          iB:=23;
          timeGeosArr[skT]:=pocket[iB];
          timeGeosArr[skT+1]:=pocket[iB+1];
          skT:=skT+2;
          cT:=cT+1;
          if skT=9 then
            begin
              skT:=1;
              cT:=1;
              pTime:=@timeGeosArr[1];
              timeGEOS:=pTime^;
              if timeGEOS<0 then
                begin
                  timeTime:=-1;
                end
              else
                begin
                  if  timeGEOS<={239578053.0}MAXNUMINDOUBLE then
                    begin
                      timeTime:=Trunc(timeGEOS);
                    end
                  else
                    begin
                      timeTime:=-1;
                    end;
                end;

              if  timeTime>=0 then
                begin
                  timeGEOS_int:=timeTime+1199145600+14400;
                  dT:=UnixToDateTime(timeGEOS_int);
                  DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);

                  if (flagSearch) then
                    begin
                      sss:=dtStr;
                      Delete(sss,11,length(sss));
                    end;

                  if ((sss<>'01.01.2008')and(flagSearch)) then
                    begin
                      //������� ������ �������� �������
                      //������� ������ ������
                      deltaTime:=strInUnixTime-timeGEOS_int;
                      //��������� ������������ ������� ������������ ������ ������
                      if (deltaTime<0) then
                        begin
                          //����� �� ������ ������
                          break;
                        end;

                      //������ ����
                      deltaByte:=deltaTime*BYTEINSEC;

                      //��������� �������� �� � ������ ������
                      if deltaByte<=allRecordSize then
                        begin
                          //������� ���� ������� ���� ����������
                          iByteAcum:=0;
                          byteAcum:=SCRUTfileArr[iByteAcum].size;
                          while iByteAcum<=length(SCRUTfileArr)-1 do
                            begin
                              if deltaByte>byteAcum then
                                begin
                                  inc(iByteAcum);
                                  byteAcum:=byteAcum+SCRUTfileArr[iByteAcum].size;
                                end
                              else
                                begin
                                  break;
                                end;
                            end;
                          //� iByteAcum ����� ����� � ������� � 0
                          //���������� ������ ����
                          fileStream.Free;
                          //���������� ������
                          fileStream:=TFileStream.Create(SCRUTfileArr[iByteAcum].path,fmOpenRead);
                          //������� �������� � ������ �� ������� ��� �����

                          deltaPrevF:=0;
                          for ii:=0 to iByteAcum-1 do
                            begin
                              deltaPrevF:=deltaPrevF+SCRUTfileArr[ii].size;
                            end;


                          //������� �������� � �����
                          deltaInOpenFile:=deltaByte-deltaPrevF;
                          //��������� �� ������ ���� � �����
                          fileStream.Position:={countBugByte-4800+}deltaInOpenFile;
                          flagSearch:=false;
                          continue;
                        end
                      else
                        begin
                          //��� ������ �������
                          break;
                        end;
                    end;

                  //sss:=IntToStr(deltaByte);
                  //DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);
                  //form2.Label5.Caption:=dtStr;
                  //application.ProcessMessages;
                  //��������� ���� �� ������ ��� ����� ������
                  if dtStr=time then
                    begin

                      //����� �����. �������� ����� �����. � �������� �� ��� ������
                      SetLength(recordInfoMas,iRecordInfoMas+1);
                      recordInfoMas[iRecordInfoMas].fileNumber:=iByteAcum;
                      recordInfoMas[iRecordInfoMas].fileOffset:=fileStream.Position;
                      inc(iRecordInfoMas);

                      rezBool:=true;
                      break;
                    end;
                end;
            end;
        end;

    finally
      if  fileStream.Position>=fileStream.Size then
        begin
          if fileIndex<length(SCRUTfileArr)-1 then
            begin
              fileStream.Free;
              //wait(5);
              inc(fileInd);
              fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
            end
          else
            begin
              exitBool:=true;
            end;
        end;
    end;
  end;

fileStream.Free;
result:=rezBool;

end;
//==============================================================================

//==============================================================================
//��������� ������ ������� ���������� � ����.
//���������� ����� ����� � ��������� ����������, �������� �� ������ �����,������
//�� �������� �� ������ ������� ������
//==============================================================================
procedure WriteInterval(numF:integer;offsetF:int64;timeBegStr:string;timeEndStr:string);
const
//���������� ���� � �������
BYTEINSEC=48000;
var
fileStream: TFileStream;
fileInd:integer;
finish:boolean;
pocket: array[1..POCKETSIZE] of byte;
iB:integer;
countS_T:word;
timeGeosArr:array [1..8] of byte;
skT,cT:integer;
pTime:^double;
timeGEOS:double;
timeTime:{Extended}Int64;
timeGEOS_int:{Extended}Int64;
dT:TDateTime;
dtStr:string;
//������� ������ ��� ������ � ����
outStr:string;
//�������� ���������� ����� �������
fileName:string;
SCRUTtextFile:text;
iFileName:integer;
strInUnixTimeDelta:int64;

begin
fileInd:=numF;
//��������� ���������� ����
fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
//������ �������� �� ������
fileStream.Position:=offsetF;
//��� ����� �������
skT:=1;
cT:=1;
//������� ����� ������ � ����
finish:=false;

//��������� �������� ��� ��������.
strInUnixTimeDelta:=trunc((DateTimeToUnix(StrToDateTime(timeEndStr))-
  DateTimeToUnix(StrToDateTime(timeBegStr)))*BYTEINSEC/POCKETSIZE);

form2.ProgressBar1.Min:=0;
form2.ProgressBar1.Max:=strInUnixTimeDelta-1;

//��������� �������� ����� �K
fileName:='�������_�������_�������'+DateToStr(Date)+'_'+TimeToStr(Time)+'.txt';
//������ : �� .
for iFileName:=1 to length(fileName) do
  begin
    if (fileName[iFileName]=':') then
      begin
        fileName[iFileName]:='.';
      end;
  end;


//���������� ���� �� ��������
fileName:=ExtractFileDir(ParamStr(0))+'\Report\'+fileName;

//��������� ���� � ��������� ��� �� ������
AssignFile(SCRUTtextFile,fileName);
ReWrite(SCRUTtextFile);

while (not finish) do
  begin
    try
      fileStream.Read(pocket, SizeOf(pocket));
      //���� ��������
      iB:=1;
      countS_T:=0;
      countS_T:=countS_T+pocket[iB+1];
      countS_T:=countS_T shl 8;
      countS_T:=countS_T+pocket[iB];

      //��������� ������ �������
      iB:=3;
      outStr:='';
      while iB<=POCKETSIZE-2 do
        begin
          outStr:=outStr+IntToStr(pocket[iB])+' ';
          inc(iB)
        end;

      //����� ����������
      SaveResultToFile(SCRUTtextFile,outStr);
      form2.ProgressBar1.Position:=form2.ProgressBar1.Position+1;

      if ((countS_T-cT+1) mod 2000 =0) then
        begin
          timeGeosArr[skT]:=pocket[iB];
          timeGeosArr[skT+1]:=pocket[iB+1];
          skT:=skT+2;
          cT:=cT+1;
          if skT=9 then
            begin
              skT:=1;
              cT:=1;
              pTime:=@timeGeosArr[1];
              timeGEOS:=pTime^;
              if timeGEOS<0 then
                begin
                  timeTime:=-1;
                end
              else
                begin
                  if  timeGEOS<={239578053.0}MAXNUMINDOUBLE then
                    begin
                      timeTime:=Trunc(timeGEOS);
                    end
                  else
                    begin
                      timeTime:=-1;
                    end;
                end;

              if  timeTime>=0 then
                begin
                  timeGEOS_int:=timeTime+1199145600+14400;
                  dT:=UnixToDateTime(timeGEOS_int);
                  if  dT<MAXFORERROR then
                    begin
                      DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);
                      //form1.Memo1.Lines.Add(dtStr);
                      if dtStr=timeEndStr then
                        begin
                          finish:=true;
                        end;
                    end;
                end;
            end
        end
    finally
      if  fileStream.Position>=fileStream.Size then
        begin
          if fileIndex<length(SCRUTfileArr)-1 then
            begin
              fileStream.Free;
              //wait(5);
              inc(fileInd);
              fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
            end
          else
            begin
              finish:=true;
            end;
        end;
    end;
  end;
fileStream.Free;
closeFile(SCRUTtextFile);
end;
//==============================================================================

//==============================================================================
//��������� ������ ���������� ������� ���������� � ����.
//���������� ����� ����� � ��������� ����������, �������� �� ������ �����,������
//�� �������� �� ������ ������� ������
//==============================================================================
procedure WriteIntervalMax(numF:integer;offsetF:int64;
  timeBegStr:string;timeEndStr:string;unInterval:integer);
const
//���������� ���� � �������
BYTEINSEC=48000;
var
fileStream: TFileStream;
fileInd:integer;
finish:boolean;
pocket: array[1..POCKETSIZE] of byte;
iB:integer;
countS_T:word;
timeGeosArr:array [1..8] of byte;
skT,cT:integer;
pTime:^double;
timeGEOS:double;
timeTime:{Extended}Int64;
timeGEOS_int:{Extended}Int64;
dT:TDateTime;
dtStr:string;
//������� ������ ��� ������ � ����
outStr:string;
//�������� ���������� ����� �������
fileName:string;
SCRUTtextFile:text;
iFileName:integer;
strInUnixTimeDelta:int64;
iMax:integer;

//������ ��� �������� ���������� ������� ����������
masMaxFastParam:array[1..POCKETSIZE-4] of integer;
masMaxFastParamPrev:array[1..POCKETSIZE-4] of integer;
//�������� ������������ � ������
unIntervByte:int64;
iunIntervByte:int64;
begin
fileInd:=numF;
//��������� ���������� ����
fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
//������ �������� �� ������
fileStream.Position:=offsetF;
//��� ����� �������
skT:=1;
cT:=1;
//������� ����� ������ � ����
finish:=false;

//��������� �������� ��� ��������.
strInUnixTimeDelta:=trunc((DateTimeToUnix(StrToDateTime(timeEndStr))-
  DateTimeToUnix(StrToDateTime(timeBegStr)))*BYTEINSEC/POCKETSIZE);

form3.ProgressBar1.Min:=0;
form3.ProgressBar1.Max:=strInUnixTimeDelta-1;

//�������������� ������ ���������� ������.
for iMax:=1 to POCKETSIZE-4 do
  begin
    masMaxFastParam[iMax]:=0;
    masMaxFastParamPrev[iMax]:=0;
  end;

//����.�������� ��� ������������
iunIntervByte:=0;
//����������� ������� � �����
unIntervByte:=unInterval*BYTEINSEC;

//��������� �������� ����� �K
fileName:='�������_�������_����������_�������'+DateToStr(Date)+'_'+TimeToStr(Time)+'.txt';
//������ : �� .
for iFileName:=1 to length(fileName) do
  begin
    if (fileName[iFileName]=':') then
      begin
        fileName[iFileName]:='.';
      end;
  end;


//���������� ���� �� ��������
fileName:=ExtractFileDir(ParamStr(0))+'\Report\'+fileName;

//��������� ���� � ��������� ��� �� ������
AssignFile(SCRUTtextFile,fileName);
ReWrite(SCRUTtextFile);

while (not finish) do
  begin
    try
      fileStream.Read(pocket, SizeOf(pocket));
      //���� ��������
      iB:=1;
      countS_T:=0;
      countS_T:=countS_T+pocket[iB+1];
      countS_T:=countS_T shl 8;
      countS_T:=countS_T+pocket[iB];

      //��������� ������ �������
      iB:=3;
      iMax:=1;
      outStr:='';
      while iB<=POCKETSIZE-2 do
        begin
          masMaxFastParamPrev[iMax]:=pocket[iB];
          if masMaxFastParam[iMax]<masMaxFastParamPrev[iMax]then
            begin
              masMaxFastParam[iMax]:=masMaxFastParamPrev[iMax];
            end;

          //masMaxFastParamPrev[iMax]:=pocket[iB];
          inc(iMax);
          inc(iB)
        end;

      iunIntervByte:=iunIntervByte+POCKETSIZE;

      if unIntervByte<=iunIntervByte then
        begin
          iunIntervByte:=1;
          outStr:='';
          while iunIntervByte<=length(masMaxFastParam) do
            begin
             outStr:=outStr+IntToStr(masMaxFastParam[iunIntervByte])+' ';
             inc(iunIntervByte)
            end;
          for iMax:=1 to POCKETSIZE-4 do
            begin
              masMaxFastParam[iMax]:=0;
              masMaxFastParamPrev[iMax]:=0;
            end;
          //����� ����������
          SaveResultToFile(SCRUTtextFile,outStr);
          iunIntervByte:=0;
        end;
      
      form3.ProgressBar1.Position:=form3.ProgressBar1.Position+1;

      if ((countS_T-cT+1) mod 2000 =0) then
        begin
          timeGeosArr[skT]:=pocket[iB];
          timeGeosArr[skT+1]:=pocket[iB+1];
          skT:=skT+2;
          cT:=cT+1;
          if skT=9 then
            begin
              skT:=1;
              cT:=1;
              pTime:=@timeGeosArr[1];
              timeGEOS:=pTime^;
              if timeGEOS<0 then
                begin
                  timeTime:=-1;
                end
              else
                begin
                  if  timeGEOS<={239578053.0}MAXNUMINDOUBLE then
                    begin
                      timeTime:=Trunc(timeGEOS);
                    end
                  else
                    begin
                      timeTime:=-1;
                    end;
                end;

              if  timeTime>=0 then
                begin
                  timeGEOS_int:=timeTime+1199145600+14400;
                  dT:=UnixToDateTime(timeGEOS_int);
                  if  dT<MAXFORERROR then
                    begin
                      DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);
                      if dtStr=timeEndStr then
                        begin
                          finish:=true;
                        end;
                    end;
                end;
            end
        end
    finally
      if  fileStream.Position>=fileStream.Size then
        begin
          if fileIndex<length(SCRUTfileArr)-1 then
            begin
              fileStream.Free;
              //wait(5);
              inc(fileInd);
              fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
            end
          else
            begin
              finish:=true;
            end;
        end;
    end;
  end;
fileStream.Free;
closeFile(SCRUTtextFile);
end;
//==============================================================================

procedure TForm1.changeFileClick(Sender: TObject);
var
//strPocket:string;
//i:integer;
//������ � ������� ���������� ��������  � ������� ������
folderStr:string;
begin
fileIndex:=0;
//
form1.FileNumTrack.Enabled:=true;
form1.TrackBar1.Enabled:=true;

if SelectDirectory('�������� ������� � ������� ����� �����-������ �������','\', folderStr) then
  begin
    //�������� ������� ������ ��� ���������� ��������
    //��������� ���. ������ � ������� ������ �� ������ ������� �����. �������� �����
    if FillFileArray(folderStr,SCRUTfileArr,allRecordSize) then
      begin
        //���������� �������� ������ �����
        form1.FileNumTrack.Max:=length(SCRUTfileArr);
        form1.FileNumTrack.Min:=1;
        form1.FileNumTrack.Position:=1;

        //��������� � ������ ������ �������
        openFileForIndex(fileIndex);
        //������� ����. ��������������� ������������ �������� ��������� �����
        trackSizeKoef:=trunc({allRecordSize}stream.Size/POCKETSIZE/400000)+1;
        //������������ �������
        form1.TrackBar1.Max:=trunc(stream.Size{allRecordSize}/POCKETSIZE/trackSizeKoef);
        
        //pocketCount:=1;
        //����������� ������ ������ ��� ������ ������
        form1.StartButton.Enabled:=true;
        form1.changeFile.Enabled:=false;
        form1.Button4.Enabled:=true;


        //---for Time
        skT:=1;
        cT:=1;

        //---for Shir
        skS:=1;
        cS:=1;

        //---for Dolg
        skD:=1;
        cD:=1;

        //��������� ������������� �������� ������ �����
        numPocketSp:=RTPOCKETNUM;

        ShowMessage('�������� ���� ������������');

        while (true) do
          begin
            //������� ���� ������������
            if form1.OpenDialog1.Execute then
              begin
                //������ ������� ������� ��������� �� ���������
                form1.OpenDialog1.InitialDir := GetCurrentDir;
                //������ �� ����� ������ ���� ���
                form1.OpenDialog1.Filter :='INI|*.ini';
                WorkWithConfig(form1.OpenDialog1.FileName);
                break;
              end
            else
              begin
                ShowMessage('������! ���� ������������ �� ������!');
                break;
              end;
          end;
      end
    else
      begin
        ShowMessage('������ ���������� ������ ������ �������');
        exit;
      end;
  end
else
  begin
    ShowMessage('������� �� ������!');
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
//������ ������ ������� ��������� ���������� ����� �������
ParsePocket(numPocketSp,changeFileFlag);
end;

procedure TForm1.StartButtonClick(Sender: TObject);
begin
form1.StartButton.Enabled:=false;
form1.StopButton.Enabled:=true;




//������ �������
form1.Timer1.Enabled:=true;
end;

procedure TForm1.StopButtonClick(Sender: TObject);
begin
form1.StartButton.Enabled:=true;
form1.StopButton.Enabled:=false;
form1.Timer1.Enabled:=false;
//���������� ����� �� ����������� �������
//iGist:=0;
//������� �����
//form1.Chart2.Series[0].Clear;
end;

procedure TForm1.Series1Click(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
iGist:=0;
if (graphFlag) then
  begin
    form1.Chart2.Series[0].Clear;
    graphFlag:=false;
  end
else
  begin
    graphFlag:=true;
    chanelIndex:=ValueIndex;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//��������� ������ ������ � ������ �������
stream:=nil;
//���������� ������������� ��� �����
form1.Image1.Canvas.Rectangle(0,0,form1.Image1.Width,form1.Image1.Height);

//����������� ������
form1.changeFile.Enabled:=true;
form1.StartButton.Enabled:=false;
form1.StopButton.Enabled:=false;
form1.Button4.Enabled:=false;
form1.FileNumTrack.Enabled:=false;
form1.TrackBar1.Enabled:=false;

//������������� �������� ��� ��������������� ��������
countTrack:=1;
changeFileFlag:=true;
graphFlag:=false;
iGist:=0;
chanelIndex:=0;
//������� ��� ���������� ������� �������
countPointInSpArr:=1;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin

//������������ ����� �� ������� ����� �����

//======================================================
if form1.TrackBar1.Position=form1.TrackBar1.Max-2 then
  begin
    form1.TrackBar1.Enabled:=false;
  end
else
  begin
    form1.TrackBar1.Enabled:=true;
  end;

if form1.TrackBar1.Position=form1.TrackBar1.Min+2 then
  begin
    form1.TrackBar1.Enabled:=false;
  end
else
  begin
    form1.TrackBar1.Enabled:=true;
  end;

//======================================================

//����������� ������ �������� �������. ��� ������ ����� �� ������ �� ����� �����
form1.StopButton.Enabled:=true;

form1.Timer1.Enabled:=false;
//������� ��������� � ������� �������� ����� ��� ���������� ������� �� �����
stream.Position:=(form1.TrackBar1.Position-1)*POCKETSIZE*trackSizeKoef;
form1.Timer1.Enabled:=true;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//ShowMessage('���');
Stream.Free;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
numPocketSp:=form1.TrackBar2.Position;
end;

procedure TForm1.FileNumTrackChange(Sender: TObject);
begin
form1.Timer1.Enabled:=false;
//���������� ���������� ����������� �����
stream.Free;
//������� ������� ��� ����� ��������� �������� �� ������.
form1.Chart1.Series[0].Clear;
form1.Chart2.Series[0].Clear;
//���������� ���������� ��� ������������
countTrack:=1;
iGist:=0;
//---for Time
skT:=1;
cT:=1;
//---for Shir
skS:=1;
cS:=1;
//---for Dolg
skD:=1;
cD:=1;
//��������� � ��������� ������
fileIndex:=form1.FileNumTrack.Position-1;
openFileForIndex(fileIndex);
//������� ����. ��������������� ������������ �������� ��������� �����
trackSizeKoef:=trunc({allRecordSize}stream.Size/POCKETSIZE/400000)+1;
//������������ �������
form1.TrackBar1.Max:=trunc(stream.Size{allRecordSize}/POCKETSIZE/trackSizeKoef);
changeFileFlag:=true;
//������ �������
form1.Timer1.Enabled:=true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin

{//������ ����� ���������� ��������
//����� ������ ������� �������� ��������������� ������ � ��� �������
recordInfoMas:=nil;
irecordInfoMas:=0;
//��������� ������� �� ������ �������. �������, ���������
//if form1.Timer1.Enabled then form1.Timer1.Enabled:=false;
//stream.Free;
form1.StopButton.Click;
//����� ������������� ������ ���������� ��� ������������
deltaInFileForBack:=stream.Position;
stream.Free;
//form1.Hide;
form1.Enabled:=false;
form2.Show;

//������ ����� ������������������ ���������� � �������� ������� ������




//������ ����� ���������� ���������� �� �������������� ��������
//����� ������ ������� �������� ��������������� ������ � ��� �������
recordInfoMas:=nil;
irecordInfoMas:=0;
//��������� ������� �� ������ �������. �������, ���������
//if form1.Timer1.Enabled then form1.Timer1.Enabled:=false;
//stream.Free;
form1.StopButton.Click;
//����� ������������� ������ ���������� ��� ������������
deltaInFileForBack:=stream.Position;
stream.Free;
//form1.Hide;
form1.Enabled:=false;
form3.Show;  }
end;

end.
