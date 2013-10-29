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

unit Ambrosia.Burden;

interface

uses
  Rtti,
  Ambrosia.Interfaces,
  Generics.Collections;

type
  TBurden = class (TInterfacedObject, IBurden)
    private
      FDependencies      : TList<IBurden>;
      FInstancePtr       : Pointer;
      FInstance          : TValue;
      FHandler           : Pointer;
      FTrackedExternally : Boolean;
      function  GetHandler : IHandler;
    protected
      function  GetInstance : TValue;
      function  GetInstancePtr : Pointer;
      procedure AddChild (Child : IBurden);
      procedure SetRootInstance (Instance : TValue);
      procedure SetInstancePtr (Value : Pointer);
      function  Release (ReleaseInterface : Boolean = True) : Boolean;
      function  RequiresPolicyRelease : Boolean;
      {IDisposable}
      procedure Dispose; virtual;
      property  Handler : IHandler read GetHandler;
    public
      constructor Create (Handler : IHandler; TrackedExternally : Boolean);
      destructor Destroy; override;
  end;

implementation

uses
  Windows,
  TypInfo;

//--------------------------------------------------------------------------------------------------
// TBurden
//--------------------------------------------------------------------------------------------------

procedure TBurden.AddChild (Child : IBurden);

begin
if not Assigned (FDependencies) then
  FDependencies := TList<IBurden>.Create;
FDependencies.Add (Child);
end;

//--------------------------------------------------------------------------------------------------

constructor TBurden.Create (Handler : IHandler; TrackedExternally : Boolean);

begin
FHandler := Pointer (Handler);
FTrackedExternally := TrackedExternally;
end;

//--------------------------------------------------------------------------------------------------

destructor TBurden.Destroy;

begin
//Release;
FDependencies.Free;
inherited;
end;

procedure TBurden.Dispose;

begin
FHandler := nil;
end;

//--------------------------------------------------------------------------------------------------

function TBurden.GetHandler: IHandler;
begin
Result := IHandler (FHandler);
end;

//--------------------------------------------------------------------------------------------------

function TBurden.GetInstance: TValue;

begin
Result := FInstance;
end;

//--------------------------------------------------------------------------------------------------

function TBurden.GetInstancePtr: Pointer;

begin
Result := FInstancePtr;
end;

//--------------------------------------------------------------------------------------------------

function TBurden.RequiresPolicyRelease : Boolean;

begin
Result := not FTrackedExternally {and RequiresDecomission};
end;

//--------------------------------------------------------------------------------------------------

function TBurden.Release (ReleaseInterface : Boolean = True) : Boolean;

var
  Dependency            : IBurden;

begin
if Assigned (FDependencies) then
  for Dependency in FDependencies do
    Dependency.Release (False);   //TODO : check?

if Handler.Release (Self, ReleaseInterface)
  then FInstance := TValue.Empty;


//Writeln (FInstance.ClassName);
//FInstance.Free; //TODO Use Handler -> Creates cyclic dependency!
//TODO : Release correctly
//FInstance := nil;



Result := True;
end;

//--------------------------------------------------------------------------------------------------

procedure TBurden.SetInstancePtr(Value: Pointer);

begin
FInstancePtr := Value;
end;

//--------------------------------------------------------------------------------------------------

procedure TBurden.SetRootInstance (Instance : TValue);

begin
FInstance := Instance;
end;

end.
