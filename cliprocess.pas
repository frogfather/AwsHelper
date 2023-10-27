unit cliprocess;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,process;

type 

{ TAwsCli }

 TAwsCli = class(TInterfacedObject)
    private
    fProcess:TProcess;
    fParams:TStringlist;
    property params: TStringlist read fParams;
    public
    constructor create;
    procedure clearParams;
    procedure resetParams(default:boolean = true);
    procedure addParam(param:String);
    function executeCommand:TStringList;
  end;


implementation

{ TAwsCli }

constructor TAwsCli.create;
begin
  fProcess:=TProcess.Create(Nil);
  fParams:=TStringlist.Create;

end;

procedure TAwsCli.addParam(param: String);
begin
  params.Add(param);
end;

//execute the command and return the result as a string array
function TAwsCli.executeCommand: TStringList;
var
  param:integer;
  sParam:string;
begin
  result:=TStringlist.Create;
  fProcess.Executable := '/usr/local/bin/aws';
    for param:= 0 to pred(params.Count) do
      begin
      sParam:=params[param];
      fProcess.Parameters.Add(sParam);
      end;
  fProcess.Options := fProcess.Options + [poWaitOnExit, poUsePipes, poStderrToOutPut];
  fProcess.Execute;
  result.LoadFromStream(fProcess.Output);
end;

procedure TAwsCli.clearParams;
begin
  fParams.Clear;
end;

procedure TAwsCli.resetParams(default: boolean);
begin
  clearParams;
  if default then fParams.Add('-c');
end;

end.

