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

unit Ambrosia.LifestyleManager.Scoped;

interface

uses
  Rtti,
  SysUtils,
  SyncObjs,
  Ambrosia.Interfaces,
  Ambrosia.LifestyleManager.Base;

type
  TScopedLifestyleManager = class (TBaseLifestyleManager)
    private
      FScopeAccessor : IScopeAccessor;
      function  GetScope (Context : ICreationContext) : ILifetimeScope;
      function  GetScopeAccessor : IScopeAccessor;
    protected
      function  Resolve (Context : ICreationContext; ReleasePolicy : IReleasePolicy) : TValue; override;
      procedure Dispose; override;
      property  ScopeAccessor : IScopeAccessor read GetScopeAccessor;
    public
      constructor Create (ScopeAccessor : IScopeAccessor);
      destructor Destroy; override;

  end;

implementation

uses
  Ambrosia.Types,
  Classes;

//--------------------------------------------------------------------------------------------------
// TScopedLifestyleManager
//--------------------------------------------------------------------------------------------------

constructor TScopedLifestyleManager.Create (ScopeAccessor : IScopeAccessor);

begin
FScopeAccessor := ScopeAccessor;
end;

//--------------------------------------------------------------------------------------------------

destructor TScopedLifestyleManager.Destroy;

begin
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TScopedLifestyleManager.Dispose;

begin
FScopeAccessor.Dispose;
end;

//--------------------------------------------------------------------------------------------------

function TScopedLifestyleManager.GetScope (Context : ICreationContext) : ILifetimeScope;

begin
if not Assigned (ScopeAccessor) then
  raise EInvalidOperation.Create ('Scope has already been destroyed!');
Result := ScopeAccessor.GetScope (Context);
if not Assigned (Result) then
  raise EResolutionException.Create ('Could not obtain scope for ' + Model.Name);
end;

//--------------------------------------------------------------------------------------------------

function TScopedLifestyleManager.GetScopeAccessor: IScopeAccessor;

begin
Result := IScopeAccessor (FScopeAccessor);
end;

//--------------------------------------------------------------------------------------------------

function TScopedLifestyleManager.Resolve (Context : ICreationContext;
                                          ReleasePolicy : IReleasePolicy) : TValue;

var
  Scope                 : ILifetimeScope;
  Burden                : IBurden;

begin
Scope := GetScope (Context);
Burden := Scope.GetCachedInstance (Model,
  function : IBurden
  begin
  Result := CreateInstance (Context, True);
  Track (Result, ReleasePolicy);
  end);
Result := Burden.Instance;
end;

end.
