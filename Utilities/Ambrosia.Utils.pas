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

unit Ambrosia.Utils;

interface

uses
  Generics.Defaults,
  Generics.Collections,
  TypInfo;

type
  TComponentServiceUtil = class
    private
      class var Comparer : IComparer<PTypeInfo>;
    public
      class constructor Create;
      class procedure AddService (ExistingServices : TList<PTypeInfo>; NewService : PTypeInfo);
  end;

implementation

uses
  Ambrosia.Interfaces,
  Rtti,
  Ambrosia.Types;

type
  TServiceComparer = class (TInterfacedObject, IComparer<PTypeInfo>)
    protected
      function Compare(const Left, Right: PTypeInfo) : Integer;
  end;

//--------------------------------------------------------------------------------------------------
// TComponentServiceUtil
//--------------------------------------------------------------------------------------------------

class procedure TComponentServiceUtil.AddService (ExistingServices : TList<PTypeInfo>; NewService : PTypeInfo);

var
  I                     : Integer;
  Comparison            : Integer;

begin
if ExistingServices.Contains (NewService) then Exit;
if not (NewService^.Kind in [tkClass, tkInterface]) then
  raise ERegistrationException.Create ('Service type must be a class or interface');
for I := 0 to ExistingServices.Count - 1 do
  begin
  if (ExistingServices [I]^.Kind = tkInterface) then
    ExistingServices.Insert (I, NewService);
  Comparison := Comparer.Compare (NewService, ExistingServices[I]);
  if Comparison < 0 then
    begin
    ExistingServices.Insert (I, NewService);
    Exit;
    end;
  if Comparison = 0 then
    Exit;
  end;
ExistingServices.Add (NewService);
end;

//--------------------------------------------------------------------------------------------------

class constructor TComponentServiceUtil.Create;

begin
Comparer := TServiceComparer.Create;
end;

//--------------------------------------------------------------------------------------------------
// TServiceComparer
//--------------------------------------------------------------------------------------------------

function TServiceComparer.Compare(const Left, Right : PTypeInfo) : Integer;

var
  RttiType1,
  RttiType2             : TRttiType;

begin
if Left = Right then Exit (0);
RttiType1 := RttiContext.GetType (Left);
RttiType2 := RttiContext.GetType (Right);
Result := -1;
{TODO : How do we compare types?}
//if (RttiType1 is TRttiInterfaceType) and (RttiType2 is TRttiInstanceType) then
//  begin
//
//  end;

end;

end.
