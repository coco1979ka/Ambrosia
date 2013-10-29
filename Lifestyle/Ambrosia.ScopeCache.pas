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

unit Ambrosia.ScopeCache;

interface

uses
  Generics.Collections,
  Generics.Defaults,
  Ambrosia.Interfaces;

type
  TScopeCache = class (TSingletonImplementation, IDisposable)
    private
      FMap : TDictionary<TComponentModel, IBurden>;
      function  GetItem (Model : TComponentModel) : IBurden;
      procedure SetItem (Model : TComponentModel; const Value : IBurden);
    protected
      procedure Dispose;
    public
      constructor Create;
      destructor Destroy; override;
      property Item [Model : TComponentModel] : IBurden read GetItem write SetItem; default;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TScopeCache
//--------------------------------------------------------------------------------------------------

constructor TScopeCache.Create;

begin
FMap := TDictionary<TComponentModel,IBurden>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TScopeCache.Destroy;



begin
FMap.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TScopeCache.Dispose;

var
  Burden                : IBurden;

begin
for Burden in FMap.Values do
  begin
  Burden.Release;
  Burden.Dispose;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TScopeCache.GetItem (Model : TComponentModel) : IBurden;

begin
FMap.TryGetValue (Model, Result);
end;

//--------------------------------------------------------------------------------------------------

procedure TScopeCache.SetItem (Model : TComponentModel; const Value : IBurden);

begin
FMap.Add (Model, Value);
end;


end.
