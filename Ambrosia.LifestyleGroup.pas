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

unit Ambrosia.LifestyleGroup;

interface

uses
  TypInfo,
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  TLifestyleGroupImplementation<TService> = class (TLifestyleGroup<TService>)
    private
      FRegistration : Pointer;
      function  GetRegistration : TRegistration<TService>;
    protected
      function  InitPerThread : TRegistration<TService>; override;
      function  InitScoped (ScopeType : PTypeInfo) : TRegistration<TService>; override;
      function  InitSingleton : TRegistration<TService>; override;
      function  InitTransient : TRegistration<TService>; override;
      property  Registration : TRegistration<TService> read GetRegistration;
    public
      constructor Create (Registration : TRegistration<TService>);
  end;

implementation

uses
  Ambrosia.Descriptor.ExtendedProperties,
  Ambrosia.Descriptor.Lifestyle;


//--------------------------------------------------------------------------------------------------
// TLifestyleGroup<TService>
//--------------------------------------------------------------------------------------------------

constructor TLifestyleGroupImplementation<TService>.Create(Registration: TRegistration<TService>);

begin
FRegistration := Pointer (Registration);
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroupImplementation<TService>.GetRegistration : TRegistration<TService>;

begin
Result := TRegistration<TService> (FRegistration);
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroupImplementation<TService>.InitPerThread : TRegistration<TService>;

begin
Result := Registration.AddDescriptor (TLifestyleDescriptor.Create(TLifestyleType.PerThread))
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroupImplementation<TService>.InitScoped (ScopeType : PTypeInfo) : TRegistration<TService>;

var
  ScopeAccessor         : IComponentModelDescriptor;

begin
Result := Registration.AddDescriptor (TLifestyleDescriptor.Create (TLifestyleType.Scoped));
if (ScopeType = nil) then
  Exit;
ScopeAccessor := TExtendedPropertiesDescriptor.Create ();
Registration.AddDescriptor (ScopeAccessor);
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroupImplementation<TService>.InitSingleton: TRegistration<TService>;

begin
Result := Registration.AddDescriptor (TLifestyleDescriptor.Create(TLifestyleType.Singleton));
end;

//--------------------------------------------------------------------------------------------------

function TLifestyleGroupImplementation<TService>.InitTransient: TRegistration<TService>;

begin
Result := Registration.AddDescriptor (TLifestyleDescriptor.Create (TLifestyleType.Transient));
end;

end.
