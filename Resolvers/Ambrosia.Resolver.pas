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

unit Ambrosia.Resolver;

interface

uses
  Rtti,
  TypInfo,
  Generics.Collections,
  Ambrosia.Types,
  Ambrosia.DependencyModel,
  Ambrosia.Interfaces;

type
  TDefaultDependencyResolver = class (TInterfacedObject, IDependencyResolver, ISubDependencyResolver)
    private
      FSubResolvers   : TList<ISubDependencyResolver>;
      FTypeConverter  : ITypeConverter;
      FKernel         : Pointer;
      function  GetKernel : IKernelInternal;
      function  CanResolveFromContext (Context                : ICreationContext;
                                       ContextHandlerResolver : ISubDependencyResolver;
                                       Model                  : TComponentModel;
                                       Dependency             : TDependencyModel) : Boolean;
      function  CanResolveFromHandler (Context                : ICreationContext;
                                       ContextHandlerResolver : ISubDependencyResolver;
                                       Model                  : TComponentModel;
                                       Dependency             : TDependencyModel) : Boolean;
      function  CanResolveFromContextHandlerResolver (Context                : ICreationContext;
                                                      ContextHandlerResolver : ISubDependencyResolver;
                                                      Model                  : TComponentModel;
                                                      Dependency             : TDependencyModel) : Boolean;
      function  CanResolveFromSubResolvers (Context                : ICreationContext;
                                            ContextHandlerResolver : ISubDependencyResolver;
                                            Model                  : TComponentModel;
                                            Dependency             : TDependencyModel) : Boolean;
      function  CanResolveFromKernel (Context                : ICreationContext;
                                      Model                  : TComponentModel;
                                      Dependency             : TDependencyModel) : Boolean;
    protected
      function  RebuildContextForParameter (Context : ICreationContext;
                                            RequestedType : PTypeInfo) : ICreationContext;
      function  ResolveCore  (Context                : ICreationContext;
                              ContextHandlerResolver : ISubDependencyResolver;
                              Model                  : TComponentModel;
                              Dependency             : TDependencyModel) : TValue;
      function  ResolveFromKernel (Context : ICreationContext; Model : TComponentModel;
                                   Dependency : TDependencyModel) : TValue;
      function  ResolveFromKernelByName (Context : ICreationContext; Model : TComponentModel;
                                         Dependency : TDependencyModel) : TValue;
      function  ResolveFromKernelByType (Context : ICreationContext; Model : TComponentModel;
                                         Dependency : TDependencyModel) : TValue;
      function  TryGetHandlerFromKernel (Dependency : TDependencyModel; Context : ICreationContext;
                                         out Handler : IHandler) : Boolean;
      {ISubDependencyResolver}
      procedure Add (Resolver : ISubDependencyResolver);
      procedure Initialize (Kernel : IKernelInternal);
      procedure Remove (Resolver : ISubDependencyResolver);
      {IDependencyResolver}
      function  CanResolve (Context : ICreationContext;
                              ContextHandlerResolver : ISubDependencyResolver;
                              Model : TComponentModel; Dependency :
                              TDependencyModel) : Boolean;
      function  Resolve (Context : ICreationContext; ContextHandlerResolver :
                          ISubDependencyResolver;
                          Model : TComponentModel; Dependency :
                          TDependencyModel) : TValue;
      property  Kernel : IKernelInternal read GetKernel;
    public
      constructor Create;
      destructor Destroy; override;
  end;


implementation

uses
  Ambrosia.CreationContext;

//--------------------------------------------------------------------------------------------------
// TDefaultDependencyResolver
//--------------------------------------------------------------------------------------------------

constructor TDefaultDependencyResolver.Create;

begin
FSubResolvers := TList<ISubDependencyResolver>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TDefaultDependencyResolver.Destroy;

begin
FSubResolvers.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultDependencyResolver.Add (Resolver : ISubDependencyResolver);

begin
Assert (Resolver<>nil);
FSubResolvers.Add (Resolver);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.CanResolve (Context : ICreationContext;
                                                ContextHandlerResolver : ISubDependencyResolver;
                                                Model : TComponentModel;
                                                Dependency : TDependencyModel) : Boolean;

begin
if CanResolveFromContext (Context, ContextHandlerResolver, Model, Dependency) then
  Exit (True)
else if CanResolveFromHandler (Context, ContextHandlerResolver, Model, Dependency) then
  Exit (True)
else if CanResolveFromContextHandlerResolver (Context, ContextHandlerResolver, Model, Dependency) then
  Exit (True)
else if CanResolveFromSubResolvers (Context, ContextHandlerResolver, Model, Dependency) then
  Exit (True)
else
  Result := CanResolveFromKernel (Context, Model, Dependency);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.CanResolveFromContext (Context : ICreationContext;
                                                           ContextHandlerResolver : ISubDependencyResolver;
                                                           Model : TComponentModel;
                                                           Dependency : TDependencyModel) : Boolean;

begin
Result := False;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.CanResolveFromContextHandlerResolver (Context : ICreationContext;
                                                                          ContextHandlerResolver : ISubDependencyResolver;
                                                                          Model : TComponentModel;
                                                                          Dependency : TDependencyModel) : Boolean;

