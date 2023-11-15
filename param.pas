unit param;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  
  { TParam }

  TParam = Class(TInterfacedObject)
    private
      fName: string;
      fDisplayName: string;
      fRequired: boolean;
      fGlobal:boolean;
      fType: string;
      fDescription: string;
    public
      constructor create(name_,displayName_,type_,description_:string; required_,global_:boolean);
      function toString:string; override;
      property paramName:string read fName; //array, string, integer,
      property required: boolean read fRequired;
      property global: boolean read fGlobal;
      property paramType:string read fType;
      property paramDescription: string read fDescription;
  end;

implementation

{ TParam }

constructor TParam.create(name_,displayName_,type_,description_:string; required_,global_:boolean);
begin
  fName:=name_;
  fDisplayName:=displayName_;
  fType:=type_;
  fDescription:=description_;
  fRequired:=required_;
  fGlobal:=global_;
end;

function TParam.toString: string;
begin
  if fRequired then
  result:=fName+' ('+ftype+') '+' '+fDisplayName+' '+fDescription else
  result:='['+fName+'] ('+ftype+') '+' '+fDisplayName+' '+fDescription;
  if fGlobal then result:=result+' Global';
end;

end.

