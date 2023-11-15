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
      function getDisplayName(paramName_:string):string;
      function findOption(optionList:TStringlist;paramName:string):string;
      function getParamType(option_:string):string;
      function getParamDescription(option_:string):string;
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
const PARAM_LIST_GLOBAL_OPTIONS = 'GLOBAL OPTIONS';
const PARAM_LIST_OUTPUT = 'OUTPUT';
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
  synopsisList,OptionList,GlobalOptionList:TStringList;
  paramName,paramDisplayName,paramDescription,paramType:string;
  paramRequired,paramGlobal:boolean;
  inParams,inOptions,inGlobal:Boolean;
  lineNo:integer;
  sLine,sOption:string;
begin
  params.clear;
  fAwsCli.clearParams;
  fAwsCli.addParam(service_);
  fAwsCli.addParam(command_);
  fAwsCli.addParam('help');
  resultList:=fAwsCli.executeCommand;
  synopsisList:=TStringlist.create;
  optionList:=TStringlist.create;
  globalOptionList:=TStringlist.create;
  inParams:=false;
  inOptions:=false;
  inGlobal:=false;
  //First separate the results into three lists
  //The parameters, the options for these params
  //and the global options
  for lineNo:=0 to pred(resultList.count) do
    begin
    sLine:=removeWeirdCharacters(resultList[lineNo]);

    if (inParams and (sLine.Length > 0)) then synopsisList.Add(sLine)
    else if inOptions then optionList.add(sLine)
    else if inGlobal then globalOptionList.add(sLine);

    if (sLine.Contains(PARAM_LIST_START))
      then inParams:=true
    else if (sLine.Contains(PARAM_LIST_OPTIONS) and (not sLine.Contains(PARAM_LIST_GLOBAL_OPTIONS)))
      then
        begin
        inParams:=false;
        inOptions:=true;
        end
    else if (sLine.Contains(PARAM_LIST_GLOBAL_OPTIONS))
      then
        begin
        inParams:=false;
        inOptions:=false;
        inGlobal:=true;
        end
    else if (sLine.Contains(PARAM_LIST_OUTPUT))
      then
        begin
        inParams:=false;
        inOptions:=false;
        inGlobal:=false;
        end;
    end;
  //Now go through each entry in the synopsis list
  //and get the details
  for LineNo:=0 to pred(synopsisList.Count) do
    begin
    sLine:=synopsisList[LineNo];
    paramRequired:=(sLine.IndexOf('[') = -1);
    paramName:=extractName(sLine);
    if (paramName.IndexOf('--') = -1) then continue;

    paramDisplayName:=getDisplayName(paramName);
    paramGlobal:=false;
    sOption:=findOption(optionList,paramName);
    if (sOption = '') then
      begin
      sOption:=findOption(globalOptionList,paramName);
      paramGlobal:=true;
      end;
    if (sOption <> '') then
      begin
      paramType:=getParamType(sOption);
      paramDescription:=getParamDescription(sOption);
      params.push(TParam.create(paramName,paramDisplayName,paramType,paramDescription,paramRequired,paramGlobal));
      end;
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

function TServiceLoader.getDisplayName(paramName_: string): string;
var
  sepWords:TStringArray;
begin
  //remove leading --, replace - with space and capitalise words
  sepWords:=paramName_.Replace('--','').split(['-']).upCaseFirst;
  result:=sepWords.join(' ');
end;

function TServiceLoader.findOption(optionList: TStringlist; paramName: string
  ): string;
var
  lineNo:integer;
  sLine:string;
  inOption:boolean;
begin
  inOption:=false;
  result:='';
  for LineNo:=0 to pred(optionList.Count) do
    begin
    sLine:=optionList[LineNo];
    if (sLine.Contains(paramName)) then inOption:=true;
    if (inOption and (lineNo > 0)
      and (optionList[LineNo-1].Trim = '')
      and sLine.Contains('--'))
      and not sLine.contains(paramName) then exit;
    if inOption then result:=result + sLine+' ';
    end;
  //TOOD trim
end;
//TODO write these
function TServiceLoader.getParamType(option_: string): string;
var
  parts:TStringArray;
begin
  //TODO better to check that previous is ( and next is ) to be certain
  parts:=option_.split(['(',')']);
  if (parts.size > 1) then result:=parts[1] else result:='';
end;

function TServiceLoader.getParamDescription(option_: string): string;
var
  parts:TStringArray;
begin
  parts:=option_.split(['(',')']);
  if (parts.size > 2) then result:=parts[2] else result:='';
end;

//Temp method to return params in a displayable form
function TServiceLoader.getTestParams: TStringlist;
var
  lineNo:integer;
begin
  result:=TStringlist.Create;
  for lineNo:=0 to pred(params.size) do
    begin
    result.Add(params[lineNo].toString);
    end;
end;

end.