begin
Result := False;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.CanResolveFromHandler (Context : ICreationContext;
                                                           ContextHandlerResolver : ISubDependencyResolver;
                                                           Model : TComponentModel;
                                                           Dependency : TDependencyModel): Boolean;

var
  Handler               : IHandler;
begin
Handler := Kernel.GetHandler (Model.Name);
Result := (Handler <> nil) and Handler.CanResolve(Context, ContextHandlerResolver, Model, Dependency);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.CanResolveFromKernel (Context : ICreationContext;
                                                          Model : TComponentModel;
                                                          Dependency : TDependencyModel) : Boolean;

begin
Result := False;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.CanResolveFromSubResolvers (Context : ICreationContext;
                                                                ContextHandlerResolver : ISubDependencyResolver;
                                                                Model : TComponentModel;
                                                                Dependency : TDependencyModel) : Boolean;

begin
Result := False;
end;


//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.GetKernel : IKernelInternal;

begin
Result := IKernelInternal (FKernel);
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultDependencyResolver.Initialize (Kernel : IKernelInternal);

begin
FKernel := Pointer (Kernel);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.RebuildContextForParameter (Context: ICreationContext;
                                                                RequestedType: PTypeInfo): ICreationContext;

begin
Result := TCreationContext.Create (RequestedType, Context);
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultDependencyResolver.Remove (Resolver : ISubDependencyResolver);

begin
FSubResolvers.Remove (Resolver);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.Resolve (Context : ICreationContext;
                                             ContextHandlerResolver : ISubDependencyResolver;
                                             Model : TComponentModel;
                                             Dependency : TDependencyModel) : TValue;

begin
Result := ResolveCore (Context, ContextHandlerResolver, Model, Dependency);
if Result.IsEmpty then
  raise EDependencyResolverException.Create ('Could not resolve dependency ' + Dependency.DependencyKey);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.ResolveCore (Context : ICreationContext;
                                                 ContextHandlerResolver : ISubDependencyResolver;
                                                 Model : TComponentModel;
                                                 Dependency : TDependencyModel) : TValue;
var
  Handler               : IHandler;
  SubResolver           : ISubDependencyResolver;

begin
//if CanResolveFromContext (Context, ContextHandlerResolver, Model, Dependency) then
  //Result := Context.Resolve (Context, ContextHandlerResolver, Model, Dependency)
Handler := Kernel.GetHandler (Model.Name);
if {(Handler <> ContextHandlerResolver) and} CanResolveFromHandler (Context, ContextHandlerResolver, Model, Dependency)  then
  begin
  Result := ISubDependencyResolver (Handler).Resolve (Context, ContextHandlerResolver, Model, Dependency);
  Exit;
  end;
if CanResolveFromContextHandlerResolver (Context, ContextHandlerResolver, Model, Dependency) then
  begin
  Result := ContextHandlerResolver.Resolve (Context, ContextHandlerResolver, Model, Dependency);
  Exit;
  end;
if (FSubResolvers.Count > 0) then
  begin
  for SubResolver in FSubResolvers do
    begin
    if SubResolver.CanResolve (Context, ContextHandlerResolver, Model, Dependency) then
      Exit (SubResolver.Resolve (Context, ContextHandlerResolver, Model, Dependency));
    end;
  end;
Result := ResolveFromKernel (Context, Model, Dependency);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.ResolveFromKernel (Context : ICreationContext;
                                                       Model : TComponentModel;
                                                       Dependency : TDependencyModel): TValue;

begin
//TODO : first by name, by parameter then...
Result := ResolveFromKernelByType (Context, Model, Dependency);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.ResolveFromKernelByName (Context    : ICreationContext;
                                                             Model      : TComponentModel;
                                                             Dependency : TDependencyModel) : TValue;

begin

end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.ResolveFromKernelByType (Context : ICreationContext;
                                                             Model : TComponentModel;
                                                             Dependency : TDependencyModel) : TValue;

var
  Handler               : IHandler;

begin
if not TryGetHandlerFromKernel (Dependency, Context, Handler) then
  raise EDependencyResolverException.Create ('Cannot resolve dependency for type ' + Dependency.TargetItemType.Name);

Context := RebuildContextForParameter (Context, Dependency.TargetItemType.Handle);
Exit (Handler.Resolve (context));
end;

//--------------------------------------------------------------------------------------------------

function TDefaultDependencyResolver.TryGetHandlerFromKernel (Dependency : TDependencyModel;
                                                             Context : ICreationContext;
                                                             out Handler : IHandler): Boolean;

var
  PossibleHandler       : IHandler;
  Handlers              : TArray<IHandler>;

begin
Result := False;
Handler := Kernel.LoadHandlerByType (Dependency.DependencyKey, Dependency.TargetItemType.Handle,
                                     Context.AdditionalArguments);
if not Handler.IsBeingResolvedInContext (Context) then
  Exit (True);
Handlers := Kernel.GetHandlers (Dependency.TargetItemType.Handle);
for PossibleHandler in Handlers do
  if not PossibleHandler.IsBeingResolvedInContext (Context) then
    begin
    Handler := PossibleHandler;
    Exit (True);
    end;
end;

end.
