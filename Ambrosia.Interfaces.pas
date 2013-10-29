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

unit Ambrosia.Interfaces;

interface

uses
  Rtti,
  Generics.Collections,
  Ambrosia.ConstructorCandidate,
  Ambrosia.Interception,
  Ambrosia.DependencyModel,
  Ambrosia.Types,
  TypInfo;

type
  IReleasePolicy = interface;
  IRegistration = interface;
  IHandler = interface;
  IDependencyResolver = interface;
  ISubDependencyResolver = interface;
  IComponentActivator = interface;
  ICreationContext = interface;
  IProxyFactory = interface;

  TComponentModel = class;

  IDisposable = interface
    ['{DB4D9DCC-1490-4EB2-A60C-F9566036831C}']
      procedure Dispose;
  end;

  ITypeConverter = interface
    ['{107AF898-67DE-4BFC-AD59-298FAE640A44}']
  end;

  IBurden = interface (IDisposable)
    ['{882EF6DA-3F9F-460C-BC34-A99ABA9823EE}']
      function  GetInstance : TValue;
      function  GetInstancePtr : Pointer;
      procedure AddChild (Child : IBurden);
      procedure SetInstancePtr (Value : Pointer);
      procedure SetRootInstance (Instance : TValue);
      function  Release (ReleaseInterface : Boolean = True) : Boolean;
      function  RequiresPolicyRelease : Boolean;
      property  Instance    : TValue read GetInstance;
      property  InstancePtr : Pointer read GetInstancePtr;
  end;

  IConfiguration  = interface
    ['{C2481D80-88E4-452A-B605-3F7F898448CF}']
      function  GetArguments : TDictionary<string, TValue>;
      property  Arguments : TDictionary<string, TValue> read GetArguments;
  end;

  IResolutionContext = interface
    ['{5B4DD63B-76FF-4AEA-A2B6-6CD7BF2FAA00}']
      {Property Access}
      function  GetBurden  : IBurden;
      function  GetContext : ICreationContext;
      function  GetHandler : IHandler;
      {Methods}
      procedure AttachBurden (Burden : IBurden);
      function  CreateBurden (TrackExternally : Boolean) : IBurden;
      {Properties}
      property Burden : IBurden read GetBurden;
      property Context : ICreationContext read GetContext;
      property Handler : IHandler read GetHandler;
  end;

  TScopeRootSelector = reference to function (Scopes : TArray<IHandler>) : IHandler;

  ICreationContext = interface
    ['{975D8C31-93DD-4490-962D-EBB207A01016}']
      {Property Access}
      function  GetArguments : TArguments;
      function  GetHandler : IHandler;
      function  GetHandlerStack : TStack<IHandler>;
      function  GetPolicy : IReleasePolicy;
      function  GetRequestedType : PTypeInfo;
      function  GetResolutionStack : TStack<IResolutionContext>;
      {Methods}
      procedure AttachBurden (Burden : IBurden);
      function  CreateBurden (Activator : IComponentActivator; TrackedExternally : Boolean) : IBurden;
      function  EnterResolutionContext (HandlerBeingResolved : IHandler) : IResolutionContext; overload;
      function  EnterResolutionContext (HandlerBeingResolved : IHandler; TrackContext : Boolean) : IResolutionContext; overload;
      function  HasAdditionalArguments : Boolean;
      function  IsInResolutionContext (Handler : IHandler) : Boolean;
      function  IsResolving : Boolean;
      function  SelectScopeRoot (ScopeRootSelector : TScopeRootSelector) : IResolutionContext;
      procedure ExitResolutionContext (BUrden : IBurden; TrackContext : Boolean);
      {Properties}
      property AdditionalArguments  : TArguments read GetArguments;
      property Handler              : IHandler read GetHandler;
      property HandlerStack         : TStack<IHandler> read GetHandlerStack;
      property ReleasePolicy        : IReleasePolicy read GetPolicy;
      property RequestedType        : PTypeInfo read GetRequestedType;
      property ResolutionStack      : TStack<IResolutionContext> read GetResolutionStack;
  end;



  IKernel = interface
    ['{E7B69BBB-ED46-46E7-ACBB-973951942ABF}']
      function  GetHandler (Name : string) : IHandler; overload;
      function  GetHandler (AType : PTypeInfo) : IHandler; overload;
      function  GetProxyFactory : IProxyFactory;
      procedure Register (Registration : IRegistration) ;
      function  Resolve (Service : PTypeInfo; Arguments : TArguments) : TValue; overload;
      function  Resolve (Key : string; Service : PTypeInfo; Arguments : TArguments) : TValue; overload;
      procedure ReleaseComponent (Obj : Pointer);
      property  ProxyFactory : IProxyFactory read GetProxyFactory;
  end;

  IComponentActivator = interface
    ['{257C912E-D767-4C64-867F-1AFB728EB6B1}']
      function  Create (Context : ICreationContext; Burden : IBurden) : TValue;
      procedure Destroy (Instance : TValue; ReleaseInterface : Boolean);
  end;

  ILifestyleManager = interface (IDisposable)
    ['{E8EA3D89-25E4-47E9-95A9-46F0542D6C00}']
      procedure Init (Activator : IComponentActivator; Kernel : IKernel; Model : TComponentModel);
      function  Release (Instance : TValue; ReleaseInterface : Boolean) : Boolean;
      function  Resolve (Context : ICreationContext; ReleasePolicy : IReleasePolicy) : TValue;
  end;

  IHandlerFactory = interface
    ['{51587642-56CA-4924-8D9B-A2BFF12434E7}']
      function Create (Model : TComponentModel) : IHandler;
  end;

  IComponentModelDescriptor = interface
    ['{A0B45AE6-F56E-4D6C-9855-00DE9FA34519}']
      procedure BuildComponentModel (Kernel : IKernel; ComponentModel : TComponentModel);
      procedure ConfigureComponentModel (Kernel : IKernel; ComponentModel : TComponentModel);
  end;

  IContributeComponentModelConstruction = interface
    ['{7016F58F-921B-4205-9E51-C897A993691E}']
      procedure ProcessModel (Kernel : IKernel; Model : TComponentModel);
  end;

  IComponentModelBuilder = interface
    ['{26ECFC69-8CFB-40D6-84B4-9CC985ADAC33}']
      function BuildModel (Descriptors : TArray<IComponentModelDescriptor>) : TComponentModel;
  end;

  IReleasePolicy = interface
    ['{3CDA2AE1-2534-42D5-B377-3FC707C54866}']
      function  CreateSubPolicy : IReleasePolicy;
      function  HasTrack (Instance : Pointer) : Boolean;
      procedure Release (Instance : Pointer);
      procedure Track (Instance : Pointer; Burden : IBurden);
  end;

  IKernelInternal = interface (IKernel)
    ['{7C425D52-82B7-425A-A835-85425CC8147C}']
      function  AddCustomComponent (Model : TComponentModel) : IHandler;
      function  CreateActivator (Model : TComponentModel) : IComponentActivator;
      function  CreateLifestyleManager (Model : TComponentModel; Activator : IComponentActivator) : ILifestyleManager;
      function  LoadHandlerByType (Key : string; Service : PTypeInfo; Arguments : TArguments) : IHandler;
      function  Resolve (Service : PTypeInfo; Arguments : TArguments; ReleasePolicy : IReleasePolicy) : TValue;
      function  ComponentModelBuilder : IComponentModelBuilder;
      function  GetResolver : IDependencyResolver;

      function  GetHandlers (Service : PTypeInfo) : TArray<IHandler>;
      property  Resolver : IDependencyResolver read GetResolver;
  end;

  INamingSubsystem = interface
    ['{3762A71F-DB9B-4E94-BC29-1F7957BA81F0}']
      function  GetHandler (Service : PTypeInfo) : IHandler; overload;
      function  GetHandler (Name : string) : IHandler; overload;
      function  GetHandlers (Service : PTypeInfo) : TArray<IHandler>; overload;
      procedure Register (Handler : IHandler);
  end;



  IRegistration =  interface
    ['{64D48D77-9358-483D-AEDA-D52F8FFD2611}']
      procedure Register (Kernel : IKernelInternal);

  end;

  ISubDependencyResolver = interface
    ['{7DB8E132-40B3-4434-873C-5D83B5D5190C}']
      function CanResolve (Context                : ICreationContext;
                           ContextHandlerResolver : ISubDependencyResolver;
                           Model                  : TComponentModel;
                           Dependency             : TDependencyModel) : Boolean;
      function Resolve    (Context                : ICreationContext;
                           ContextHandlerResolver : ISubDependencyResolver;
                           Model                  : TComponentModel;
                           Dependency             : TDependencyModel) : TValue;
  end;

  IDependencyResolver = interface (ISubDependencyResolver)
    ['{14FAC759-283D-4B43-937B-E72DE2C05B37}']
      procedure Add (Resolver : ISubDependencyResolver);
      procedure Initialize (Kernel : IKernelInternal);
      procedure Remove (Resolver : ISubDependencyResolver);
  end;

  IHandler = interface (ISubDependencyResolver)
    ['{3AB4D8AB-86EA-46CF-8057-AAA85AD6D66D}']
      function  GetComponentModel : TComponentModel;
      procedure Init (Kernel : IKernelInternal);
      function  Resolve (Context : ICreationContext) : TValue;
      function  Release (Burden : IBurden; ReleaseInterface : Boolean) : Boolean;
      function  Supports (Service : PTypeInfo) : Boolean;
      function  IsBeingResolvedInContext (Context : ICreationContext) : Boolean;
      property  ComponentModel : TComponentModel read GetComponentModel;
  end;


  TRegistration<TService> = class;

  ILifestyleGroup<TService> = interface
    function Transient : TRegistration<TService>;
    function Singleton : TRegistration<TService>;
    function Scoped    : TRegistration<TService>;
  end;

  TInstanceActivationCallback = reference to function : IBurden;

  ILifetimeScope = interface
    ['{F8C40CFF-B7E7-494E-B3C1-72420A5E04A0}']
      function GetCachedInstance (Model : TComponentModel;
                                  CreateInstance : TInstanceActivationCallback) : IBurden;
  end;

  IScopeAccessor = interface (IDisposable)
    ['{74FE8E8C-BE1D-4FC3-930F-5126E3F2CB1E}']
      function GetScope (Context : ICreationContext) : ILifetimeScope;
  end;

  IReference<T> = interface
    procedure Attach (Component : TComponentModel);
    procedure Detach (Component : TComponentModel);
    function  Resolve (Kernel : IKernel; Context : ICreationContext) : T;
  end;

  IProxyFactory = interface
    ['{1E2CE033-4CB6-4BC5-B708-63FCC580970F}']
      function  CreateProxy (Kernel : IKernel; Instance : TObject; Model : TComponentModel;
                             Context : ICreationContext; Arguments : TArguments) : TObject;
      function  RequiresTargetInstance (Kernel : IKernel; Model : TComponentModel) : Boolean;
      function  ShouldCreateProxy (Model : TComponentModel) : Boolean;
  end;

  TLifestyleGroup<TService> = class abstract
    protected
      function InitPerThread : TRegistration<TService>; virtual; abstract;
      function InitScoped (ScopeType : PTypeInfo) : TRegistration<TService>; virtual; abstract;
      function InitSingleton : TRegistration<TService>; virtual; abstract;
      function InitTransient : TRegistration<TService>; virtual; abstract;
    public
      function PerThread                  : TRegistration<TService>;
      function Pooled                     : TRegistration<TService>;
      function Scoped                     : TRegistration<TService>; overload;
      function Scoped<T: IScopeAccessor>  : TRegistration<TService>; overload;
      function Singleton                  : TRegistration<TService>;
      function Transient                  : TRegistration<TService>;

  end;

  TRegistration<TService> = class abstract (TInterfacedObject, IRegistration)
    protected
      function  ImplementedBy (Impl : PTypeInfo) : TRegistration<TService>; overload; virtual; abstract;
    public
      procedure Register (Kernel : IKernelInternal); virtual; abstract;
      function  AddDescriptor (Descriptor : IComponentModelDescriptor) : TRegistration<TService>; virtual; abstract;
      function  DependsOn (Configuration : IConfiguration) : TRegistration<TService>; virtual; abstract;
      function  Lifestyle : TLifestyleGroup<TService>; virtual; abstract;
      function  LifestyleTransient : TRegistration<TService>;
      function  LifestylePerThread : TRegistration<TService>;

      function  ImplementedBy<TImplementation> : TRegistration<TService>; overload;
      function  Named (const Name : string) : TRegistration<TService>;  virtual; abstract;
  end;

  TComponentModel = class
    private
      FConstructors       : TObjectList<TConstructorCandidate>;
      FCustomDependencies : TDictionary<string, TValue>;
      FDependencies       : TList<TDependencyModel>;
      FImplType           : TRttiInstanceType;
      FInterceptors       : TList<IReference<IInterceptor>>;
      FName               : string;
      FLifestyle          : TLifestyleType;
      FServices           : TList<PTypeInfo>;
      function  GetServices : TArray<PTypeInfo>;
      function  GetDependencies: TArray<TDependencyModel>;
      function  GetInterceptors : TList<IReference<IInterceptor>>;
    public
      constructor Create;
      destructor Destroy; override;
      procedure AddService (Service : PTypeInfo);
      function  HasInterceptors : Boolean;
      property  Constructors        : TObjectList<TConstructorCandidate> read FConstructors;
      property  CustomDependencies  : TDictionary<string, TValue> read FCustomDependencies;
      property  Dependencies        : TArray<TDependencyModel> read GetDependencies;
      property  ImplType            : TRttiInstanceType read FImplType write FImplType;
      property  Interceptors        : TList<IReference<IInterceptor>> read GetInterceptors;
      property  Lifestyle           : TLifestyleType read FLifestyle write FLifestyle;
      property  Name                : string read FName write FName;
      property  Services            : TArray<PTypeInfo> read GetServices;

  end;
