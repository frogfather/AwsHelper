unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  cliProcess, serviceLoader;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbService: TComboBox;
    cbCommand: TComboBox;
    lCommand: TLabel;
    lService: TLabel;
    ListBox1: TListBox;
    pServices: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure cbCommandCloseUp(Sender: TObject);
    procedure cbServiceCloseUp(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  loader:TServiceLoader;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  awsCli:TAwsCli;
begin
  awsCli:=TAwsCli.create('/usr/local/bin/aws');
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

procedure TForm1.cbCommandCloseUp(Sender: TObject);
begin
  //Get params for this command
  loader.getParamsForCommand(cbService.text,cbCommand.text);
  listbox1.items:=loader.testParams;
end;

procedure TForm1.cbServiceCloseUp(Sender: TObject);
begin
  //Get the commands for this service
  loader.getCommandsForService(cbService.Text);
  cbCommand.items:= loader.commands;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  loader:=TServiceLoader.create;
  loader.getServiceList;
  //TODO when process execution is async the line below will be done by an onComplete method
  cbService.Items:=loader.serviceList;
end;

end.

