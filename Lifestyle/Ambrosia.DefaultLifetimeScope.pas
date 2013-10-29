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

unit Ambrosia.DefaultLifetimeScope;

interface

uses
  Ambrosia.ScopeCache,
  Ambrosia.Interfaces;

type
  TDefaultLifetimeScope = class (TInterfacedObject, ILifetimeScope)
    private
      FScopeCache : TScopeCache;    //Todo: Make this an interface?
      FOwnsCache  : Boolean;
    protected
      function  GetCachedInstance (Model : TComponentModel;
                                   CreateInstance : TInstanceActivationCallback) : IBurden;
    public
      constructor Create (Cache : TScopeCache = nil);
      destructor Destroy; override;


  end;

implementation


//--------------------------------------------------------------------------------------------------
// TDefaultLifetimeScope
//--------------------------------------------------------------------------------------------------

constructor TDefaultLifetimeScope.Create (Cache : TScopeCache);

begin
FScopeCache := Cache;
if not Assigned (Cache) then
  begin
  FScopeCache := TScopeCache.Create;
  FOwnsCache := True;
  end;
end;

//--------------------------------------------------------------------------------------------------

destructor TDefaultLifetimeScope.Destroy;

begin
if FOwnsCache then
  begin
  IDisposable (FScopeCache).Dispose;
  FScopeCache.Free;
  end;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultLifetimeScope.GetCachedInstance (Model : TComponentModel;
                                                  CreateInstance : TInstanceActivationCallback) : IBurden;

begin
Result := FScopeCache [Model];
if not Assigned (Result) then
  begin
  Result := CreateInstance;
  FScopeCache [Model] := Result;
  end;
end;

end.
