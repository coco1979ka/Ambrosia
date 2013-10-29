//--------------------------------------------------------------------------------------------------
// Copyright 2013 AmbrosiaProject
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//--------------------------------------------------------------------------------------------------

unit Ambrosia.Reflection;

interface

uses
  SysUtils,
  TypInfo,
  Rtti;

type
  EInvalidModuleName = class (Exception);

  TConstructorCondition = reference to function (RttiMethod : TRttiMethod) : Boolean;

  TRttiTypeHelper = class helper for TRttiType
    public
      function CanBeAssignedFrom (RttiType : TRttiType) : Boolean;
      function GetConstructors (Condition : TConstructorCondition) : TArray<TRttiMethod>;
      function Attributes<T: TCustomAttribute> : TArray<T>;
  end;

  TModule = class
    class function GetCallingModule : TRttiPackage;
    class function GetModuleNamed (Name : string) : TRttiPackage;
  end;

  TComponentName = record
    private
      FFullName   : string;
      FSetByUser  : Boolean;

    public
      class function Create (Name : string; SetByUser : Boolean) : TComponentName; static;
      class function DefaultFor (AType : PTypeInfo) : TComponentName; static;
      class operator Implicit (A : TComponentName) : string;
  end;



var
  GlobalCtx : TRttiContext;

implementation

uses
  Generics.Collections;

//--------------------------------------------------------------------------------------------------
// TModule
//--------------------------------------------------------------------------------------------------

class function TModule.GetCallingModule : TRttiPackage;

var
  Packages              : TArray<TRttiPackage>;

begin
Packages := GlobalCtx.GetPackages;
Assert (Length (Packages) > 0);
Result := Packages [0];
end;

//--------------------------------------------------------------------------------------------------

class function TModule.GetModuleNamed (Name : string) : TRttiPackage;

var
  Package               : TRttiPackage;

begin
for Package in GlobalCtx.GetPackages do
  if (CompareText (ExtractFileName (Name), ExtractFileName (Package.Name)) = 0) then
    Exit (Package);
raise EInvalidModuleName.Create('Model with name ' + Name + ' could not be found!');
end;


//--------------------------------------------------------------------------------------------------
// TRttiTypeHelper
//--------------------------------------------------------------------------------------------------

function TRttiTypeHelper.CanBeAssignedFrom (RttiType : TRttiType) : Boolean;

var
  BaseType,
  InstType              : TRttiInstanceType;
  IntfType              : TRttiInterfaceType;


begin
Result := False;
if (Self is TRttiInterfaceType) then
  begin
  if (RttiType is TRttiInstanceType) then
    begin
    InstType := TRttiInstanceType (RttiType);
    for IntfType in InstType.GetImplementedInterfaces do
      if IntfType = Self then
        Exit (True);
    end;
  end
else if (Self is TRttiInstanceType) then
  begin
  if (RttiType is TRttiInstanceType) then
    begin
    BaseType := TRttiInstanceType (RttiType).BaseType;
    repeat
      if (BaseType = Self) then Exit (True);
      BaseType := BaseType.BaseType;
    until (BaseType = nil);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TRttiTypeHelper.Attributes<T>: TArray<T>;

var
  Attributes            : TList<T>;
  Attribute             : TCustomAttribute;

begin
Attributes := TList<T>.Create;
try
  for Attribute in Self.GetAttributes do
    if Attribute is T then
      Attributes.Add (T (Attribute));
  Result := Attributes.ToArray;
finally
  Attributes.Free;
end;
end;

//--------------------------------------------------------------------------------------------------

function TRttiTypeHelper.GetConstructors (Condition : TConstructorCondition) : TArray<TRttiMethod>;

var
  HasConstructor        : Boolean;
  RttiInstanceType      : TRttiInstanceType;
  RttiMethod            : TRttiMethod;
  List                  : TList<TRttiMethod>;


begin
if not Self.IsInstance then Exit;
List := TList<TRttiMethod>.Create;
try
  RttiInstanceType := Self.AsInstance;
  HasConstructor := False;
  for RttiMethod in RttiInstanceType.GetDeclaredMethods do
    if RttiMethod.IsConstructor then
      begin
      if not Assigned (Condition) or Condition (RttiMethod) then
        begin
        HasConstructor := True;
        List.Add (RttiMethod);
        end;
      end;
  if not HasConstructor then
    if (RttiInstanceType.BaseType <> nil) then
      List.AddRange (RttiInstanceType.BaseType.GetConstructors (Condition));
  Result := List.ToArray;
finally
  List.Free;
end;
end;

//--------------------------------------------------------------------------------------------------
// TComponentName
//--------------------------------------------------------------------------------------------------

class function TComponentName.Create(Name: string; SetByUser: Boolean): TComponentName;

begin
Result.FFullName := Name;
Result.FSetByUser := SetByUser;
end;

//--------------------------------------------------------------------------------------------------

class function TComponentName.DefaultFor (AType : PTypeInfo) : TComponentName;

var
  T                     : TRttiInstanceType;

begin
T := GlobalCtx.GetType(AType).AsInstance;
Result.FFullName := T.DeclaringUnitName + '.' + T.Name;
Result.FSetByUser := False;
end;

//--------------------------------------------------------------------------------------------------

class operator TComponentName.Implicit(A: TComponentName): string;

begin
Result := A.FFullName;
end;

end.
