unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xpman, ExtCtrls, StdCtrls, Series, TeEngine, TeeProcs, Chart,
  ComCtrls,DateUtils, Math, FileCtrl, Unit2, IniFiles;
const
POCKETSIZE=28;//размер пакета СКРУТЖТ
//TRACK_SIZE_KOEF=224;//коэф. масштабирования для ТрекБара
RTPOCKETNUM=31;// количество обр. пакетов за 10 мс таймера в реалтайме
MAXNUMINDOUBLE=1.79E25;
MAXFORERROR=1.7E10;//барьер для обхода сбоев про сборе времени
//колич. точек для подсчета спектра
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
  // тип для хранения короткой информации о файле-записи СКРУТЖТ
  TfileMiniInfo=record
    path:string;
    size:integer;
  end;

  //тип для хранения информации для выборочной записи в файл
  TrecInfo=record
    fileNumber:integer;
    fileOffset:int64;
  end;

  //тип для передаче динамич массива в качестве параметра
  TMyArrayOfString=array of TfileMiniInfo;
  //входной тип для вычисления масс. спектра
  TByteArr=array [1..MAX_POINT_IN_SPECTR] of byte;
  //возвращаемый тип спектра
  TIntArr=array [1..MAX_POINT_IN_SPECTR] of integer;
var
  Form1: TForm1;

  fileSCRUTJT:file;
  stream: TFileStream;
  iGist:integer;
  chanelIndex:integer;
  graphFlag:boolean;
  
  //массив - пакет СКРУТЖТ
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

  //количество обр. пакетов за 10 мс таймера
  numPocketSp:integer;

  //внутренний счетчик для масштабирования трекбара
  countTrack:integer;

  trackSizeKoef:integer;//коэф. масштабирования для ТрекБара
  //массив файлов
  SCRUTfileArr:TMyArrayOfString;
  fileIndex:integer;

  //полная размерность записи в байтах
  allRecordSize:Int64;

  changeFileFlag:boolean;

  kkkk:integer;

  deltaInFileForBack:Int64;
  //дин массив для записи быстрых парам. в файл
  recordInfoMas:array of TrecInfo;
  iRecordInfoMas:integer;

  //переменные для хранения пользов интервала с строковом виде
  beginInterval:string;
  endInterval:string;

  //переменная для работы с файлом конфигурации
  confIni:TIniFile;
  //счетчик точек во входном массиве для вычисления спектра
  countPointInSpArr:integer;
  //входной массив для выч. спектра
  spArrayIn:TByteArr;
   //выходной массив спектра
  spArrayOut:TIntArr;
procedure openFileForIndex(ind:integer);
function TestTime(time:string):boolean; //объявление для возможности запуска из др. юнита
procedure WriteInterval(numF:integer;offsetF:int64;timeBegStr:string;timeEndStr:string);
procedure WriteIntervalMax(numF:integer;offsetF:int64;
  timeBegStr:string;timeEndStr:string;unInterval:integer);
implementation

uses Unit3;
{$R *.dfm}
//Процедура задержки
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
//Процедуры отвечающие за вывод в файл
//==============================================================================

//процедура для записи в файл логов 
procedure SaveResultToFile(var outF:text;str:string);
begin
Writeln(outF,str);
//exit
end;
//==============================================================================

//==============================================================================
//Функция формирующая список файлов(полные пути) и полный размер записи. Без вложенности.
//==============================================================================
function FillFileArray(var treeDirPath:string;
  var SCRUTfileArr:TMyArrayOfString;var allRecordSize:Int64):boolean;
var
//запись найденного в каталоге файла
searchResult : TSearchRec;
iSCRUTfileArr:integer;

begin

allRecordSize:=0;
SCRUTfileArr:=nil;
iSCRUTfileArr:=0;

//-----------
//добавим \ в конец каталога если его нет
if treeDirPath[length(treeDirPath)]<>'\' then
  begin
    treeDirPath:=treeDirPath+'\';
  end;
//-----------

