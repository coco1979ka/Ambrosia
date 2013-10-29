// --------------------------------------------------------------------------------------------------
// Copyright 2013 AmbrosiaProject
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// --------------------------------------------------------------------------------------------------

unit Ambrosia.CreationContext;

interface

uses
  TypInfo,
  Rtti,
  Generics.Collections,
  Ambrosia.DependencyModel,
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  TCreationContext = class(TInterfacedObject, ICreationContext,
    ISubDependencyResolver)
  private
    FArguments: TArguments;
    FConverter: ITypeConverter;
    FHandler: Pointer;
    FHandlerStack: TStack<IHandler>;
    // FBurden           : IBurden;
    FIsResolving: Boolean;
    FIsRoot: Boolean;
    FPolicy: Pointer;
    FResolutionStack: TStack<IResolutionContext>;
    FRequestedType: PTypeInfo;
    function CanConvertParameter(ParameterType: PTypeInfo): Boolean;
    function CanResolve(Dependency: TDependencyModel;
      InlineArgument: TValue): Boolean;
    function CanResolveByKey(Dependency: TDependencyModel): Boolean;
    function CanResolveByType(Dependency: TDependencyModel): Boolean;
    function Resolve(Dependency: TDependencyModel;
      InlineArgument: TValue): TValue;
    { Property Access }
    function GetArguments: TArguments;
    function GetHandler: IHandler;
    function GetHandlerStack: TStack<IHandler>;
    function GetPolicy: IReleasePolicy;
    function GetRequestedType: PTypeInfo;
    function GetResolutionStack: TStack<IResolutionContext>;
  protected
    { ISubDependencyResolver }
    function SDCanResolve(Context: ICreationContext;
      ContextHandlerResolver: ISubDependencyResolver; Model: TComponentModel;
      Dependency: TDependencyModel): Boolean;

    function SDResolve(Context: ICreationContext;
      ContextHandlerResolver: ISubDependencyResolver; Model: TComponentModel;
      Dependency: TDependencyModel): TValue;

    function ISubDependencyResolver.CanResolve = SDCanResolve;
    function ISubDependencyResolver.Resolve = SDResolve;

    { ICreationContext }
    procedure AttachBurden(Burden: IBurden);
    function CreateBurden(Activator: IComponentActivator;
      TrackedExternally: Boolean): IBurden;
    function EnterResolutionContext(HandlerBeingResolved: IHandler)
      : IResolutionContext; overload;
    function EnterResolutionContext(HandlerBeingResolved: IHandler;
      TrackContext: Boolean): IResolutionContext; overload;
    function HasAdditionalArguments: Boolean;
    function IsInResolutionContext(Handler: IHandler): Boolean;
    function IsResolving: Boolean;
    function SelectScopeRoot(ScopeRootSelector: TScopeRootSelector)
      : IResolutionContext;
    procedure ExitResolutionContext(Burden: IBurden; TrackContext: Boolean);
    constructor InternalCreate;
  public
    constructor Create(Handler: IHandler; Policy: IReleasePolicy;
      RequestedType: PTypeInfo; Arguments: TArguments;
      Converter: ITypeConverter; Parent: ICreationContext); overload;
    constructor Create(RequestedType: PTypeInfo;
      ParentContext: ICreationContext); overload;
    destructor Destroy; override;
    class function CreateEmpty: TCreationContext;
    class function ForDependencyInspection(Handler: IHandler): TCreationContext;

  end;

implementation

uses
  SysUtils,
  Ambrosia.ResolutionContext;

// --------------------------------------------------------------------------------------------------
// TCreationContext
// --------------------------------------------------------------------------------------------------
constructor TCreationContext.Create(Handler: IHandler; Policy: IReleasePolicy;
  RequestedType: PTypeInfo; Arguments: TArguments; Converter: ITypeConverter;
  Parent: ICreationContext);

begin
  Writeln('Creating Creation Context for : ' + RequestedType.Name);
  FHandler := Pointer(Handler);
  FPolicy := Pointer(Policy);
  FRequestedType := RequestedType;
  if Assigned(Arguments) then
    FArguments := TArguments.Create(Arguments)
  else
    FArguments := TArguments.Create;
  FConverter := Converter;
  if Assigned(Parent) then
  begin
    FHandlerStack := Parent.HandlerStack;
    FResolutionStack := Parent.ResolutionStack;
    Exit;
  end;
  FIsRoot := True;
  FHandlerStack := TStack<IHandler>.Create;
  FResolutionStack := TStack<IResolutionContext>.Create;
end;

// --------------------------------------------------------------------------------------------------

constructor TCreationContext.Create(RequestedType: PTypeInfo;
  ParentContext: ICreationContext);

begin
  Assert(Assigned(ParentContext));
  Create(ParentContext.Handler, ParentContext.ReleasePolicy, RequestedType, nil,
    nil, ParentContext);
end;

// --------------------------------------------------------------------------------------------------

constructor TCreationContext.InternalCreate;

begin
  // TODO NoTrackingReleasePolicy
  FIsRoot := True;
  FHandlerStack := TStack<IHandler>.Create;
  FResolutionStack := TStack<IResolutionContext>.Create;
end;

// --------------------------------------------------------------------------------------------------

destructor TCreationContext.Destroy;

begin
  FArguments.Free;
  if FIsRoot then
  begin
    FHandlerStack.Free;
    FResolutionStack.Free;
  end;
  inherited;
end;

