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

unit Ambrosia.ComponentRegistration;

interface

uses
  Rtti,
  Generics.Collections,
  TypInfo,
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  TComponentRegistration<TService> = class (TRegistration<TService>)
    private
      FDescriptors        : TList<IComponentModelDescriptor>;
      FName               : string;
      FImpl               : TRttiInstanceType;
      FPotentialServices  : TList<PTypeInfo>;
      function  GetContributors (Services : TArray<PTypeInfo>) : TArray<IComponentModelDescriptor>;
      function  Forward (Service : PTypeInfo) : TComponentRegistration<TService>; overload;
      function  Forward (Services : TArray<PTypeInfo>) : TComponentRegistration<TService>; overload;
      function  Forward<TService2> : TComponentRegistration<TService>; overload;
      function  FilterServices (Kernel : IKernelInternal) : TArray<PTypeInfo>;
    public
      constructor Create (ImplType : PTypeInfo); overload;
      constructor Create (Services : TArray<PTypeInfo>; ImplType : PTypeInfo); overload;
      destructor Destroy; override;
      procedure Register (Kernel : IKernelInternal); override;
      function  AddDescriptor (Descriptor : IComponentModelDescriptor) : TRegistration<TService>; override;
      function  DependsOn (Configuration : IConfiguration) : TRegistration<TService>; override;
      function  ImplementedBy (Impl : PTypeInfo) : TRegistration<TService>; override;
      function  Lifestyle : TLifestyleGroup<TService>; override;
      function  Named (const Name : string) : TRegistration<TService>; override;

  end;

implementation

uses
  Ambrosia.Utils,
  Ambrosia.LifestyleGroup,
  Ambrosia.Descriptor.Services,
  Ambrosia.Descriptor.CustomDependency,
  Ambrosia.Descriptor.Defaults;

//--------------------------------------------------------------------------------------------------
// TComponentRegistration<TService>
//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.AddDescriptor(Descriptor : IComponentModelDescriptor) : TRegistration<TService>;

begin
FDescriptors.Add (Descriptor);
end;

//--------------------------------------------------------------------------------------------------

constructor TComponentRegistration<TService>.Create (ImplType : PTypeInfo);

begin
FDescriptors := TList<IComponentModelDescriptor>.Create;
FPotentialServices := TList<PTypeInfo>.Create;
Forward (TypeInfo (TService));
ImplementedBy (ImplType);
end;

//--------------------------------------------------------------------------------------------------

constructor TComponentRegistration<TService>.Create (Services : TArray<PTypeInfo>; ImplType : PTypeInfo);

var
  Service               : PTypeInfo;

begin
FDescriptors := TList<IComponentModelDescriptor>.Create;
FPotentialServices := TList<PTypeInfo>.Create;
for Service in Services do
  Forward (Service);
ImplementedBy (ImplType);
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.DependsOn (Configuration : IConfiguration) : TRegistration<TService>;

begin
FDescriptors.Add (TCustomDependencyDescriptor.Create (Configuration.Arguments));
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

destructor TComponentRegistration<TService>.Destroy;

begin
FDescriptors.Free;
FPotentialServices.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.FilterServices(Kernel : IKernelInternal) : TArray<PTypeInfo>;

var
  Services              : TList<PTypeInfo>;

begin
Services := TList<PTypeInfo>.Create (FPotentialServices);
try
  //if new components only...
  Result := Services.ToArray;
finally
  Services.Free;
end;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.Forward (Services : TArray<PTypeInfo>) : TComponentRegistration<TService>;

var
  Service               : PTypeInfo;

begin
for Service in Services do
  TComponentServiceUtil.AddService (FPotentialServices, Service);
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.Forward (Service: PTypeInfo) : TComponentRegistration<TService>;

begin
TComponentServiceUtil.AddService (FPotentialServices, Service);
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.Forward<TService2>: TComponentRegistration<TService>;

begin

Result := Self;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.GetContributors (Services : TArray<PTypeInfo>) : TArray<IComponentModelDescriptor>;

var
  List                  : TList<IComponentModelDescriptor>;

begin
List := TList<IComponentModelDescriptor>.Create;
try
  List.Add (TServicesDescriptor.Create (Services));
  List.Add (TDefaultsDescriptor.Create (FName, FImpl));

  List.AddRange (FDescriptors);
  Result := List.ToArray;
finally
  List.Free;
end;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.ImplementedBy(Impl: PTypeInfo): TRegistration<TService>;

var
  Ctx                   : TRttiContext;

begin
FImpl := RttiContext.GetType (Impl) as TRttiInstanceType;
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.Lifestyle : TLifestyleGroup<TService>;

begin
Result := TLifestyleGroupImplementation<TService>.Create (Self);
end;

//--------------------------------------------------------------------------------------------------

function TComponentRegistration<TService>.Named (const Name : string) : TRegistration<TService>;

begin
FName := Name;
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

procedure TComponentRegistration<TService>.Register (Kernel : IKernelInternal);

var
  Services              : TArray<PTypeInfo>;

begin
Services := FilterServices (Kernel);
Kernel.AddCustomComponent (Kernel.ComponentModelBuilder.BuildModel (GetContributors (Services)));
end;



end.