//находим первое совпадение файла исходя из условий
if FindFirst(treeDirPath+'SKRUTZHT *',faAnyFile,searchResult)=0 then
  begin
    SetLength(SCRUTfileArr,iSCRUTfileArr+1);
    //полный путь к файлу
    SCRUTfileArr[iSCRUTfileArr].path:=treeDirPath+searchResult.Name;
    //размер файла в байтах
    SCRUTfileArr[iSCRUTfileArr].size:=searchResult.Size;
    inc(iSCRUTfileArr);
    allRecordSize:=allRecordSize+searchResult.Size;
    //ищем повторные совпадения пока не найдем все
    while FindNext(searchResult) = 0 do
      begin
        SetLength(SCRUTfileArr,iSCRUTfileArr+1);
        //полный путь к файлу
        SCRUTfileArr[iSCRUTfileArr].path:=treeDirPath+searchResult.Name;
        //размер файла в байтах
        SCRUTfileArr[iSCRUTfileArr].size:=searchResult.Size;
        inc(iSCRUTfileArr);
        allRecordSize:=allRecordSize+searchResult.Size;
      end;
    FindClose(searchResult);
    result:=true;
  end
else
  begin
    //ошибка в поиске файлов
    //освобождаем структуру поиска
    FindClose(searchResult);
    result:=false;
  end;
end;
//==============================================================================


//==============================================================================
//Работа с файлом конфигурации. Вынимаем параметры для работы ПО
//==============================================================================
procedure WorkWithConfig(confPath:string);
begin
confIni:=TiniFile.Create(confPath);
confIni.Free;
end;
//==============================================================================

//==============================================================================
//Функция для сбора счетчика пакета. Передается номер младшего байта. Вернет счетчик
//==============================================================================
function CollectCounter(iByteDj:integer):word;
var
cSCRUTJT:word;
begin
cSCRUTJT:=0;
cSCRUTJT:=cSCRUTJT+pocketSCRUTJT[iByteDj+1];//записали старший байт
cSCRUTJT:=cSCRUTJT shl 8;
cSCRUTJT:=cSCRUTJT+pocketSCRUTJT[iByteDj];//записали младший байт
//form1.Memo1.Lines.Add('Содержимое счетчика пакета СКРУТЖТ '+IntToStr(cSCRUTJT));
//form1.Memo1.Lines.Add('');
result:=cSCRUTJT;
end;
//==============================================================================

//==============================================================================
//Сбор медленного параметра
//==============================================================================
function CollectSlowParam(iB:integer):word;
begin
result:=pocketSCRUTJT[iB]+pocketSCRUTJT[iB+1] shl 8;
end;
//==============================================================================


//==============================================================================
//Собираем значение времени
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
    //сбрасываем счетчик байтов времени от 1..8
    skT:=1;
    //сбрасываем счетчик для выборки
    cT:=1;
    //конвертируем 8 байт в тип double, тип в котором считается время
    pTime:=@timeGeosArr[1];
    timeGEOS:=pTime^;//содержит количество секунд с 1 января 2008г.

    //в случае сбоя проверка на отрицательное время
    if timeGEOS<0 then
      begin
        timeTime:=-1;
      end
    else
      begin
        //в случае слишком большого числа и переполнения разрядной сетки
        if  timeGEOS<={239578053.0}MAXNUMINDOUBLE then
          begin
            timeTime:=Trunc(timeGEOS);
          end
        else
          begin
            timeTime:=-1;
          end;
      end;

     //перед разбором проверка на корректность полученного времени
     if  timeTime>=0 then
      begin
        timeGEOS_int:=timeTime+1199145600+14400;
        //приводим время к формату Unix (колич секунд от 1 янв 1970 г.) и переводим в дату и время
        dT:=UnixToDateTime(timeGEOS_int);
        //при большем значении возникают сбои прни преобразовании времени  строку
        if  dT<MAXFORERROR then
          begin
            //время в строковом варианте
            //dtStr:=DateTimeToStr(dT);
            //более универсально
            DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);
            {if dtStr='24.08.2015 10:16:18' then
             begin
              form1.Memo1.Lines.Add('Ошибка');
             end; }
            //вывод времени
            form1.timeLabel.Caption:=dtStr;
          end;
      end;
  end;
end;
//==============================================================================

