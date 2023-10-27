unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,cliProcess;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  awsCli:TAwsCli;
begin
  awsCli:=TAwsCli.create;
  awsCli.addParam('marketplace-catalog');
  awsCli.addParam('list-entities');
  awsCli.addParam('--catalog');
  awsCli.addParam('AWSMarketplace');
  awsCli.addParam('--entity-type');
  awsCli.addParam('SaaSProduct');
  awsCli.addParam('--profile');
  awsCli.addParam('mp_cp');
  awsCli.addParam('--region');
  awsCli.addParam('us-east-1');
  listbox1.Items:= awsCli.executeCommand;

end;

end.

