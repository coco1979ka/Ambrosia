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

unit Ambrosia.ThreadScopeAccessor;

interface

uses
  SyncObjs,
  Generics.Collections,
  Ambrosia.Interfaces;

type
  TThreadScopeAccessor = class (TInterfacedObject, IScopeAccessor)
    private
      FMap  : TDictionary<NativeUInt, ILifetimeScope>;
      FLock : TCriticalSection;
    protected
      procedure Dispose;
      function GetScope(Context: ICreationContext) : ILifetimeScope;

    public
      constructor Create;
      destructor Destroy; override;

  end;

implementation

uses
  Ambrosia.DefaultLifetimeScope,
  Windows;

//--------------------------------------------------------------------------------------------------
// TThreadScopeAccessor
//--------------------------------------------------------------------------------------------------

constructor TThreadScopeAccessor.Create;

begin
FLock := TCriticalSection.Create;
FMap := TDictionary<NativeUInt, ILifetimeScope>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TThreadScopeAccessor.Destroy;

begin

FMap.Free;
FLock.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TThreadScopeAccessor.Dispose;

begin
FLock.Enter;
try
  FMap.Clear;
finally
  FLock.Leave;
end;
end;

//--------------------------------------------------------------------------------------------------

function TThreadScopeAccessor.GetScope(Context: ICreationContext): ILifetimeScope;

var
  ThreadId              : Cardinal;
  
begin
ThreadId := GetCurrentThreadId;
FLock.Enter;
try
  if not FMap.TryGetValue (ThreadId, Result) then
    begin
    Result := TDefaultLifetimeScope.Create;
    FMap.Add (ThreadId, Result);
    end;
finally
  FLock.Leave;
end;
end;

end.
