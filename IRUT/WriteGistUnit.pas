unit WriteGistUnit;

interface
uses
Classes, SysUtils, Dialogs;
const
//���������� ������-����������
FILE_NUM=24;
//���������� ���� � ������
POCKETSIZE=28;

type
//����� ��� ������
TThreadWrite = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
end;

// ��� ��� �������� ������ ��������� � �����������(��������)
TStrikeRec=record
  //��������
  interval:double;
  //���������� ��������� � ��������
  countStrike:cardinal;
end;

//������������ ������ ������� 
TStrikeRecArr=array of TStrikeRec;

TfastProc=array of byte;
var
//������ ��������� ������
filesGistArray:array [1..FILE_NUM] of text;
//������ ������� �������� ��� ������� �����
arrOfFastProcArray:array [1..FILE_NUM] of TfastProc;
//������ �������  ��������� � �����������(��������)
countsStrikeArr:array [1..FILE_NUM] of TStrikeRecArr;
//����� ������ �� �����
readStream: TFileStream;
//����� ������
thWriteGist: TThreadWrite;
//������ ����������� �������� ������
pocket:array[1..POCKETSIZE]  of byte;
implementation
uses
Unit1;

//==============================================================================
//��������� �������� ������
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

//��������� ���������
iBufArrCount:=1;
while iBufArrCount<=FILE_NUM do
  begin
    //��������� ��������� �� �����, ���� ��� �� � �� ��������� ���, ��� ����
    if (arrEnableSensors[iBufArrCount]) then
      begin
        //������ ����� �����������
        fileBufCount:=0;
        while fileBufCount<=numValInFfileBufer-1 do   //!!!
          begin
            //��������� � ����� �������� ������� �����
            inlCount:=0;
            while inlCount<=length(countsStrikeArr[iBufArrCount])-1 do
              begin
                //���������, �� ������ ���� ��������� �� �������
                if ((arrOfFastProcArray[iBufArrCount][fileBufCount]>=
                      countsStrikeArr[iBufArrCount][inlCount].interval)and
                    (arrOfFastProcArray[iBufArrCount][fileBufCount]<
                      countsStrikeArr[iBufArrCount][inlCount+1].interval)) then
                  begin
                    //����� ���������. ���� � ����� �� ����� ������
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
//������ ��������� ������ ����������
//==============================================================================
procedure WriteHistFiles;
var
//������� �������� ������
iFile:integer;
fileName:string;
//�������������� ������������ ������
writeStr:string;
//������ �������� ������� ����� ������������
iWriteCount:integer;
begin
//��������� ������. ������ ������ � ��������. �������
iFile:=1;
while iFile<=FILE_NUM do
  begin
    //��������� ��������� �� �����, ���� ��� �� �� ������� ���� ����� ������
    if (arrEnableSensors[iFile]) then
      begin
        //��������� ��� �����
        fileName:=ExtractFileDir(ParamStr(0))+'\Report\'+'\hist\'+
          '�����'+IntToStr(iFile)+'_hist'+'.xls';
        //������� ��� ������
        AssignFile(filesGistArray[iFile],fileName);
        //������� �� ������. ��� ��������� ������ ���������� ���������� ��������
        Rewrite(filesGistArray[iFile]);

        //���������� ������ ���� � ������� �������� �����.���������
        iWriteCount:=0;
        while iWriteCount<=length(countsStrikeArr[iFile])-1 do
          begin
            //��������� ������ �� ������
            writeStr:=FloatToStr(countsStrikeArr[iFile][iWriteCount].interval)+
              #9+IntToStr(countsStrikeArr[iFile][iWriteCount].countStrike);
            //������ ������ � ����
            writeLn(filesGistArray[iFile],writeStr);
            inc(iWriteCount);
          end;
        //��������, �������
        CloseFile(filesGistArray[iFile]);
      end;
    //��������� �� ������ ���������� �����
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
//������� ������������ �������
k:integer;

//h:integer;
begin
  ind:=0;
  k:=0;
  readStream:=TFileStream.Create(SCRUTfileArr[ind].path,fmShareDenyNone{fmOpenRead});


  //h:=length(SCRUTfileArr);
  //ShowMessage(IntToStr(h));


  //������ ������ � ��������
  //���������� ��� ��������� � �������� ����� ������
  while ind<length(SCRUTfileArr) do
    begin

       try
        //������ �� ����� 28 ������. 1 �����
        readStream.Read(pocket, SizeOf(pocket));

        //��������� ��������� ����� �� ������� ������. �� 1 ��������
        i:=1;
        while i<=FILE_NUM do
          begin
            //���������� �� 1 ����� ��� ������ ����� ������
            SetLength(arrOfFastProcArray[i],k+1);
            //�������� ��������� �� �����, ���� ��� ��������� ��� �������� ������
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
          //��������� �� �������� �� ���� �� �����
          if  readStream.Position>=readStream.Size then
            begin
              //���� ����������, ������� � ����������� ������ �� ���������
              readStream.Free;
              inc(ind);
              //��������� ���� �� ��������� ���� �� ���������
              if ind<length(SCRUTfileArr) then
                begin
                  //������� ����. ����
                  readStream:=TFileStream.Create(SCRUTfileArr[ind].path,fmShareDenyNone{fmOpenRead});
                  form1.Memo1.Lines.Add(intToStr(ind));
                end
              else
                begin
                  //�.� ���� ��������� �� ���������� ���������� ����� ������� ����������
                  //���� �� ������ ������
                  ParseFileBuffer(k);
                  WriteHistFiles;
                  //�������� ����������� �����
                  for k:=1 to FILE_NUM do
                    begin
                      arrOfFastProcArray[k]:=nil;
                    end;

                  //�������� ����������� �������� ��� ����������� ������� � ������
                  for k:=1 to FILE_NUM do
                    begin
                      countsStrikeArr[k]:=nil;
                    end;

                  k:=0;
                  form1.Memo1.Lines.Add('!!!!���');
                end;
            end;
        end;
        //����� ��������. ����������� ������ ������ �� ���� �������
        inc(k);

        //��������� �� ������� �� ������ ���������� ����� ������ ������� ������������� �����.
        if k=poolFastVal then
          begin
            //������� ���������� ����� ��������� ������� �������������
            //�������� ���������� �������� � ������ ������ ����� �������� ��������
            //������� ������ �� ����������� 1 �����,�.� ��� ����� �����
            ParseFileBuffer(length(arrOfFastProcArray[1]));

            WriteHistFiles;
            //�������� ����������� �����
            for k:=1 to FILE_NUM do
              begin
                arrOfFastProcArray[k]:=nil;
              end;
            k:=0;
          end;

    end;
//���������� �����
thWriteGist.Free;
end;
//==============================================================================
end.
 