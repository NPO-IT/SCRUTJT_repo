unit WriteGistUnit;

interface
uses
Classes, SysUtils, Dialogs;
const
//количество файлов-гистограмм
FILE_NUM=24;
//количество байт в пакете
POCKETSIZE=28;

type
//поток для записи
TThreadWrite = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
end;

// тип для хранения записи попадания в подинтервал(интервал)
TStrikeRec=record
  //интервал
  interval:double;
  //количество попаданий в интервал
  countStrike:cardinal;
end;

//динамический массив записей 
TStrikeRecArr=array of TStrikeRec;

TfastProc=array of byte;
var
//массив текстовых файлов
filesGistArray:array [1..FILE_NUM] of text;
//массив буферов значений для каждого файла
arrOfFastProcArray:array [1..FILE_NUM] of TfastProc;
//массив записей  попадания в подинтервал(интервал)
countsStrikeArr:array [1..FILE_NUM] of TStrikeRecArr;
//поток чтения из файла
readStream: TFileStream;
//поток чтения
thWriteGist: TThreadWrite;
//массив содержимого текущего пакета
pocket:array[1..POCKETSIZE]  of byte;
implementation
uses
Unit1;

//==============================================================================
//Разбираем файловые буферы
//==============================================================================
procedure ParseFileBuffer(numValInFfileBufer:integer);
var
iBufArrCount:integer;
fileBufCount:integer;
inlCount:integer;

//hh:integer;
begin
//iBufArrCount:=1;
//hh:= length(countsStrikeArr[iBufArrCount]);
//form1.Memo1.Lines.Add(intToStr(hh));

//разбираем пофайлово
iBufArrCount:=1;
while iBufArrCount<=FILE_NUM do
  begin
    //проверяем подключен ли канал, если нет то и не проверяем его, там нули
    if (arrEnableSensors[iBufArrCount]) then
      begin
        //разбор файла поэлементно
        fileBufCount:=0;
        while fileBufCount<=numValInFfileBufer-1 do   //!!!
          begin
            //проверяем в какой интервал элемент вошел
            inlCount:=0;
            while inlCount<=length(countsStrikeArr[iBufArrCount])-1 do
              begin
                //проверяем, от левого края интервала до правого
                if ((arrOfFastProcArray[iBufArrCount][fileBufCount]>=
                      countsStrikeArr[iBufArrCount][inlCount].interval)and
                    (arrOfFastProcArray[iBufArrCount][fileBufCount]<
                      countsStrikeArr[iBufArrCount][inlCount+1].interval)) then
                  begin
                    //нашли попадание. учил и вышли из цикла поиска
                    inc(countsStrikeArr[iBufArrCount][inlCount].countStrike);
                    break;
                  end;
                inc(inlCount);
              end;
            inc(fileBufCount);
          end;
      end;
    inc(iBufArrCount);
  end;
end;
//==============================================================================



//==============================================================================
//Запись текстовых файлов гистограмм
//==============================================================================
procedure WriteHistFiles;
var
//счетчик перебора файлов
iFile:integer;
fileName:string;
//сформированная записываемая строка
writeStr:string;
//счетик перебора записей файла гистрограммы
iWriteCount:integer;
begin
//разбираем послед. буферы файлов с накоплен. точками
iFile:=1;
while iFile<=FILE_NUM do
  begin
    //проверяем подключен ли канал, если нет то не создаем файл этого канала
    if (arrEnableSensors[iFile]) then
      begin
        //формируем имя файла
        fileName:=ExtractFileDir(ParamStr(0))+'\Report\'+'\hist\'+
          'Канал'+IntToStr(iFile)+'_hist'+'.xls';
        //связали дял записи
        AssignFile(filesGistArray[iFile],fileName);
        //открыли на запись. При повторной записи предидущее содержимое затрется
        Rewrite(filesGistArray[iFile]);

        //записываем каждый файл в формате интервал колич.попаданий
        iWriteCount:=0;
        while iWriteCount<=length(countsStrikeArr[iFile])-1 do
          begin
            //формируем строку на запись
            writeStr:=FloatToStr(countsStrikeArr[iFile][iWriteCount].interval)+
              #9+IntToStr(countsStrikeArr[iFile][iWriteCount].countStrike);
            //запись строки в файл
            writeLn(filesGistArray[iFile],writeStr);
            inc(iWriteCount);
          end;
        //записали, закрыли
        CloseFile(filesGistArray[iFile]);
      end;
    //переходим на запись следующего файла
    inc(iFile);
  end;