var
  RttiContext : TRttiContext;


implementation

uses
  Generics.Defaults;


//--------------------------------------------------------------------------------------------------
// TRegistration<TService>
//--------------------------------------------------------------------------------------------------

function TRegistration<TService>.ImplementedBy<TImplementation>: TRegistration<TService>;

begin
Result := ImplementedBy (TypeInfo(TImplementation));
end;


//--------------------------------------------------------------------------------------------------
// TLifestyleGroup<TService>
//--------------------------------------------------------------------------------------------------

function TLifestyleGroup<TService>.PerThread : TRegistration<TService>;

begin
Result := InitPerThread;
Free;
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroup<TService>.Pooled : TRegistration<TService>;
begin

end;

function TLifestyleGroup<TService>.Scoped : TRegistration<TService>;

begin
Result := InitScoped (nil);
Free;
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroup<TService>.Scoped<T> : TRegistration<TService>;

begin
Result := InitScoped (TypeInfo(T));
Free;
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroup<TService>.Singleton : TRegistration<TService>;

begin
Result := InitSingleton;
Free;
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroup<TService>.Transient : TRegistration<TService>;

begin
Result := InitTransient;
Free;
end;

function TRegistration<TService>.LifestylePerThread: TRegistration<TService>;

begin
Result := Lifestyle.PerThread;
end;

