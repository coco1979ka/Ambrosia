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

unit Ambrosia.CombinedDicitonary;

interface

uses
  Rtti,
  TypInfo,
  Generics.Collections;

type
  TCombinedDicitonary = class
    private
      FNameValueMap : TDictionary<string, TValue>;
      FTypeValueMap : TDictionary<PTypeInfo, TValue>;
    public
      constructor Create;
      destructor Destroy; override;
      procedure  AddOrSetValue (Key : string; Value : TValue); overload;
      procedure  AddOrSetValue (Key : PTypeInfo; Value : TValue); overload;
      function   ContainsKey (Key : string) : Boolean; overload;
      function   ContainsKey (Key : PTypeInfo) : Boolean; overload;
      function   TryGetValue (Key : string; out Value : TValue) : Boolean; overload;
      function   TryGetValue (Key : PTypeInfo; out Value : TValue) : Boolean; overload;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TCombinedDicitonary
//--------------------------------------------------------------------------------------------------

constructor TCombinedDicitonary.Create;

begin
FNameValueMap := TDictionary<string, TValue>.Create;
FTypeValueMap := TDictionary<PTypeInfo, TValue>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TCombinedDicitonary.Destroy;

begin
FNameValueMap.Free;
FTypeValueMap.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TCombinedDicitonary.AddOrSetValue (Key : PTypeInfo; Value : TValue);

begin
FTypeValueMap.AddOrSetValue (Key, Value);
end;

//--------------------------------------------------------------------------------------------------

procedure TCombinedDicitonary.AddOrSetValue (Key : string; Value : TValue);

begin
FNameValueMap.AddOrSetValue (Key, Value);
end;

//--------------------------------------------------------------------------------------------------

function TCombinedDicitonary.ContainsKey (Key : string) : Boolean;

begin
Result := FNameValueMap.ContainsKey (Key);
end;

//--------------------------------------------------------------------------------------------------

function TCombinedDicitonary.ContainsKey (Key : PTypeInfo) : Boolean;

begin
Result := FTypeValueMap.ContainsKey (Key);
end;

//--------------------------------------------------------------------------------------------------

function TCombinedDicitonary.TryGetValue (Key : string; out Value : TValue) : Boolean;

begin
Result := FNameValueMap.TryGetValue (Key, Value);
end;

//--------------------------------------------------------------------------------------------------

function TCombinedDicitonary.TryGetValue (Key : PTypeInfo; out Value : TValue) : Boolean;

begin
Result := FTypeValueMap.TryGetValue (Key, Value);
end;



end.
