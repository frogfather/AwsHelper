unit serviceLoader;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,cliProcess,arrayUtils,param;
//A class to load the various services from file along
//with required and optional parameters and their types
//fetch the list of services (aws help)

type
  
  { TServiceLoader }

  TServiceLoader = class(TInterfacedObject)
    private
      fServices:TStringlist;
      fCommands:TStringlist;
      fParams:TParamArray;
      fAwsCli:TAwsCli;
      function removeWeirdCharacters(input_:string):string;
      function extractName(input_:string):string;
      function getTestParams:TStringlist;
    public
      constructor create;
      procedure getServiceList;
      procedure getCommandsForService(service_: string);
      procedure getParamsForCommand(service_,command_:string);
      property serviceList:TStringlist read fServices;
      property commands:TStringlist read fCommands;
      property params:TParamArray read fParams;
      property testParams:TStringlist read getTestParams;
  end;

implementation
const SERVICE_LIST_START = 'AVAILABLE SERVICES';
const COMMAND_LIST_START = 'AVAILABLE COMMANDS';
const SERVICE_LIST_END = 'SEE ALSO';
const PARAM_LIST_START = 'SYNOPSIS';
const PARAM_LIST_OPTIONS = 'OPTIONS';
{ TServiceLoader }

constructor TServiceLoader.create;
begin
  fServices:=TStringlist.create;
  fCommands:=TStringlist.create;
  fParams:=TParamArray.create;
  fAwsCli:=TAwsCli.create('/usr/local/bin/aws');
end;

procedure TServiceLoader.getServiceList;
var
  helpList:TStringlist;
  lineNo:integer;
  sLine:string;
  inServices:boolean;
begin
  fServices.Clear;
  fAwsCli.clearParams;
  fAwsCli.addParam('help');
  helpList:=fAwsCli.executeCommand;
  inServices:=false;
  for lineNo:=0 to pred(helpList.Count) do
    begin
    sLine:= removeWeirdCharacters(helpList[lineNo]);
    if (sLine.Contains(SERVICE_LIST_END)) then inServices:=false;
    if (inServices)and(sLine.Length > 0) then fServices.add(sLine.Trim.split(' ')[1]);
    if (sLine.Contains(SERVICE_LIST_START))then inServices:=true;
    end;
end;

procedure TServiceLoader.getCommandsForService(service_: string);
var
  helpList:TStringlist;
  lineNo:integer;
  sLine:string;
  inServices:boolean;
begin
  commands.Clear;
  fAwsCli.clearParams;
  fAwsCli.addParam(service_);
  fAwsCli.addParam('help');
  helpList:=fAwsCli.executeCommand;
  inServices:=false;
  for lineNo:=0 to pred(helpList.Count) do
    begin
    sLine:= removeWeirdCharacters(helpList[lineNo]);//Add if line has o at start
    if (inServices)and(sLine.Length > 0) then fCommands.add(sLine.Trim.split(' ')[1]);
    if (sLine.Contains(COMMAND_LIST_START))then inServices:=true;
    end;
end;

procedure TServiceLoader.getParamsForCommand(service_, command_: string);
var
  resultList:TStringList;
  paramName,paramDesc,paramType:string;
  paramRequired:boolean;
  inParams:Boolean;
  lineNo:integer;
  sLine:string;
begin
  params.clear;
  fAwsCli.clearParams;
  fAwsCli.addParam(service_);
  fAwsCli.addParam(command_);
  fAwsCli.addParam('help');
  resultList:=fAwsCli.executeCommand;
  inParams:=false;
  for lineNo:=0 to pred(resultList.count) do
    begin
    sLine:=removeWeirdCharacters(resultList[lineNo]);
    if inParams and (sLine.Length > 0) then
      begin
      //If it's in square brackets it's optional
      paramRequired:=(sLine.IndexOf('[')=-1);
      paramName:=extractName(sLine);
      if (paramName.IndexOf('--') > -1) then
        params.push(TParam.Create(paramName,paramRequired));
      end;
    if (sLine.Contains(PARAM_LIST_START)) then inParams:=true
    else if (sLine.Contains(PARAM_LIST_OPTIONS)) then inParams:=false;
    end;
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

function TServiceLoader.extractName(input_: string): string;
begin
  //remove square brackets, spaces and angle brackets
  result:=input_.trim.Split([' '])[0].Replace('[','').Replace(']','');
end;
//Temp method to return params in a displayable form
function TServiceLoader.getTestParams: TStringlist;
var
  lineNo:integer;
begin
  result:=TStringlist.Create;
  for lineNo:=0 to pred(params.size) do
    begin
    result.Add(params[lineNo].paramName + ' '+params[lineNo].required.toString);
    end;
end;

end.

