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

unit Ambrosia.Container;

interface

uses
  Generics.Collections,
  TypInfo,
  Ambrosia.CreationContext,
  Ambrosia.Configuration,
  Ambrosia.Interfaces,
  Ambrosia.GenericForwarders,
  Ambrosia.Enumerable,
  Ambrosia.Types,
  Rtti,
  SysUtils;

type
  TContainer = class;

  IDependencyInstaller = interface
    ['{24FCBE36-876F-4516-8FF2-1A2A4C0EC134}']
      procedure Install (Container : TContainer);
  end;

  Component = record
    class function ForType<TService> : Registration<TService>; static;
  end;

  AllTypes = record
    class function FromApplication : TFromModuleDescriptor; static;
    class function FromPackageNamed (Name : string) : TFromModuleDescriptor; static;
  end;

  Configuration = record
    class function  Add (Name : string; Value : TValue) : TConfiguration; overload; static;
    class function  Add<T> (Name : string; Value : T) : TConfiguration; overload; static;
  end;

  TContainer = class
    private
      FKernel     : IKernel;
      FScope      : ILifetimeScope;
      FScopeStack : TStack<ILifetimeScope>;
      function  GetScope : ILifetimeScope;
      procedure SetScope (Value : ILifetimeScope);
    protected
      property Kernel : IKernel read FKernel;
      property Scope : ILifetimeScope read GetScope write SetScope;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Install (Installer : IDependencyInstaller); overload;
      procedure Install (Installers : TArray<IDependencyInstaller>); overload;
      procedure Register (Registration : IRegistration); overload;
      procedure Register (Registrations : IEnumerable<IRegistration>); overload;
      function  Resolve<T> : T; overload;
      function  Resolve<T> (Name : string) : T; overload;
      function  Resolve<T> (Context : TCreationContext) : T; overload;
      function  ResolveAll<T> : IEnumerable<T>;
      procedure Release (var Obj);
    end;

var
  Container             : TContainer;

implementation

uses
  Ambrosia.Reflection,
  Ambrosia.Kernel.Default,
  Ambrosia.Resolver,
  Ambrosia.ComponentRegistration;

//--------------------------------------------------------------------------------------------------
// TContainer
//--------------------------------------------------------------------------------------------------

constructor TContainer.Create;

begin
FKernel := TKernel.Create;
FScopeStack := TStack<ILifetimeScope>.Create;
end;

//--------------------------------------------------------------------------------------------------

procedure TContainer.Install (Installer : IDependencyInstaller);

begin
Installer.Install (Self);
end;

//--------------------------------------------------------------------------------------------------

procedure TContainer.Register (Registration : IRegistration);

begin
FKernel.Register (Registration);
end;

//--------------------------------------------------------------------------------------------------

destructor TContainer.Destroy;

begin
FScopeStack.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TContainer.GetScope : ILifetimeScope;

begin
Result := FScopeStack.Pop;
end;

//--------------------------------------------------------------------------------------------------

procedure TContainer.Install (Installers : TArray<IDependencyInstaller>);

var
  Installer             : IDependencyInstaller;

begin
for Installer in Installers do
  Installer.Install (Self);
end;

//--------------------------------------------------------------------------------------------------

procedure TContainer.Register (Registrations : IEnumerable<IRegistration>);

var
  Registration             : IRegistration;

begin
if not Assigned (Registrations) then Exit;
for Registration in Registrations do
  FKernel.Register (Registration);
end;

//--------------------------------------------------------------------------------------------------

procedure TContainer.Release (var Obj);

begin
FKernel.ReleaseComponent (Pointer (Obj));
Pointer (Obj) := nil;
end;


//--------------------------------------------------------------------------------------------------

function TContainer.Resolve<T> (Name : string) : T;

var
  LTypeInfo             : PTypeInfo;

begin
LTypeInfo := TypeInfo (T);
if not (LTypeInfo^.Kind in [tkInterface, tkClass]) then
  raise ERegistrationException.Create('Type must be a class or interface!');
//Result := TResolver.Resolve<T> (FRegistry, FInstances, nil);
//Result := FServiceMap.Resolve<T> (Name).AsType<T>;
end;

//--------------------------------------------------------------------------------------------------

function TContainer.Resolve<T> (Context : TCreationContext) : T;

var
  LTypeInfo             : PTypeInfo;

begin
LTypeInfo := TypeInfo (T);
if not (LTypeInfo^.Kind in [tkInterface, tkClass]) then
  raise ERegistrationException.Create('Type must be a class or interface!');
//Result := TResolver.Resolve<T> (FRegistry, FInstances, Context);
end;

//--------------------------------------------------------------------------------------------------

function TContainer.Resolve<T>: T;

var
  ServiceType           : PTypeInfo;
  Obj                   : TObject;
  LocalInterface        : Pointer;
  Value                 : TValue;

begin
ServiceType := TypeInfo (T);
Value := FKernel.Resolve (TypeInfo(T), nil);
Result := Value.AsType<T>;
end;

//--------------------------------------------------------------------------------------------------

function TContainer.ResolveAll<T>: IEnumerable<T>;

var
  LTypeInfo             : PTypeInfo;

begin
LTypeInfo := TypeInfo (T);
if not (LTypeInfo^.Kind in [tkInterface, tkClass]) then
  raise ERegistrationException.Create('Type must be a class or interface!');
//Result := TResolver.ResolveAll<T> (FRegistry, FInstances);
end;

procedure TContainer.SetScope (Value : ILifetimeScope);

begin
FScopeStack.Push (Value);
end;

//--------------------------------------------------------------------------------------------------
// Component
//--------------------------------------------------------------------------------------------------

class function Component.ForType<TService> : Registration<TService>;

var
  LTypeInfo             : PTypeInfo;

begin
LTypeInfo := TypeInfo (TService);
if not (LTypeInfo^.Kind in [tkInterface, tkClass]) then
  raise ERegistrationException.Create('Type must be a class or interface!');
end;

//--------------------------------------------------------------------------------------------------
// Classes
//--------------------------------------------------------------------------------------------------

class function AllTypes.FromApplication : TFromModuleDescriptor;

begin
Result := CreateFromModule (TModule.GetCallingModule);
end;

//--------------------------------------------------------------------------------------------------

class function AllTypes.FromPackageNamed (Name : string) : TFromModuleDescriptor;

begin
Result := CreateFromModule (TModule.GetModuleNamed (Name));
end;

//--------------------------------------------------------------------------------------------------
// Configuration
//--------------------------------------------------------------------------------------------------

class function Configuration.Add (Name : string; Value : TValue) : TConfiguration;

begin
Result := CreateConfiguration;
Result.Add (Name,Value);
end;

//--------------------------------------------------------------------------------------------------

class function Configuration.Add<T>(Name: string; Value: T): TConfiguration;

begin
Result := CreateConfiguration;
Result.Add<T> (Name,Value);
end;


initialization

Container := TContainer.Create;

finalization

Container.Free;
Container := nil;

end.