function TRegistration<TService>.LifestyleTransient: TRegistration<TService>;
begin
Result := Lifestyle.Transient;
end;


type
  TConstructorComparer = class (TInterfacedObject, IComparer<TConstructorCandidate>)
    protected
      function Compare(const Left, Right: TConstructorCandidate) : Integer;
  end;


//--------------------------------------------------------------------------------------------------
// TComponentModel
//--------------------------------------------------------------------------------------------------

procedure TComponentModel.AddService(Service: PTypeInfo);

begin
FServices.Add (Service);
end;

//--------------------------------------------------------------------------------------------------

constructor TComponentModel.Create;

begin
FConstructors := TObjectList<TConstructorCandidate>.Create (TConstructorComparer.Create);
FCustomDependencies := TDictionary<string,TValue>.Create;
FDependencies := TList<TDependencyModel>.Create;
FServices := TList<PTypeInfo>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TComponentModel.Destroy;

begin
FConstructors.Free;
FCustomDependencies.Free;
FDependencies.Free;
FServices.Free;
FInterceptors.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TComponentModel.GetDependencies: TArray<TDependencyModel>;

begin
Result := FDependencies.ToArray;
end;

//--------------------------------------------------------------------------------------------------

function TComponentModel.GetInterceptors : TList<IReference<IInterceptor>>;

begin
if not Assigned (FInterceptors) then
  FInterceptors := TList<IReference<IInterceptor>>.Create;
Result := FInterceptors;
end;

//--------------------------------------------------------------------------------------------------

function TComponentModel.GetServices: TArray<PTypeInfo>;

begin
Result := FServices.ToArray;
end;

//--------------------------------------------------------------------------------------------------

function TComponentModel.HasInterceptors: Boolean;

begin
Result := Assigned (FInterceptors) and (FInterceptors.Count > 0);
end;

//--------------------------------------------------------------------------------------------------
// TConstructorComparer
//--------------------------------------------------------------------------------------------------

function TConstructorComparer.Compare (const Left, Right : TConstructorCandidate) : Integer;

begin
Result := Right.Dependencies.Count - Left.Dependencies.Count;
end;


end.
