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
      fRequired: boolean;
      fType: string;
      fDescription: string;
    public
      constructor create(name_:string; required_:boolean);
      function toString:string;
      property paramName:string read fName; //array, string, integer,
      property required: boolean read fRequired;
      property paramType:string read fType;
      property paramDescription: string read fDescription;
  end;

implementation

{ TParam }

constructor TParam.create(name_: string; required_: boolean
  );
begin
  fName:=name_;
  fRequired:=required_;
end;

function TParam.toString: string;
begin
  if fRequired then
  result:=fName+' ('+ftype+') '+fDescription else
  result:='['+fName+'] ('+ftype+') '+fDescription;
end;

end.