//==============================================================================
//Собираем значение широты
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
        form1.Memo1.Lines.Add('Ошибка');
      end;}
    skS:=1;
    cS:=1;
    //конвертируем 8 байт в тип double, тип в котором считается широта
    pLat:=@latArr[1];
    lat:=pLat^;
    //получаем градусы
    lat:=lat*180/3.1415926535;
    //Обработка ошибок связаных со сбоями. с учетом шкалы измерения 0..360
    if ((lat>=0.0) and (lat<=360.0)) {((lat>=-180.0) and (lat<=180.0))}  then
      begin
        gradLat:=trunc(lat);
        //получаем минуты
        minLat:=frac(lat)*60;
        //секунды
        secLat:=frac(minLat)*60;
        secLat:=round(secLat);
        minLat:=trunc(minLat);
        latStr:=FloatToStr(gradLat)+'° '+FloatToStr(minLat)+''' '+FloatToStr(secLat)+'"';
        form1.LabelLat.Caption:=latStr;
      end;
  end;
end;
//==============================================================================

//==============================================================================
//Собираем значение долготы
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
        form1.Memo1.Lines.Add('Ошибка');
      end;}
     skD:=1;
     cD:=1;
     //конвертируем 8 байт в тип double, тип в котором считается долгота
     pLon:=@lonArr[1];
     lon:=pLon^;

     //Проверяем не сбой ли это?
     if ((lon<3.1415926535)and(lon>-3.1415926535)) then
      begin
        //получаем градусы
        lon:=lon*180/3.1415926535;
      end
     else
      begin
        lon:=-100;
      end;

     //Обработка ошибок связаных со сбоями. с учетом шкалы измерения 0..180
     if ((lon>=0.0) and (lon<=180.0)) {((lon>=-90.0) and (lon<=90.0))}  then
      begin
        gradLon:=trunc(lon);
        //получаем минуты
        minLon:=frac(lon)*60;
        //секунды
        secLon:=frac(minLon)*60;
        secLon:=round(secLon);
        minLon:=trunc(minLon);
        lonStr:=FloatToStr(gradLon)+'° '+FloatToStr(minLon)+''' '+FloatToStr(secLon)+'"';
        form1.LabelLon.Caption:=lonStr;
      end;
  end;
end;
//==============================================================================

//==============================================================================
//Вывод на диаграмму и гистограмму
//==============================================================================
procedure OutToDiaAndGist(var iB:integer);
begin
form1.Chart1.Series[0].Clear;
while iB<=POCKETSIZE-2 do
  begin
    //вывод столбца на диаграмму
    form1.Chart1.Series[0].AddXY(iB-2,pocketSCRUTJT[iB]);
    //Вывод выбранного значения байта на гистограмму
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
// Процедура открытия файла по индексу
//==============================================================================
procedure openFileForIndex(ind:integer);
begin
//if stream<>nil then
  //begin
    //освободили предидущий открытый рабочий файл СКРУТЖТ
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
//заполнение массива спектра
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
//Вычисление спектра сигнала
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

//размерность переданного массива.
arrSize:integer;
//половина размера массива
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
//отчистили спектр
form1.spectrDia.Series[0].Clear;
for i:=1 to round(length(spArrayOut)/2) do
  begin
    form1.spectrDia.Series[0].AddXY(i-1,spArrayOut[i]);
  end;

end;
//===============================================================================



//==============================================================================
//Процедура по разбору пакета СКРУТЖТ. Передается количество пакетов.
//==============================================================================
procedure ParsePocket(numberOfPocket:word;var bool:boolean);
var
i:integer;
iByte:integer;
//счетчик СКРУТЖТ
countSCRUTJT:word;//0..65535
//медленный параметр
slowParamSCRUTJ:word;
//strPocket:string;
begin
i:=1;

//для переключения между файлами
if (bool) then
  begin
    bool:=false;
    form1.TrackBar1.Position:=1;
  end;

