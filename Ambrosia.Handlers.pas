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

unit Ambrosia.Handlers;

interface

uses
  Rtti,
  TypInfo,
  Ambrosia.DependencyModel,
  Ambrosia.Burden,
  Ambrosia.Interfaces;

type
  TBaseHandler = class (TInterfacedObject, IHandler, ISubDependencyResolver, IDisposable)
    strict private
      FKernel : Pointer;
      FModel  : TComponentModel;
      procedure AddDependency (Dependency : TDependencyModel);
      function  GetKernel  : IKernelInternal;
      function  HasCustomParameter (Key : string) : Boolean;
    protected
      {Template Methods}
      function  DoRelease (Burden : IBurden; ReleaseInterface : Boolean) : Boolean; virtual; abstract;
      function  DoResolve (Context : ICreationContext; InstanceRequired : Boolean) : TValue; virtual; abstract;
      procedure InitDependencies; virtual;

      {ISubDependencyResolver}
      function  CanResolve (Context: ICreationContext; ContextHandlerResolver: ISubDependencyResolver;
                            Model: TComponentModel; Dependency: TDependencyModel): Boolean;
      function  Resolve (Context: ICreationContext; ContextHandlerResolver: ISubDependencyResolver;
                         Model: TComponentModel; Dependency: TDependencyModel): TValue;
      {IHandler}
      function  IHandlerResolve (Context : ICreationContext) : TValue;
      function  IHandler.Resolve = IHandlerResolve;
      function  Release (Burden : IBurden; ReleaseInterface : Boolean) : Boolean;
      function  GetComponentModel : TComponentModel;
      function  IsBeingResolvedInContext (Context : ICreationContext) : Boolean;
      procedure Init (Kernel : IKernelInternal); virtual;
      function  Supports(Service : PTypeInfo) : Boolean;

      {IDisposable}
      procedure Dispose; virtual; abstract;

      {Field Access}
      property  Kernel  : IKernelInternal read GetKernel;
      property  Model   : TComponentModel read FModel;
    public
      constructor Create (Model : TComponentModel);
      destructor Destroy; override;
  end;

  TDefaultHandler = class (TBaseHandler)
    private
      FLifestyleManager : ILifestyleManager;
    protected
      function  DoResolve (Context : ICreationContext; InstanceRequired : Boolean) : TValue; override;
      function  DoRelease(Burden: IBurden; ReleaseInterface : Boolean): Boolean; override;
      procedure InitDependencies; override;
      function  ResolveCore (Context : ICreationContext; out Burden : IBurden) : TValue;
      procedure Dispose; override;

      property  LifestyleManager : ILifestyleManager read FLifestyleManager;

    public


  end;

implementation

uses
  Ambrosia.ArrayUtils;


//--------------------------------------------------------------------------------------------------
// TBaseHandler
//--------------------------------------------------------------------------------------------------

constructor TBaseHandler.Create (Model : TComponentModel);

begin
FModel := Model;
end;

//--------------------------------------------------------------------------------------------------

destructor TBaseHandler.Destroy;

begin
FModel.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TBaseHandler.AddDependency (Dependency : TDependencyModel);

begin

end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.CanResolve (Context : ICreationContext;
                                  ContextHandlerResolver : ISubDependencyResolver; Model : TComponentModel;
                                  Dependency : TDependencyModel) : Boolean;

begin
Result := False;
if (FModel.CustomDependencies.Count > 0) then
  Result := HasCustomParameter (Dependency.DependencyKey);
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.GetComponentModel: TComponentModel;

begin
Result := FModel;
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.GetKernel: IKernelInternal;

begin
Result := IKernelInternal (FKernel);
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.HasCustomParameter(Key: string): Boolean;

begin
Result := FModel.CustomDependencies.ContainsKey (Key);
end;

//--------------------------------------------------------------------------------------------------

procedure TBaseHandler.Init(Kernel: IKernelInternal);

begin
Assert (Kernel<>nil);
FKernel := Pointer (Kernel);
InitDependencies;
end;

//--------------------------------------------------------------------------------------------------

procedure TBaseHandler.InitDependencies;

var
  Dependency            : TDependencyModel;

begin
for Dependency in Model.Dependencies do
  AddDependency (Dependency);
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.IsBeingResolvedInContext (Context : ICreationContext) : Boolean;

begin
Result := Assigned (Context) and Context.IsInResolutionContext (Self);
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.Release(Burden: IBurden; ReleaseInterface : Boolean): Boolean;

begin
Result := DoRelease (Burden, ReleaseInterface);
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.Resolve (Context : ICreationContext;
                               ContextHandlerResolver : ISubDependencyResolver;
                               Model : TComponentModel;
                               Dependency : TDependencyModel) : TValue;

begin
if HasCustomParameter (Dependency.DependencyKey) then
  Result := FModel.CustomDependencies [Dependency.DependencyKey];
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.Supports (Service : PTypeInfo) : Boolean;

begin
Result := TArrayUtils<PTypeInfo>.Contains (FModel.Services, Service);
end;

//--------------------------------------------------------------------------------------------------

function TBaseHandler.IHandlerResolve(Context: ICreationContext): TValue;

begin
Result := DoResolve (Context, True);
end;


//--------------------------------------------------------------------------------------------------
// TDefaultHandler
//--------------------------------------------------------------------------------------------------

procedure TDefaultHandler.Dispose;

begin
LifestyleManager.Dispose;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultHandler.DoRelease(Burden: IBurden; ReleaseInterface : Boolean): Boolean;

begin
Result := LifestyleManager.Release (Burden.Instance, ReleaseInterface);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultHandler.DoResolve (Context : ICreationContext; InstanceRequired : Boolean) : TValue;

var
  Burden                : IBurden;

begin
Result := ResolveCore (Context, Burden);
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultHandler.InitDependencies;

var
  Activator             : IComponentActivator;

begin
Activator := Kernel.CreateActivator (Model);
FLifestyleManager := Kernel.CreateLifestyleManager (Model, Activator);
//TODO : Init dependencies
end;

//--------------------------------------------------------------------------------------------------

function TDefaultHandler.ResolveCore (Context: ICreationContext; out Burden: IBurden) : TValue;

var
  ResolutionContext     : IResolutionContext;

begin
ResolutionContext := Context.EnterResolutionContext (Self);
try
  Result := LifestyleManager.Resolve (Context, Context.ReleasePolicy);
  Burden := ResolutionContext.Burden;
finally
  Context.ExitResolutionContext (Burden, True);
end;
end;

end.
