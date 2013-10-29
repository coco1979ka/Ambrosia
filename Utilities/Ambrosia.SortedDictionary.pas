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

unit Ambrosia.SortedDictionary;

interface

uses
  Generics.Defaults,
  Generics.Collections;

type
  TSortedDictionary<TKey,TValue> = class
    private
      FValues   : TList<TValue>;
      FKeys     : TList<TKey>;
      function  GetItem (Key : TKey) : TValue;
      function  GetValues : TArray<TValue>;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add (Key : TKey; Value : TValue);
      property  Values : TArray<TValue> read GetValues;
      property  Items [Key : TKey] : TValue read GetItem; default;
  end;

implementation

uses
  Classes,
  RTLConsts;

//--------------------------------------------------------------------------------------------------
// TSortedDictionary<TKey,TValue>
//--------------------------------------------------------------------------------------------------

constructor TSortedDictionary<TKey, TValue>.Create;

begin
FKeys := TList<TKey>.Create;
FValues := TList<TValue>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TSortedDictionary<TKey, TValue>.Destroy;

begin
FKeys.Free;
FValues.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TSortedDictionary<TKey, TValue>.Add (Key : TKey; Value : TValue);

begin
if FKeys.Contains (Key) then
  raise EListError.CreateRes(@SGenericDuplicateItem);
FKeys.Add (Key);
FValues.Add (Value);
end;

//--------------------------------------------------------------------------------------------------

function TSortedDictionary<TKey, TValue>.GetItem (Key : TKey) : TValue;

var
  Idx                   : Integer;

begin
Idx := FKeys.IndexOf (Key);
if Idx < 0 then
  raise EListError.CreateRes (@SItemNotFound);
Result := FValues [Idx];
end;

//--------------------------------------------------------------------------------------------------

function TSortedDictionary<TKey, TValue>.GetValues: TArray<TValue>;

begin
Result := FValues.ToArray;
end;

end.
