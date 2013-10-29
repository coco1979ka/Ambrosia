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

unit Ambrosia.ReleasePolicy;

interface

uses
  Generics.Collections,
  SysUtils,
  Ambrosia.Interfaces;

type
  TDefaultReleasePolicy = class (TInterfacedObject, IReleasePolicy)
    private
      FLock               : IReadWriteSync;
      FInstanceBurdenMap  : TDictionary<Pointer, IBurden>;
      FParentPolicy       : Pointer;
      function  GetParentPolicy : IReleasePolicy;
    protected
      function CreateSubPolicy: IReleasePolicy;
      function  HasTrack (Instance : Pointer) : Boolean;
      procedure Release (Instance : Pointer);
      procedure Track (Instance : Pointer; Burden: IBurden);
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TDefaultReleasePolicy
//--------------------------------------------------------------------------------------------------

constructor TDefaultReleasePolicy.Create;

begin
FLock := TMREWSync.Create;
FInstanceBurdenMap := TDictionary<Pointer, IBurden>.Create;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultReleasePolicy.CreateSubPolicy: IReleasePolicy;

begin
Result := TDefaultReleasePolicy.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TDefaultReleasePolicy.Destroy;

begin
FInstanceBurdenMap.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultReleasePolicy.GetParentPolicy: IReleasePolicy;

begin
Result := IReleasePolicy (FParentPolicy);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultReleasePolicy.HasTrack (Instance : Pointer) : Boolean;

begin
Result := False;
if not Assigned (Instance) then Exit;
FLock.BeginRead;
try
  Result := FInstanceBurdenMap.ContainsKey (Instance);
finally
  FLock.EndRead;
end;
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultReleasePolicy.Release (Instance : Pointer);

var
  Burden                : IBurden;

begin
FLock.BeginWrite;
try
  if not FInstanceBurdenMap.TryGetValue (Instance, Burden) then
    Exit;
  Burden.Release;
  FInstanceBurdenMap.Remove (Instance);
finally
  FLock.EndWrite;
end;
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultReleasePolicy.Track (Instance : Pointer; Burden : IBurden);


begin
FLock.BeginWrite;
try
  FInstanceBurdenMap.AddOrSetValue (Burden.InstancePtr, Burden);
finally
  FLock.EndWrite;
end;
end;

end.
