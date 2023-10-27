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
    fExecutable:String;
    property params: TStringlist read fParams;
    public
    constructor create(executable_:string);
    procedure clearParams;
    procedure resetParams(default:boolean = true);
    procedure addParam(param:String);
    function executeCommand:TStringList;
  end;


implementation

{ TAwsCli }

constructor TAwsCli.create(executable_:String);
begin
  fParams:=TStringlist.Create;
  fExecutable:=executable_;
end;

procedure TAwsCli.addParam(param: String);
begin
  params.Add(param);
end;

//execute the command and return the result as a string array
function TAwsCli.executeCommand: TStringList;
var
  param:integer;
begin
  fProcess:=TProcess.Create(Nil);
  result:=TStringlist.Create;
  fProcess.Executable := '/usr/local/bin/aws';

  for param:= 0 to pred(params.Count) do fProcess.Parameters.Add(params[param]);
  //TODO modify to run asynchronously
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