//последовательно обрабатываем пакеты
while i<=numberOfPocket do
  begin
    try
      //читаем из файла 28 байтов
      Stream.Read(pocketSCRUTJT, SizeOf(pocketSCRUTJT));

      //первые 2 байта счетчик (0..59999)
      //счетчик пакета(слово).Собираем его.
      iByte:=1;
      countSCRUTJT:=CollectCounter(iByte);

      iByte:=3;
      //Вывод быстрых параметров на Диаграмму и вывод на график
      //1-24 быстрых по 1 байту
      OutToDiaAndGist(iByte);

      {if countPointInSpArr=101 then
        begin
          form1.Memo1.Lines.Add('1');
        end;}

      //заполняем массив для выч. спектра. c 3 байта
      countPointInSpArr:=WriteSpArr(spArrayIn,iByte-(POCKETSIZE-4),countPointInSpArr);

      //проверяем не собрали ли нужное количество точек.
      if countPointInSpArr=MAX_POINT_IN_SPECTR+1 then
        begin
          //вычисляем спектр
          countPointInSpArr:=1;
          //вычисление спектра
          spArrayOut:=CalculateSpectr(spArrayIn);
          //вывод спектра на диаграмму спектра
          OutSpectr(spArrayOut);
        end ;



      //когда счетчик ГЕОС кратен 200(200,400,600..), то вынимаем значения повторений
      //+1 т.к счетчик с 0
      if ((countSCRUTJT+1) mod 200 =0) then
        begin
          //формируем значение медленного парам.
          slowParamSCRUTJ:=CollectSlowParam(iByte);
        end;

      //Вынимаем время. Вынимаются из двух последних байтов пакета
      //время начинает приходить по счетчику каждые 2000 и по 8 байт в 4 пакетах
      if ((countSCRUTJT-cT+1) mod 2000 =0) then
        begin
          CollectTime(iByte);
        end;

      //вынимаем широту. Вынимаются из двух последних байтов пакета
      if ((countSCRUTJT-cS-3) mod 2000 =0) then
        begin
          CollectLatitude(iByte);
        end;

      //вынимаем долготу. Вынимаются из двух последних байтов пакета 
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


      //form1.Memo1.Lines.Add('Текущая позиция в файле'+IntToStr(stream.Position)+' из '+intToStr(stream.Size));
    finally
      //проверяем каждый раз дошли ли до конца файла. Дошли значит заканчиваем работу с файлом
      //form1.Memo1.Lines.Add(intToStr(stream.Position));
      if  stream.Position>=stream.Size then
        begin
          form1.Timer1.Enabled:=false;
          //проверяем не конец ли записи
          if fileIndex<length(SCRUTfileArr)-1 then
            begin
              stream.Free;
              //wait(5);
              inc(fileIndex);
              openFileForIndex(fileIndex);
              //переключаем номер файла в трекбаре номеров
              form1.FileNumTrack.Position:=form1.FileNumTrack.Position+form1.FileNumTrack.PageSize;
              form1.TrackBar1.Position:=1;
            end
          else
            begin
              //конец
              //последний файл не освобождаем
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
//количество байт в секунде
BYTEINSEC=48000;
var
fileInd:integer;
fileStream: TFileStream;
pocket: array[1..POCKETSIZE] of byte;
//номер байта в пакете
iB:integer;
//счетчик СКРУТЖТ
countS_T:word;//0..65535
//для времени
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
//перевод времени из строки
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

//для случаев сбойных данных
countBugByte:integer;
begin

countBugByte:=0;
flagSearch:=true;
//установка номера первого файла
fileInd:=0;
//нач.результат работы подпрограммы
rezBool:=false;
exitBool:=false;
//нач.иниц счетчиков для сбора времени
skT:=1;
cT:=1;

//переведем поисковую строку времени в unixTime
strInDateTime:=StrToDateTime(time);
//время в unix
strInUnixTime:=DateTimeToUnix(strInDateTime);

//fileStream.free;
//открыли файл на чтение
fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);

