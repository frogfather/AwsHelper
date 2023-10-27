unit serviceLoader;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,cliProcess;
//A class to load the various services from file along
//with required and optional parameters and their types
//fetch the list of services (aws help)

type
  
  { TServiceLoader }

  TServiceLoader = class(TInterfacedObject)
    private
      fServices:TStringlist;
      fAwsCli:TAwsCli;
      function removeWeirdCharacters(input_:string):string;
    public
      constructor create;
      property serviceList:TStringlist read fServices;
  end;

implementation
const SERVICE_LIST_START = 'AVAILABLE SERVICES';
const SERVICE_LIST_END = 'SEE ALSO';
{ TServiceLoader }

constructor TServiceLoader.create;
var
  helpList:TStringlist;
  lineNo:integer;
  sLine:string;
  inServices:boolean;
begin
  fServices:=TStringlist.create;
  fAwsCli:=TAwsCli.create('/usr/local/bin/aws');
  fAwsCli.addParam('help');
  helpList:=fAwsCli.executeCommand;
  inServices:=false;
  writeln('help list '+inttostr(helplist.Count));
  for lineNo:=0 to pred(helpList.Count) do
    begin
    sLine:= removeWeirdCharacters(helpList[lineNo]);
    if (sLine.Contains(SERVICE_LIST_END)) then inServices:=false;
    if (inServices)and(sLine.Length > 0) then fServices.add(sLine.Trim.split(' ')[1]);
    if (sLine.Contains(SERVICE_LIST_START))then inServices:=true;
    end;
  for lineNo:= 0 to pred(fServices.Count) do
    writeLn(fServices[lineNo]);
end;

function TServiceLoader.removeWeirdCharacters(input_: string): string;
var
  index,removeCount:Integer;
  done: boolean;
begin
  //remove #$08 and next char if it's not a space
  done:=false;
  result:=input_;
  removeCount:=0;
  index:=0;
  while not done do
    begin
    if (result.Substring(index,1) = #$08) then
      begin
      removeCount:=removeCount+1;
      if (index < pred(result.Length)) and (result.Substring(index+1,1) <> ' ')
        then removeCount:=removeCount +1;
      end;
    if removeCount > 0 then result:=result.Remove(index,removeCount) else index:=index+1;
    removeCount:=0;
    done:=index >= pred(result.Length);
    end;
end;

end.

