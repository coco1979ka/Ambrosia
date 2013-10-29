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

unit Ambrosia.Kernel.Default;

interface

uses
  Rtti,
  //Generics.Collections,
  TypInfo,
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  TKernel = class (TInterfacedObject, IKernel, IKernelInternal)
    private
      FComponentModelBuilder  : IComponentModelBuilder;
      FCurrentCreationContext : ICreationContext;
      FHandlerFactory         : IHandlerFactory;
      FNamingSubsystem        : INamingSubsystem;
      FProxyFactory           : IProxyFactory;
      FReleasePolicy          : IReleasePolicy;
      FResolver               : IDependencyResolver;

      function  ResolveComponent (Handler : IHandler; Service : PTypeInfo; Arguments : TArguments;
                                  Policy : IReleasePolicy) : TValue;
      function  CreateHandler (Model : TComponentModel) : IHandler;
      function  CreateCreationContext (Handler: IHandler; Service: PTypeInfo; Arguments: TArguments;
                                        Policy: IReleasePolicy) : ICreationContext;
      function  CreateScopeAccessor (Model : TComponentModel) : IScopeAccessor;
    protected
      function  AddCustomComponent (Model : TComponentModel) : IHandler;
      function  ComponentModelBuilder : IComponentModelBuilder;
      function  CreateActivator (Model : TComponentModel) : IComponentActivator;
      function  CreateLifestyleManager (Model : TComponentModel; Activator : IComponentActivator) : ILifestyleManager;
      function  GetHandler (Service : PTypeInfo) : IHandler; overload;
      function  GetHandler (Name : string) : IHandler; overload;
      function  GetHandlers (Service : PTypeInfo) : TArray<IHandler>;
      function  GetProxyFactory : IProxyFactory;
      procedure Register (Registration : IRegistration);
      function  Resolve (Service : PTypeInfo; Arguments : TArguments) : TValue; overload;
      function  Resolve (Key : string; Service : PTypeInfo; Arguments : TArguments) : TValue; overload;
      function  LoadHandlerByType (Key : string; Service : PTypeInfo; Arguments : TArguments) : IHandler;
      function  Resolve (Service : PTypeInfo; Arguments : TArguments; ReleasePolicy : IReleasePolicy) : TValue; overload;
      function  GetResolver : IDependencyResolver;
      procedure ReleaseComponent (Instance : Pointer);
      property  ReleasePolicy : IReleasePolicy read FReleasePolicy;
      property  HandlerFactory : IHandlerFactory read FHandlerFactory;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  Ambrosia.CreationContext,
  Ambrosia.Resolver,
  Ambrosia.ReleasePolicy,
  Ambrosia.ComponentActivator.Default,
  Ambrosia.HandlerFactory,
  Ambrosia.ComponentModelBuilder,
  Ambrosia.NamingSubsystem,
  Ambrosia.LifestyleManager.Scoped,
  Ambrosia.LifestyleManager.Transient,
  Ambrosia.LifestyleManager.Singleton,
  Ambrosia.ThreadScopeAccessor,
  Ambrosia.DefaultProxyFactory,
  Ambrosia.LifetimeScopeAccessor;

//--------------------------------------------------------------------------------------------------
// TKernel
//--------------------------------------------------------------------------------------------------


constructor TKernel.Create;

begin
FComponentModelBuilder := TComponentModelBuilder.Create (Self);
FNamingSubsystem := TNamingSubsystem.Create;
FReleasePolicy := TDefaultReleasePolicy.Create;
FHandlerFactory := TDefaultHandlerFactory.Create (Self);
FResolver := TDefaultDependencyResolver.Create;
FProxyFactory := TDefaultProxyFactory.Create;
FResolver.Initialize (Self);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.CreateActivator (Model : TComponentModel) : IComponentActivator;

begin
Result := TDefaultComponentActivator.Create (Model, Self);
end;

//--------------------------------------------------------------------------------------------------
function TKernel.CreateCreationContext (Handler : IHandler; Service : PTypeInfo;
                                        Arguments : TArguments;
                                        Policy : IReleasePolicy) : ICreationContext;

begin
Result := TCreationContext.Create (Handler, Policy, Service, Arguments, nil, nil);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.CreateHandler (Model : TComponentModel) : IHandler;