while (not rezBool) do
  begin
    if (exitBool) then
      begin
        exitBool:=false;
        break;
      end;
    try
      //читаем пакет
      fileStream.Read(pocket, SizeOf(pocket));

      if (flagSearch) then
        begin
          countBugByte:=countBugByte+SizeOf(pocket);
        end;

      //сбор счетчика
      iB:=1;
      countS_T:=0;
      countS_T:=countS_T+pocket[iB+1];
      countS_T:=countS_T shl 8;
      countS_T:=countS_T+pocket[iB];

      if ((countS_T-cT+1) mod 2000 =0) then
      //отлов пакетов со временем
      //сбор времени
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
                      //собрали первое значение времени
                      //считаем дельту секунд
                      deltaTime:=strInUnixTime-timeGEOS_int;
                      //проверяем корректность времени относительно начала записи
                      if (deltaTime<0) then
                        begin
                          //время до начала записи
                          break;
                        end;

                      //дельта байт
                      deltaByte:=deltaTime*BYTEINSEC;

                      //проверяем попадаем ли в размер записи
                      if deltaByte<=allRecordSize then
                        begin
                          //находим файл который надо подключить
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
                          //в iByteAcum номер файла в массиве с 0
                          //освободили старый файл
                          fileStream.Free;
                          //подключили нужный
                          fileStream:=TFileStream.Create(SCRUTfileArr[iByteAcum].path,fmOpenRead);
                          //находим смещение в байтах до нужного нам файла

                          deltaPrevF:=0;
                          for ii:=0 to iByteAcum-1 do
                            begin
                              deltaPrevF:=deltaPrevF+SCRUTfileArr[ii].size;
                            end;


                          //находим смещение в файле
                          deltaInOpenFile:=deltaByte-deltaPrevF;
                          //переходим на нужный байт в файле
                          fileStream.Position:={countBugByte-4800+}deltaInOpenFile;
                          flagSearch:=false;
                          continue;
                        end
                      else
                        begin
                          //нет такого времени
                          break;
                        end;
                    end;

                  //sss:=IntToStr(deltaByte);
                  //DateTimeToString(dtStr,'dd.mm.yyyy hh:mm:ss',dT);
                  //form2.Label5.Caption:=dtStr;
                  //application.ProcessMessages;
                  //проверяем есть ли нужное нам время поиска
                  if dtStr=time then
                    begin

                      //нашли время. записали номер файла. и смещение от его начала
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
//Процедура записи быстрых параметров в файл.
//Передаются номер файла с начальным интервалом, смещение от начала файла,строка
//со временем до какого момента писать
//==============================================================================
procedure WriteInterval(numF:integer;offsetF:int64;timeBegStr:string;timeEndStr:string);
const
//количество байт в секунде
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
//готовая строка для записи в файл
outStr:string;
//название текстового файла СКРУТЖТ
fileName:string;
SCRUTtextFile:text;
iFileName:integer;
strInUnixTimeDelta:int64;

begin
fileInd:=numF;
//открываем переданный файл
fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
//задаем смещение от начала
fileStream.Position:=offsetF;
//для сбора времени
skT:=1;
cT:=1;
//признак конца записи в файл
finish:=false;

//формируем прогресс бар максимум.
strInUnixTimeDelta:=trunc((DateTimeToUnix(StrToDateTime(timeEndStr))-
  DateTimeToUnix(StrToDateTime(timeBegStr)))*BYTEINSEC/POCKETSIZE);

form2.ProgressBar1.Min:=0;
form2.ProgressBar1.Max:=strInUnixTimeDelta-1;

//Формируем название файла СK
fileName:='СКРУТЖТ_выборка_быстрых'+DateToStr(Date)+'_'+TimeToStr(Time)+'.txt';
//меняем : на .
for iFileName:=1 to length(fileName) do
  begin
    if (fileName[iFileName]=':') then
      begin
        fileName[iFileName]:='.';
      end;
  end;


//дописываем путь до каталога
fileName:=ExtractFileDir(ParamStr(0))+'\Report\'+fileName;

//связываем файл и открываем его на запись
AssignFile(SCRUTtextFile,fileName);
ReWrite(SCRUTtextFile);

while (not finish) do
  begin
    try
      fileStream.Read(pocket, SizeOf(pocket));
      //сбор счетчика
      iB:=1;
      countS_T:=0;
      countS_T:=countS_T+pocket[iB+1];
      countS_T:=countS_T shl 8;
      countS_T:=countS_T+pocket[iB];

      //формируем строку быстрых
      iB:=3;
      outStr:='';
      while iB<=POCKETSIZE-2 do
        begin
          outStr:=outStr+IntToStr(pocket[iB])+' ';
          inc(iB)
        end;

      //Пишем содержимое
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
//Процедура записи максимумов быстрых параметров в файл.
//Передаются номер файла с начальным интервалом, смещение от начала файла,строка
//со временем до какого момента писать
//==============================================================================
procedure WriteIntervalMax(numF:integer;offsetF:int64;
  timeBegStr:string;timeEndStr:string;unInterval:integer);
const
//количество байт в секунде
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
//готовая строка для записи в файл
outStr:string;
//название текстового файла СКРУТЖТ
fileName:string;
SCRUTtextFile:text;
iFileName:integer;
strInUnixTimeDelta:int64;
iMax:integer;