//if
//filesGistArray
end;
//==============================================================================

//==============================================================================
//
//==============================================================================
procedure TThreadWrite.Execute;
var
ind:integer;
i:integer;
//счетчик обработанных пакетов
k:integer;

//h:integer;
begin
  ind:=0;
  k:=0;
  readStream:=TFileStream.Create(SCRUTfileArr[ind].path,fmShareDenyNone{fmOpenRead});


  //h:=length(SCRUTfileArr);
  //ShowMessage(IntToStr(h));


  //РАБОТА ТОЛЬКО С БЫСТРЫМИ
  //Перебираем все найденные в каталоге файлы СКРУТА
  while ind<length(SCRUTfileArr) do
    begin

       try
        //читаем из файла 28 байтов. 1 пакет
        readStream.Read(pocket, SizeOf(pocket));

        //разбираем считанный пакет по буферам файлов. по 1 значению
        i:=1;
        while i<=FILE_NUM do
          begin
            //заказываем по 1 точке под каждый буфер массив
            SetLength(arrOfFastProcArray[i],k+1);
            //проверяе подключен ли канал, если нет заполняем его значения нулями
            if (arrEnableSensors[i]) then
              begin
                arrOfFastProcArray[i][k]:=pocket[i+2];
              end
            else
              begin
                arrOfFastProcArray[i][k]:=0;
              end;
            inc(i);
          end;
        finally
          //проверяем не дочитали ли файл до конца
          if  readStream.Position>=readStream.Size then
            begin
              //файл обработали, закрыли и переключили индекс на следующий
              readStream.Free;
              inc(ind);
              //проверяем есть ли следующий файл на обработку
              if ind<length(SCRUTfileArr) then
                begin
                  //открыли след. файл
                  readStream:=TFileStream.Create(SCRUTfileArr[ind].path,fmShareDenyNone{fmOpenRead});
                  form1.Memo1.Lines.Add(intToStr(ind));
                end
              else
                begin
                  //т.к файл последний то обработаем количество точек которое накопилось
                  //чтоб не терять данные
                  ParseFileBuffer(k);
                  WriteHistFiles;
                  //сбросили накопленные точки
                  for k:=1 to FILE_NUM do
                    begin
                      arrOfFastProcArray[k]:=nil;
                    end;

                  //сбросили накопленные счетчики для возможности разбора с начала
                  for k:=1 to FILE_NUM do
                    begin
                      countsStrikeArr[k]:=nil;
                    end;

                  k:=0;
                  form1.Memo1.Lines.Add('!!!!Все');
                end;
            end;
        end;
        //пакет записали. переключаем буферы файлов на след позицию
        inc(k);

        //проверяем не собрали ли нужное количество точек равное чиатоте дискретизации быстр.
        if k=poolFastVal then
          begin
            //собрали количество точек соглавсно частоте дискретизации
            //передаем количество значений в каждом буфере файла быстрого процесса
            //считаем исходя из размерности 1 файла,т.к все файлы равны
            ParseFileBuffer(length(arrOfFastProcArray[1]));

            WriteHistFiles;
            //сбросили накопленные точки
            for k:=1 to FILE_NUM do
              begin
                arrOfFastProcArray[k]:=nil;
              end;
            k:=0;
          end;

    end;
//обработали файлы
thWriteGist.Free;
end;
//==============================================================================
end.
 