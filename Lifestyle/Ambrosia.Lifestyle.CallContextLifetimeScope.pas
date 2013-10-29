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

unit Ambrosia.Lifestyle.CallContextLifetimeScope;

interface

uses
  System.SyncObjs,
  Generics.Collections,
  Ambrosia.ScopeCache,
  Ambrosia.Interfaces;

type
  TCallContextLifetimeScope = class (TInterfacedObject, ILifetimeScope)
    private
      class var LocalInstanceCache : TDictionary<TGUID, ILifetimeScope>; //TODO : should be threadsafe
      class constructor Create;
      class destructor Destroy;
    private
      FCache        : TScopeCache;
      FInstanceId   : TGUID;
      FParentScope  : ILifetimeScope;
      FLock         : TCriticalSection;
    protected
      function  GetCachedInstance (Model : TComponentModel;
                                  CreateInstance : TInstanceActivationCallback) : IBurden;

      procedure SetCurrentScope (Scope : ILifetimeScope);
    public
      constructor Create (Kernel : IKernel);
      destructor Destroy; override;
      class function  ObtainCurrentScope : ILifetimeScope; static;
  end;

var
  GlobalScope           : ILifetimeScope = nil;

implementation

uses
  SysUtils;

//--------------------------------------------------------------------------------------------------
// TCallContextLifetimeScope
//--------------------------------------------------------------------------------------------------

constructor TCallContextLifetimeScope.Create (Kernel : IKernel);

begin
FParentScope := ObtainCurrentScope;
SetCurrentScope (Self);
CreateGUID (FInstanceId);
FLock := TCriticalSection.Create;
FCache := TScopeCache.Create;
end;

//--------------------------------------------------------------------------------------------------

class constructor TCallContextLifetimeScope.Create;

begin
LocalInstanceCache := TDictionary<TGUID, ILifetimeScope>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TCallContextLifetimeScope.Destroy;

begin
FLock.Enter;
try
  if not Assigned (FCache) then Exit;
  IDisposable (FCache).Dispose;
  FCache.Free;
  if Assigned (FParentScope) then
    SetCurrentScope (FParentScope);
finally
  FLock.Leave;
end;
LocalInstanceCache.Remove (FInstanceId);
FLock.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

class destructor TCallContextLifetimeScope.Destroy;

begin
LocalInstanceCache.Free;
end;

//--------------------------------------------------------------------------------------------------

function TCallContextLifetimeScope.GetCachedInstance (Model : TComponentModel;
                                                      CreateInstance : TInstanceActivationCallback) : IBurden;

begin
FLock.Enter;
try
  Result := FCache [Model];
  if not Assigned (Result) then
    begin
    Result := CreateInstance;
    FCache [Model] := Result;
    end;
finally
  FLock.Leave;
end;
end;

//--------------------------------------------------------------------------------------------------

class function TCallContextLifetimeScope.ObtainCurrentScope : ILifetimeScope;

begin
Result := GlobalScope;
end;

//--------------------------------------------------------------------------------------------------

procedure TCallContextLifetimeScope.SetCurrentScope(Scope: ILifetimeScope);

begin
GlobalScope := Scope; //TODO: should this be a global var or better some kind of TApplicationContext
end;



end.
