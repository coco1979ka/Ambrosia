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

unit Ambrosia.Enumerable;

interface

uses
  Generics.Collections;

type
  {$REGION ' Documentation '} {
    Generic interface for list enumerators.
  } {$ENDREGION}
  IEnumerator<T> = interface
  ['{82F1D04D-D060-45DE-A5E2-13C3538F4087}']
    {$REGION ' Documentation '} {
      Return the current item.
    } {$ENDREGION}
    function GetCurrent : T;
    {$REGION ' Documentation '} {
      Move to the next item.
    } {$ENDREGION}
    function MoveNext : Boolean;
    {$REGION ' Documentation '} {
      see @link(GetCurrent)
    } {$ENDREGION}
    property Current : T read GetCurrent;
  end;

  {$REGION ' Documentation '} {
    Generic interface for list enumerables. This interface must be implemented by the object that
    should be used in the for..in construct. An enumerable just returns an enumerator when being asked
    for it.
  } {$ENDREGION}
  IEnumerable<T> = interface
  ['{FE63D54C-395B-47C4-89FF-B5319B530D0D}']
    {$REGION ' Documentation '} {
      Return an enumerator for the implementing object.
    } {$ENDREGION}
    function GetEnumerator : IEnumerator<T>;
  end;

  {$REGION ' Documentation '} {
    IListEnumerator implementation for @bold(TList).
  } {$ENDREGION}
  TListEnumerator<T> = class (TInterfacedObject, IEnumerator<T>)
  strict private
    FList               : TList<T>;
    FIndex              : Integer;
  public
    constructor Create (List : TList<T>);
    function    GetCurrent : T;
    function    MoveNext : Boolean;
  end;

  {$REGION ' Documentation '} {
    IListEnumerable implementation for @bold (TList).
  } {$ENDREGION}
  TListEnumerable <T> = class (TInterfacedObject, IEnumerable <T>)
  strict private
    FList               : TList<T>;
  public
    constructor Create (List : TList<T>);
    function    GetEnumerator : IEnumerator<T>;
  end;

implementation

//--------------------------------------------------------------------------------------------------

constructor TListEnumerator<T>.Create (List : TList<T>);

begin
FList := List;
FIndex := -1;
end;

//--------------------------------------------------------------------------------------------------

function TListEnumerator<T>.GetCurrent : T;

begin
Result := FList [FIndex];
end;

//--------------------------------------------------------------------------------------------------

function TListEnumerator<T>.MoveNext : Boolean;

begin
Result := FIndex < (FList.Count - 1);
if Result then
  Inc (FIndex);
end;

//--------------------------------------------------------------------------------------------------

constructor TListEnumerable<T>.Create (List : TList<T>);

begin
FList := List;
end;

//--------------------------------------------------------------------------------------------------

function TListEnumerable<T>.GetEnumerator : IEnumerator<T>;

begin
Result := TListEnumerator <T>.Create (FList);
end;


end.
