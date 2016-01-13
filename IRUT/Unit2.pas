unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, DateUtils, ComCtrls;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    MaskEdit1: TMaskEdit;
    MaskEdit2: TMaskEdit;
    Label5: TLabel;
    ProgressBar1: TProgressBar;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  
function TestStr(st:string):boolean;
implementation
uses Unit1;
{$R *.dfm}

function TestStr(st:string):boolean;
var
i:integer;
str:string;
begin
i:=1;
str:=st;
while (i<=length(str))do
  begin
    if ((str[i]='.')or(str[i]=':')) then  str[i]:=Chr(32);
    inc(i);
  end;
str:=TrimLeft(str);
if str='' then result:=false
  else result:=true;
end;



procedure TForm2.Button1Click(Sender: TObject);
begin

//��������� �� ������ ���� �����
if ((TestStr(form2.MaskEdit1.Text))and(TestStr(form2.MaskEdit2.Text)))then
  begin
    //��������� ���� �� ����� ����� ����� � ������
    if (TestTime(form2.MaskEdit1.Text)) then
      begin
        if (TestTime(form2.MaskEdit2.Text)) then
          begin
            beginInterval:=form2.MaskEdit1.Text;
            endInterval:=form2.MaskEdit2.Text;
            //��������� ��� ������ ��������� ������ �����
            if DateTimeToUnix(StrToDateTime(beginInterval))<
              DateTimeToUnix(StrToDateTime(endInterval)) then
              begin
                form2.MaskEdit1.Clear;
                form2.MaskEdit2.Clear;
                WriteInterval(recordInfoMas[0].fileNumber,
                  recordInfoMas[0].fileOffset,beginInterval,endInterval);
                ShowMessage('���� �������!');

                //������� �������. ��� �������
                form1.Chart1.Series[0].Clear;
                form1.Chart2.Series[0].Clear;
                //������� �������� ��� ��� ���������� �������������
                form2.ProgressBar1.Position:=0;
                //��������� ��� ���� �� ������� ���. ������
                openFileForIndex(fileIndex);
                form1.Enabled:=true;
                form2.Close;
                //form1.Show;
              end
            else
              begin
                showMessage('����� ��������� ������ ���� ������ ������!');
                form2.MaskEdit1.Clear;
                form2.MaskEdit2.Clear;
              end;
          end
        else
          begin
            showMessage('������ �������� �������� 2');
            form2.MaskEdit1.Clear;
            form2.MaskEdit2.Clear;
          end;
      end
    else
      begin
        showMessage('������ �������� �������� 1');
        form2.MaskEdit1.Clear;
        form2.MaskEdit2.Clear;
      end;
  end
else
  begin
    showMessage('���� ���������� �� ���������!');
  end;



end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
form1.Enabled:=true;
end;

end.
