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

unit Ambrosia.LifestyleManager.Singleton;

interface

uses
  Rtti,
  SyncObjs,
  Ambrosia.Interfaces,
  Ambrosia.LifestyleManager.Base;

type
  TSingletonLifestyleManager = class (TBaseLifestyleManager)
    private
      FInstance     : TValue;
      FRefCount     : Integer;
      FLock         : TCriticalSection;
      FCachedBurden : IBurden;
    protected
      function Resolve (Context : ICreationContext; ReleasePolicy : IReleasePolicy) : TValue; override;
      function Release (Instance : TValue; ReleaseInterface : Boolean) : Boolean; override;
      procedure Dispose; override;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TSingletonLifestyleManager
//--------------------------------------------------------------------------------------------------

constructor TSingletonLifestyleManager.Create;

begin
FInstance := nil;
FLock := TCriticalSection.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TSingletonLifestyleManager.Destroy;

begin

FLock.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TSingletonLifestyleManager.Dispose;

begin
if Assigned (FCachedBurden) then
  begin
  FCachedBurden.Release (True);
  FCachedBurden.Dispose;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TSingletonLifestyleManager.Release (Instance : TValue; ReleaseInterface : Boolean) : Boolean;

begin
Result := inherited;
//FLock.Enter;
//try
//  Dec (FRefCount);
//  if (FRefCount = 0) then
//    Activator.Destroy (FInstance, ReleaseInterface);
//finally
//  FLock.Leave;
//end;
end;

//--------------------------------------------------------------------------------------------------

function TSingletonLifestyleManager.Resolve (Context : ICreationContext; ReleasePolicy : IReleasePolicy) : TValue;

begin
FLock.Enter;
try
  if Assigned (FCachedBurden) then
    Exit (FCachedBurden.Instance);
  FCachedBurden := CreateInstance (Context, True);
  Track (FCachedBurden, ReleasePolicy);
  Result := FCachedBurden.Instance;
  Inc (FRefCount);
finally
  FLock.Leave;
end;
end;

end.