// --------------------------------------------------------------------------------------------------

class function TCreationContext.ForDependencyInspection(Handler: IHandler)
  : TCreationContext;

begin
  // Result := nil;
  raise ENotSupportedException.Create('This method is currently not supported');
  // TODO : Implement
end;


// --------------------------------------------------------------------------------------------------

procedure TCreationContext.AttachBurden(Burden: IBurden);

var
  ResolutionContext: IResolutionContext;

begin
  ResolutionContext := FResolutionStack.Peek;
  ResolutionContext.AttachBurden(Burden);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.CanConvertParameter(ParameterType: PTypeInfo)
  : Boolean;

begin
  // TODO : Implement
  raise ENotSupportedException.Create('This method is currently not supported');
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.SDCanResolve(Context: ICreationContext;
  ContextHandlerResolver: ISubDependencyResolver; Model: TComponentModel;
  Dependency: TDependencyModel): Boolean;

begin
  Result := HasAdditionalArguments and
    (CanResolveByKey(Dependency) or CanResolveByType(Dependency));
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.CanResolve(Dependency: TDependencyModel;
  InlineArgument: TValue): Boolean;

var
  DependencyType: PTypeInfo;
  TestValue: TValue;

begin
  DependencyType := Dependency.TargetItemType.Handle;
  if InlineArgument.IsEmpty then
    Exit(False);
  Result := InlineArgument.TryCast(DependencyType, TestValue) or
    CanConvertParameter(DependencyType);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.CanResolveByKey(Dependency: TDependencyModel)
  : Boolean;

begin
  Assert(FArguments <> nil);
  Result := CanResolve(Dependency, FArguments[Dependency.DependencyKey]);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.CanResolveByType(Dependency
  : TDependencyModel): Boolean;

begin
  // TODO search for an argument by its type which is not currently supported
  Result := False;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.CreateBurden(Activator: IComponentActivator;
  TrackedExternally: Boolean): IBurden;

var
  ResolutionContext: IResolutionContext;

begin
  ResolutionContext := FResolutionStack.Peek;
  Result := ResolutionContext.CreateBurden(TrackedExternally);
end;

// --------------------------------------------------------------------------------------------------

class function TCreationContext.CreateEmpty: TCreationContext;

begin
  Result := InternalCreate;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.EnterResolutionContext(HandlerBeingResolved: IHandler;
  TrackContext: Boolean): IResolutionContext;

begin
  Result := TResolutionContext.Create(Self, HandlerBeingResolved, TrackContext);
  FHandlerStack.Push(HandlerBeingResolved);
  if TrackContext then
    FResolutionStack.Push(Result);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.EnterResolutionContext(HandlerBeingResolved: IHandler)
  : IResolutionContext;

begin
  Result := EnterResolutionContext(HandlerBeingResolved, True);
end;

// --------------------------------------------------------------------------------------------------

procedure TCreationContext.ExitResolutionContext(Burden: IBurden;
  TrackContext: Boolean);

var
  Parent: IBurden;

begin
  FHandlerStack.Pop;
  if TrackContext then
    FResolutionStack.Pop;
  if not Assigned(Burden) then
    Exit;
  if Burden.Instance.IsEmpty then
    Exit;
  if not Burden.RequiresPolicyRelease then
    Exit;
  if FResolutionStack.Count > 0 then
  begin
    Parent := FResolutionStack.Peek.Burden;
    Parent.AddChild(Burden);
  end;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.GetArguments: TArguments;

begin
  Result := FArguments;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.GetHandler: IHandler;

begin
  Result := IHandler(FHandler);
end;
// --------------------------------------------------------------------------------------------------

function TCreationContext.GetHandlerStack: TStack<IHandler>;

begin
  Result := FHandlerStack;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.GetPolicy: IReleasePolicy;

begin
  Result := IReleasePolicy(FPolicy);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.GetRequestedType: PTypeInfo;

begin
  Result := FRequestedType;
end;

function TCreationContext.GetResolutionStack: TStack<IResolutionContext>;

begin
  Result := FResolutionStack;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.HasAdditionalArguments: Boolean;

begin
  Result := (FArguments.Count > 0);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.IsInResolutionContext(Handler: IHandler): Boolean;

var
  HandlersInStack: TArray<IHandler>;
  CurrentHandler: IHandler;

begin
  Result := False;
  HandlersInStack := FHandlerStack.ToArray;
  for CurrentHandler in HandlersInStack do
    if (CurrentHandler = Handler) then
      Exit(True);
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.IsResolving: Boolean;

begin
  Result := FIsResolving;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.SDResolve(Context: ICreationContext;
  ContextHandlerResolver: ISubDependencyResolver; Model: TComponentModel;
  Dependency: TDependencyModel): TValue;

begin
  if Dependency.DependencyKey <> '' then
    Result := Resolve(Dependency, FArguments[Dependency.DependencyKey]);
  // if Result.IsEmpty then
  // Result := Resolve (Dependency, FArguments [Dependency.TargetItemType])
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.Resolve(Dependency: TDependencyModel;
  InlineArgument: TValue): TValue;

begin
  if InlineArgument.IsEmpty then
    Exit(TValue.Empty);
  // We should do some type checking here
  Result := InlineArgument;
end;

// --------------------------------------------------------------------------------------------------

function TCreationContext.SelectScopeRoot(ScopeRootSelector: TScopeRootSelector)
  : IResolutionContext;

begin
  // TODO : Implement
end;

end.