//массив для хранения максимымов быстрых параметров
masMaxFastParam:array[1..POCKETSIZE-4] of integer;
masMaxFastParamPrev:array[1..POCKETSIZE-4] of integer;
//значение подинтервала в байтах
unIntervByte:int64;
iunIntervByte:int64;
begin
fileInd:=numF;
//открываем переданный файл
fileStream:=TFileStream.Create(SCRUTfileArr[fileInd].path,fmOpenRead);
//задаем смещение от начала
fileStream.Position:=offsetF;
//для сбора времени
skT:=1;
cT:=1;
//признак конца записи в файл
finish:=false;

//формируем прогресс бар максимум.
strInUnixTimeDelta:=trunc((DateTimeToUnix(StrToDateTime(timeEndStr))-
  DateTimeToUnix(StrToDateTime(timeBegStr)))*BYTEINSEC/POCKETSIZE);

form3.ProgressBar1.Min:=0;
form3.ProgressBar1.Max:=strInUnixTimeDelta-1;

//инициализируем массив маскимумов нулями.
for iMax:=1 to POCKETSIZE-4 do
  begin
    masMaxFastParam[iMax]:=0;
    masMaxFastParamPrev[iMax]:=0;
  end;

//иниц.счетчика для подинтервала
iunIntervByte:=0;
//преобразуем секунды в байты
unIntervByte:=unInterval*BYTEINSEC;

//Формируем название файла СK
fileName:='СКРУТЖТ_выборка_максимумов_быстрых'+DateToStr(Date)+'_'+TimeToStr(Time)+'.txt';
//меняем : на .
for iFileName:=1 to length(fileName) do
  begin
    if (fileName[iFileName]=':') then
      begin
        fileName[iFileName]:='.';
      end;
  end;


//дописываем путь до каталога
fileName:=ExtractFileDir(ParamStr(0))+'\Report\'+fileName;

//связываем файл и открываем его на запись
AssignFile(SCRUTtextFile,fileName);
ReWrite(SCRUTtextFile);

while (not finish) do
  begin
    try
      fileStream.Read(pocket, SizeOf(pocket));
      //сбор счетчика
      iB:=1;
      countS_T:=0;
      countS_T:=countS_T+pocket[iB+1];
      countS_T:=countS_T shl 8;
      countS_T:=countS_T+pocket[iB];

      //формируем массив быстрых
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
          //Пишем содержимое
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
//строка с адресом выбранного каталога  с файлами скрута
folderStr:string;
begin
fileIndex:=0;
//
form1.FileNumTrack.Enabled:=true;
form1.TrackBar1.Enabled:=true;

