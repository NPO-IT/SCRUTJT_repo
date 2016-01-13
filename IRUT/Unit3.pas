unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Mask, ExtCtrls, DateUtils;

type
  TForm3 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MaskEdit1: TMaskEdit;
    MaskEdit2: TMaskEdit;
    Button2: TButton;
    Label6: TLabel;
    ProgressBar1: TProgressBar;
    Label5: TLabel;
    Label7: TLabel;
    MaskEdit3: TMaskEdit;
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation
uses Unit1, Unit2;
{$R *.dfm}

function TestStrUnInt(str:string;var unInt:string):boolean;
var
i:integer;
j:integer;
ss:string;

begin
i:=1;
j:=1;
ss:='';
while i<=length(str) do
  begin
    if (str[i]<>' ') then
      begin
        ss:=ss+str[i];
      end;
    inc(i);
  end;
ss:=TrimLeft(ss);
unInt:=ss;
if ss='' then result:=false
  else result:=true;
end;


procedure TForm3.Button2Click(Sender: TObject);
var
unInterval:string;
begin
//��������� �� ������ ���� �����
if ((TestStr(form3.MaskEdit1.Text))and(TestStr(form3.MaskEdit2.Text)))then
  begin
    //��������� ���� �� ����� ����� ����� � ������
    if (TestTime(form3.MaskEdit1.Text)) then
      begin
        if (TestTime(form3.MaskEdit2.Text)) then
          begin
            //�������� ������������
            if TestStrUnInt(form3.MaskEdit3.Text,unInterval) then
              begin
                beginInterval:=form3.MaskEdit1.Text;
                endInterval:=form3.MaskEdit2.Text;
                //��������� ��� ������ ��������� ������ �����
                if DateTimeToUnix(StrToDateTime(beginInterval))<
                  DateTimeToUnix(StrToDateTime(endInterval)) then
                  begin
                    //�������� ��� ����������� � �������� �� ������ ������ ���������
                    if  ((DateTimeToUnix(StrToDateTime(endInterval))-
                      DateTimeToUnix(StrToDateTime(beginInterval)))>=
                        strToInt(unInterval))
                        then
                      begin
                        form3.MaskEdit1.Clear;
                        form3.MaskEdit2.Clear;
                        form3.MaskEdit3.Clear;


                        WriteIntervalMax(recordInfoMas[0].fileNumber,
                          recordInfoMas[0].fileOffset,beginInterval,endInterval,
                            strToInt(unInterval));
                        ShowMessage('���� �������!');

                        //������� �������. ��� �������
                        form1.Chart1.Series[0].Clear;
                        form1.Chart2.Series[0].Clear;
                        //������� �������� ��� ��� ���������� �������������
                        form3.ProgressBar1.Position:=0;
                        //��������� ��� ���� �� ������� ���. ������
                        openFileForIndex(fileIndex);
                        form1.Enabled:=true;
                        form3.Close;
                        //form1.Show;
                      end
                    else
                      begin
                        showMessage('����������� ������ ��������� ���������!');
                        form3.MaskEdit1.Clear;
                        form3.MaskEdit2.Clear;
                        form3.MaskEdit3.Clear;
                      end;
                  end
                else
                  begin
                   showMessage('����� ��������� ������ ���� ������ ������!');
                   form3.MaskEdit1.Clear;
                   form3.MaskEdit2.Clear;
                   form3.MaskEdit3.Clear;
                  end;
              end
            else
              begin
                showMessage('������ �������� �����������!');
                form3.MaskEdit1.Clear;
                form3.MaskEdit2.Clear;
                form3.MaskEdit3.Clear;
              end;
          end
        else
          begin
            showMessage('������ �������� �������� 2');
            form3.MaskEdit1.Clear;
            form3.MaskEdit2.Clear;
            form3.MaskEdit3.Clear;
          end;
      end
    else
      begin
        showMessage('������ �������� �������� 1');
        form3.MaskEdit1.Clear;
        form3.MaskEdit2.Clear;
        form3.MaskEdit3.Clear;
      end;
  end
else
  begin
    showMessage('���� ���������� �� ���������!');
  end;

end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
form1.Chart1.Series[0].Clear;
form1.Chart2.Series[0].Clear;
form3.ProgressBar1.Position:=0;
openFileForIndex(fileIndex);
form1.Enabled:=true;
end;

end.
