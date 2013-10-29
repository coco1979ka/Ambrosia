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

unit Ambrosia.ComponentActivator.Base;

interface

uses
  Rtti,
  Ambrosia.Interfaces;

type
  TComponentActivator = class abstract (TInterfacedObject, IComponentActivator)
    private
      FKernel : Pointer;
      FModel  : TComponentModel;
      function GetKernel : IKernelInternal;
    protected
      function  InternalCreate (Context : ICreationContext) : TObject; virtual; abstract;
      procedure InternalDestroy (Instance : TValue; ReleaseInterface : Boolean); virtual; abstract;
      function  CreateComponent (Context : ICreationContext; Burden : IBurden) : TValue; virtual;
      procedure DestroyComponent (Instance : TValue; ReleaseInterface : Boolean); virtual;
      function  IComponentActivator.Create = CreateComponent;
      procedure IComponentActivator.Destroy = DestroyComponent;
      property Kernel : IKernelInternal read GetKernel;
      property Model : TComponentModel read FModel;
    public
      constructor Create (Model : TComponentModel; Kernel : IKernelInternal);
  end;


implementation

uses
  SysUtils,
  TypInfo;

//--------------------------------------------------------------------------------------------------
// TComponentActivator
//--------------------------------------------------------------------------------------------------

constructor TComponentActivator.Create(Model: TComponentModel; Kernel: IKernelInternal);

begin
FModel := Model;
FKernel := Pointer (Kernel);
end;

//--------------------------------------------------------------------------------------------------

function TComponentActivator.CreateComponent (Context : ICreationContext; Burden : IBurden) : TValue;

var
  LocalInterface  : Pointer;
  Obj             : TObject;

begin
Obj := InternalCreate (Context);
if Context.RequestedType^.Kind = tkInterface
  then
    begin
//    Obj.GetInterface (GetTypeData (Context.RequestedType).Guid, LocalInterface);
    if not Supports (Obj, GetTypeData (Context.RequestedType).Guid, LocalInterface) then
      raise EInvalidCast.Create('Interface not supported');
    TValue.MakeWithoutCopy (@localInterface, Context.RequestedType, Result);
    Burden.SetInstancePtr (LocalInterface);
    end
  else
    begin
    Burden.SetInstancePtr (Pointer (Obj));
    Result := Obj;
    end;
Burden.SetRootInstance (Result);   //TODO Use this result to store pointer if possible
end;

//--------------------------------------------------------------------------------------------------

procedure TComponentActivator.DestroyComponent (Instance : TValue; ReleaseInterface : Boolean);

begin
InternalDestroy (Instance, ReleaseInterface);
end;

//--------------------------------------------------------------------------------------------------

function TComponentActivator.GetKernel: IKernelInternal;

begin
Result := IKernelInternal (FKernel);
end;

end.