if SelectDirectory('Выберите каталог в котором лежат файлы-записи СКРУТЖТ','\', folderStr) then
  begin
    //передаем функции полное имя выбранного каталога
    //формируем дин. массив с полными путями до файлов СКРУТЖТ соотв. заданной маске
    if FillFileArray(folderStr,SCRUTfileArr,allRecordSize) then
      begin
        //подготовка трекбара номера файла
        form1.FileNumTrack.Max:=length(SCRUTfileArr);
        form1.FileNumTrack.Min:=1;
        form1.FileNumTrack.Position:=1;

        //связываем с первым файлом массива
        openFileForIndex(fileIndex);
        //считаем коэф. масштабирования относительно текущего открытого файла
        trackSizeKoef:=trunc({allRecordSize}stream.Size/POCKETSIZE/400000)+1;
        //масштабируем Трекбар
        form1.TrackBar1.Max:=trunc(stream.Size{allRecordSize}/POCKETSIZE/trackSizeKoef);
        
        //pocketCount:=1;
        //доступность кнопки старта для работы дальше
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

        //первичная инициализация скорости работы проги
        numPocketSp:=RTPOCKETNUM;

        ShowMessage('Выберите файл конфигурации');

        while (true) do
          begin
            //выбрать файл конфигурации
            if form1.OpenDialog1.Execute then
              begin
                //делаем текущий каталог каталогом по умолчанию
                form1.OpenDialog1.InitialDir := GetCurrentDir;
                //фильтр на выбор только типа ини
                form1.OpenDialog1.Filter :='INI|*.ini';
                WorkWithConfig(form1.OpenDialog1.FileName);
                break;
              end
            else
              begin
                ShowMessage('Ошибка! Файл конфигураций не выбран!');
                break;
              end;
          end;
      end
    else
      begin
        ShowMessage('Ошибка заполнения списка файлов СКРУТЖТ');
        exit;
      end;
  end
else
  begin
    ShowMessage('Каталог не выбран!');
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
//каждый проход таймера разбираем переданное колич пакетов
ParsePocket(numPocketSp,changeFileFlag);
end;

procedure TForm1.StartButtonClick(Sender: TObject);
begin
form1.StartButton.Enabled:=false;
form1.StopButton.Enabled:=true;




//начало разбора
form1.Timer1.Enabled:=true;
end;

procedure TForm1.StopButtonClick(Sender: TObject);
begin
form1.StartButton.Enabled:=true;
form1.StopButton.Enabled:=false;
form1.Timer1.Enabled:=false;
//сбрасываем вывод на гистограмму сначала
//iGist:=0;
//очищием вывод
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
//обнуление потока работы с файлом СКРУТЖТ
stream:=nil;
//Прорисовка инициализации для карты
form1.Image1.Canvas.Rectangle(0,0,form1.Image1.Width,form1.Image1.Height);

//доступность кнопок
form1.changeFile.Enabled:=true;
form1.StartButton.Enabled:=false;
form1.StopButton.Enabled:=false;
form1.Button4.Enabled:=false;
form1.FileNumTrack.Enabled:=false;
form1.TrackBar1.Enabled:=false;

//инициализация счетчика для масштабирования трекбара
countTrack:=1;
changeFileFlag:=true;
graphFlag:=false;
iGist:=0;
chanelIndex:=0;
//счетчик для заполнения массива спектра
countPointInSpArr:=1;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin

//контролируем выход за пределы конца файла

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

//доступность кнопки останова разбора. Для случая когда ПО дойдет до конца файла
form1.StopButton.Enabled:=true;

form1.Timer1.Enabled:=false;
//внесено изменение в позиции трекбара файла для правильонй выборки из файла
stream.Position:=(form1.TrackBar1.Position-1)*POCKETSIZE*trackSizeKoef;
form1.Timer1.Enabled:=true;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//ShowMessage('Все');
Stream.Free;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
numPocketSp:=form1.TrackBar2.Position;
end;

procedure TForm1.FileNumTrackChange(Sender: TObject);
begin
form1.Timer1.Enabled:=false;
//освободили предидущий выполняемый поток
stream.Free;
//очищаем графики для более красивого перехода по файлам.
form1.Chart1.Series[0].Clear;
form1.Chart2.Series[0].Clear;
//подготовка переменных для переключения
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
//связываем с выбранным файлом
fileIndex:=form1.FileNumTrack.Position-1;
openFileForIndex(fileIndex);
//считаем коэф. масштабирования относительно текущего открытого файла
trackSizeKoef:=trunc({allRecordSize}stream.Size/POCKETSIZE/400000)+1;
//масштабируем Трекбар
form1.TrackBar1.Max:=trunc(stream.Size{allRecordSize}/POCKETSIZE/trackSizeKoef);
changeFileFlag:=true;
//запуск таймера
form1.Timer1.Enabled:=true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin

{//запись файла мгновенных значений
//перед каждой записью обнуляем вспомогательный массив и его счетчик
recordInfoMas:=nil;
irecordInfoMas:=0;
//проверяем запущен ли таймер разбора. Запущен, выключаем
//if form1.Timer1.Enabled then form1.Timer1.Enabled:=false;
//stream.Free;
form1.StopButton.Click;
//перед освобождением потока запоминаем где остановились
deltaInFileForBack:=stream.Position;
stream.Free;
//form1.Hide;
form1.Enabled:=false;
form2.Show;

//запись файла среднеквадратичных отклонений в заданных полосах частот




//запись файла абсолютных максимумов за обрабатываемый интервал
//перед каждой записью обнуляем вспомогательный массив и его счетчик
recordInfoMas:=nil;
irecordInfoMas:=0;
//проверяем запущен ли таймер разбора. Запущен, выключаем
//if form1.Timer1.Enabled then form1.Timer1.Enabled:=false;
//stream.Free;
form1.StopButton.Click;
//перед освобождением потока запоминаем где остановились
deltaInFileForBack:=stream.Position;
stream.Free;
//form1.Hide;
form1.Enabled:=false;
form3.Show;  }
end;

end.