begin
Assert (Model<>nil);
Result := HandlerFactory.Create (Model);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.Resolve (Service : PTypeInfo; Arguments : TArguments) : TValue;

begin
Result := Resolve (Service, Arguments, ReleasePolicy);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.AddCustomComponent (Model : TComponentModel) : IHandler;

begin
Result := CreateHandler (Model);
FNamingSubsystem.Register (Result);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.ComponentModelBuilder : IComponentModelBuilder;

begin
Result := FComponentModelBuilder;
end;

//--------------------------------------------------------------------------------------------------

function TKernel.CreateLifestyleManager (Model : TComponentModel; Activator : IComponentActivator) : ILifestyleManager;

begin
case Model.Lifestyle of
  TLifestyleType.Transient  : Result := TTransientLifestyleManager.Create;
  TLifestyleType.Singleton  : Result := TSingletonLifestyleManager.Create;
  TLifestyleType.Scoped     : Result := TScopedLifestyleManager.Create (CreateScopeAccessor (Model));
  TLifestyleType.PerThread  : Result := TScopedLifestyleManager.Create (TThreadScopeAccessor.Create);
  TLifestyleType.Pooled     : ;
  TLifestyleType.Custom     : ;
end;
Result.Init (Activator, Self, Model);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.CreateScopeAccessor(Model: TComponentModel): IScopeAccessor;

begin
//TODO : Get Accessortype from Model
Result := TLifetimeScopeAccessor.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TKernel.Destroy;

begin
//FCurrentCreationContext.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TKernel.GetHandler (Name : string): IHandler;

begin
Assert (Name<>'');
Result := FNamingSubsystem.GetHandler (Name);
//Todo : Search parent handler
end;

//--------------------------------------------------------------------------------------------------

function TKernel.GetHandlers (Service : PTypeInfo) : TArray<IHandler>;

begin
Result := FNamingSubsystem.GetHandlers (Service);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.GetProxyFactory: IProxyFactory;

begin
Result := FProxyFactory;
end;

//--------------------------------------------------------------------------------------------------

function TKernel.GetHandler (Service : PTypeInfo) : IHandler;

begin
Assert (Service <> nil);
Result := FNamingSubsystem.GetHandler (Service);
//TODO : Composite handling
//if (not Assigned (Result) and Assigned (FParent)) then
//  Result := WrapParentHandler (Parent.GetHandler (Service));
end;

//--------------------------------------------------------------------------------------------------

function TKernel.LoadHandlerByType (Key : string; Service : PTypeInfo; Arguments : TArguments) : IHandler;

begin
Assert (Service <> nil);
Result := GetHandler (Service);
//TODO : Lazy loading
end;

//--------------------------------------------------------------------------------------------------

procedure TKernel.Register(Registration: IRegistration);

begin
Registration.Register (Self);
end;

//--------------------------------------------------------------------------------------------------

procedure TKernel.ReleaseComponent (Instance: Pointer);

begin
if ReleasePolicy.HasTrack (Instance) then
  ReleasePolicy.Release (Instance);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.Resolve (Key : string; Service : PTypeInfo; Arguments : TArguments) : TValue;

begin

end;

//--------------------------------------------------------------------------------------------------

function TKernel.Resolve (Service : PTypeInfo; Arguments : TArguments; ReleasePolicy : IReleasePolicy) : TValue;

var
  Handler : IHandler;

begin
Handler := LoadHandlerByType ('', Service, Arguments);
Result  := ResolveComponent (Handler, Service, Arguments, FReleasePolicy);
end;

//--------------------------------------------------------------------------------------------------

function TKernel.ResolveComponent (Handler: IHandler; Service: PTypeInfo; Arguments: TArguments;
                                   Policy: IReleasePolicy): TValue;

var
  SavedContext          : ICreationContext;

begin
SavedContext := FCurrentCreationContext;
FCurrentCreationContext := CreateCreationContext (Handler, Service, Arguments, Policy);
try
  Result := Handler.Resolve (FCurrentCreationContext);
finally
  //FCurrentCreationContext.Free;
  FCurrentCreationContext := SavedContext;
end;
end;

//--------------------------------------------------------------------------------------------------

function TKernel.GetResolver: IDependencyResolver;

begin
Result := FResolver;
end;

end.
