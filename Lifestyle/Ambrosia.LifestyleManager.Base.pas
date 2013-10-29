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

unit Ambrosia.LifestyleManager.Base;

interface

uses
  Rtti,
  Ambrosia.Interfaces;

type
 TBaseLifestyleManager = class abstract (TInterfacedObject, ILifestyleManager)
    private
      FActivator : IComponentActivator;
      FKernel    : Pointer;
      FModel     : TComponentModel;
      function  GetActivator : IComponentActivator;
      function  GetKernel : IKernel;

    protected
      function  CreateInstance (Context : ICreationContext; TrackedExternally : Boolean) : IBurden;
      procedure Init (Activator : IComponentActivator; Kernel : IKernel;
                      Model : TComponentModel); virtual;
      function  Release (Instance : TValue; ReleaseInterface : Boolean) : Boolean; virtual;
      function  Resolve (Context : ICreationContext; ReleasePolicy : IReleasePolicy) : TValue; virtual;
      procedure Track (Burden : IBurden; Policy : IReleasePolicy);

      {IDisposable}
      procedure Dispose; virtual;
      property Activator : IComponentActivator read GetActivator;
      property Kernel : IKernel read GetKernel;
      property Model : TComponentModel read FModel;
  end;

implementation

uses
  Windows,
  Ambrosia.Burden;

//--------------------------------------------------------------------------------------------------
// TBaseLifestyleManager
//--------------------------------------------------------------------------------------------------

function TBaseLifestyleManager.CreateInstance (Context: ICreationContext;
                                               TrackedExternally: Boolean) :  IBurden;

var
  Instance              : TValue;

begin
//Result := Context.CreateBurden (Activator, TrackedExternally);
Result   := Context.CreateBurden (Activator, TrackedExternally);
Instance := Activator.Create (Context, Result);
//Assert (Instance = Result.Instance);   //TODO Rethink if activator should create an TObject
end;

//--------------------------------------------------------------------------------------------------

procedure TBaseLifestyleManager.Dispose;

begin
OutputDebugString ('Base lifestyle manager dispose');
end;

//--------------------------------------------------------------------------------------------------

function TBaseLifestyleManager.GetActivator: IComponentActivator;

begin
Result := FActivator;
//Result := IComponentActivator (FActivator);
end;

//--------------------------------------------------------------------------------------------------

function TBaseLifestyleManager.GetKernel: IKernel;

begin
Result := IKernel (FKernel);
end;

//--------------------------------------------------------------------------------------------------

procedure TBaseLifestyleManager.Init (Activator : IComponentActivator; Kernel : IKernel;
                                      Model : TComponentModel);

begin
FActivator := Activator;
//FActivator := Pointer (Activator);
FKernel := Pointer (Kernel);
FModel := Model;
end;

//--------------------------------------------------------------------------------------------------

function TBaseLifestyleManager.Release (Instance : TValue; ReleaseInterface : Boolean) : Boolean;

begin
Activator.Destroy (Instance, ReleaseInterface);
Result := True; //TODO : Check if we really need a return value here
end;

//--------------------------------------------------------------------------------------------------

function TBaseLifestyleManager.Resolve (Context : ICreationContext; ReleasePolicy : IReleasePolicy) : TValue;

var
  Burden                : IBurden;

begin
Burden := CreateInstance (Context, False);
Result := Burden.Instance;
Track (Burden, ReleasePolicy)
end;

//--------------------------------------------------------------------------------------------------

procedure TBaseLifestyleManager.Track (Burden: IBurden; Policy: IReleasePolicy);

begin
if Burden.RequiresPolicyRelease then
  Policy.Track (Burden.InstancePtr, Burden);
end;

end.
