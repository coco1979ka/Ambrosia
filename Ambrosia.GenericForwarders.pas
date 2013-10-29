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

unit Ambrosia.GenericForwarders;

interface

uses
  Generics.Collections,
  Generics.Defaults,
  TypInfo,
  Rtti,
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  Service<S> = record
    class function ImplementedBy<T> : IRegistration; static;
//    class function UsingFactoryMethod (FactoryMethod : TFactoryMethod<S>) : IRegistration; static;
    class operator Implicit (A : Service<S>) : IRegistration;
  end;

  Registration<TService> = record
    class function ImplementedBy<TImplementation> : TRegistration<TService>; static;
    {TRegistration<TService> accessors}
    class function Named (const Name : string) : TRegistration<TService>; static;
    class operator Implicit (A : Registration<TService>) : TRegistration<TService>;
  end;

  TFromDescriptor = class;
  TBasedOnDescriptor = class;

  TServiceDescriptor = class
    private
      FBasedOnDescriptor : TBasedOnDescriptor;
    protected 
      function  GetServices (RttiType : TRttiType; BaseTypes : TArray<TRttiType>) : TArray<PTypeInfo>;
    public
      constructor Create (BasedOn : TBasedOnDescriptor);
  end;
  
  TBasedOnDescriptor = class (TInterfacedObject, IRegistration)
    private
      FIfConditions     : TList<TFilterPredicate>;
      FFrom             : TFromDescriptor;
      FPotentialBases   : TArray<TRttiType>;
      FService          : TServiceDescriptor;
      FUnlessConditions : TList<TFilterPredicate>;
    protected
      constructor Create (BasedOn : TArray<TRttiType>; FromDescriptor : TFromDescriptor);
      destructor Destroy; override;
      function  Accepts (RttiType : TRttiType; out BaseTypes : TArray<TRttiType>) : Boolean;
      function  ExecuteIfCondition (RttiType : TRttiType) : Boolean;
      function  ExecuteUnlessCondition (RttiType : TRttiType) : Boolean;
      function  IsBasedOn (RttiType : TRttiType; out BaseTypes : TArray<TRttiType>) : Boolean;
      procedure Register (Kernel : IKernelInternal);
      function  TryRegister (RttiType : TRttiType; Kernel : IKernel) : Boolean;
    public

      function  IfCondition (Predicate : TFilterPredicate) : TBasedOnDescriptor;
      function  UnlessCondition (Predicate : TFilterPredicate) : TBasedOnDescriptor;
  end;

  TFromDescriptor = class (TInterfacedObject, IRegistration)
    private
      FCriterias : TList<TBasedOnDescriptor>;
      function  BasedOn (RttiType : TRttiType) : TBasedOnDescriptor; overload;
    protected
      constructor Create;
      destructor Destroy; override;
      procedure Register (Kernel : IKernelInternal);
      function  SelectedTypes : TArray<TRttiType>; virtual; abstract;
    public
      function  BasedOn<T> : TBasedOnDescriptor; overload;
      function  Where (Filter : TFilterPredicate) : TBasedOnDescriptor;
  end;

  TFromModuleDescriptor = class (TFromDescriptor)
    private
      FModule : TRttiPackage;
    protected
      constructor Create (Module : TRttiPackage);
      function SelectedTypes : TArray<TRttiType>; override;
  end;

  function CreateFromModule (Module : TRttiPackage) : TFromModuleDescriptor;


implementation

uses
  Windows,

  Ambrosia.Reflection,
  Ambrosia.ComponentRegistration;

function CreateFromModule (Module : TRttiPackage) : TFromModuleDescriptor;

begin
Result := TFromModuleDescriptor.Create (Module);
end;

//--------------------------------------------------------------------------------------------------
// Service
//--------------------------------------------------------------------------------------------------

class function Service<S>.ImplementedBy<T> : IRegistration;

var
  ServiceType,
  ImplementationType    : PTypeInfo;

begin
ServiceType := TypeInfo (S);
//Result := TRegistration.Create<S,T>;
end;

//--------------------------------------------------------------------------------------------------

class operator Service<S>.Implicit (A : Service<S>) : IRegistration;

begin
Result := A.ImplementedBy<S>;
end;

//--------------------------------------------------------------------------------------------------
// Registration<TService>
//--------------------------------------------------------------------------------------------------

class function Registration<TService>.ImplementedBy<TImplementation>: TRegistration<TService>;

begin
Result := TComponentRegistration<TService>.Create (TypeInfo (TImplementation));
end;

//--------------------------------------------------------------------------------------------------

class operator Registration<TService>.Implicit(A: Registration<TService>): TRegistration<TService>;

begin
Result := A.ImplementedBy<TService>;
end;

//--------------------------------------------------------------------------------------------------

class function Registration<TService>.Named(const Name: string): TRegistration<TService>;

begin
Result := TComponentRegistration<TService>.Create (TypeInfo (TService));
Result.Named (Name);
end;

//--------------------------------------------------------------------------------------------------
// TBasedOnDescriptor
//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.Accepts (RttiType : TRttiType; out BaseTypes : TArray<TRttiType>) : Boolean;

begin
Result := IsBasedOn (RttiType, BaseTypes) and ExecuteIfCondition (RttiType)
          and not ExecuteUnlessCondition (RttiType);
end;

//--------------------------------------------------------------------------------------------------

constructor TBasedOnDescriptor.Create (BasedOn : TArray<TRttiType>; FromDescriptor : TFromDescriptor);

begin
FIfConditions := TList<TFilterPredicate>.Create;
FPotentialBases := BasedOn;
FFrom := FromDescriptor;
FService := TServiceDescriptor.Create (Self);
FUnlessConditions := TList<TFilterPredicate>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TBasedOnDescriptor.Destroy;

begin
FUnlessConditions.Free;
FIfConditions.Free;
FService.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.ExecuteIfCondition (RttiType : TRttiType) : Boolean;

var
  IfCondition           : TFilterPredicate;

begin
Result := True;
for IfCondition in FIfConditions do
  if not IfCondition (RttiType) then Exit (False);
end;

//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.ExecuteUnlessCondition (RttiType : TRttiType) : Boolean;

var
  UnlessCondition       : TFilterPredicate;

begin
Result := False;
for UnlessCondition in FUnlessConditions do
  if UnlessCondition (RttiType) then Exit (True)
end;

//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.IfCondition(Predicate: TFilterPredicate): TBasedOnDescriptor;

begin
FIfConditions.Add (Predicate);
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.IsBasedOn (RttiType : TRttiType; out BaseTypes : TArray<TRttiType>) : Boolean;

var
  ActuallyBasedOn       : TList<TRttiType>;
  PotentialBase         : TRttiType;

begin
ActuallyBasedOn := TList<TRttiType>.Create;
try
  for PotentialBase in FPotentialBases do
    if PotentialBase.CanBeAssignedFrom (RttiType) then
      ActuallyBasedOn.Add (PotentialBase);
  BaseTypes := ActuallyBasedOn.ToArray;
  Result := Length (BaseTypes) > 0;
finally
  ActuallyBasedOn.Free;
end;
end;

//--------------------------------------------------------------------------------------------------

procedure TBasedOnDescriptor.Register (Kernel : IKernelInternal);

begin
IRegistration (FFrom).Register (Kernel);
FFrom.Free;
end;

//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.TryRegister (RttiType: TRttiType; Kernel: IKernel) : Boolean;

var
  BaseTypes             : TArray<TRttiType>;
  Registration          : IRegistration;
  Services              : TArray<PTypeInfo>;

begin
Result := True;
if not Accepts (RttiType, BaseTypes) then
  Exit (False);
Services := FService.GetServices (RttiType, BaseTypes);
//TODO : Should we better use a non generic registration?
Registration := TComponentRegistration<TObject>.Create (Services, RttiType.Handle);
Kernel.Register (Registration);
end;

//--------------------------------------------------------------------------------------------------

function TBasedOnDescriptor.UnlessCondition(Predicate: TFilterPredicate): TBasedOnDescriptor;

begin
FUnlessConditions.Add (Predicate);
Result := Self;
end;

//--------------------------------------------------------------------------------------------------
// TFromDescriptor
//--------------------------------------------------------------------------------------------------

function TFromDescriptor.BasedOn<T> : TBasedOnDescriptor;

var
  RttiType : TRttiType;

begin
RttiType := GlobalCtx.GetType (TypeInfo (T));
Result := BasedOn (RttiType);
end;

//--------------------------------------------------------------------------------------------------

constructor TFromDescriptor.Create;

begin
FCriterias := TList<TBasedOnDescriptor>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TFromDescriptor.Destroy;

begin
FCriterias.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TFromDescriptor.BasedOn (RttiType : TRttiType): TBasedOnDescriptor;

var
  PotentialBases        : TArray<TRttiType>;
  
begin
SetLength (PotentialBases, 1);
PotentialBases [0] := RttiType;
Result := TBasedOnDescriptor.Create (PotentialBases, Self);
FCriterias.Add (Result);
end;

//--------------------------------------------------------------------------------------------------

procedure TFromDescriptor.Register (Kernel : IKernelInternal);

var
  RttiType              : TRttiType;
  Criteria              : TBasedOnDescriptor;

begin
if (FCriterias.Count = 0) then Exit;
for RttiType in SelectedTypes do
  begin
  for Criteria in FCriterias do
    if Criteria.TryRegister (RttiType, Kernel as IKernel)
      then Break; 
  end;

end;

//--------------------------------------------------------------------------------------------------

function TFromDescriptor.Where (Filter : TFilterPredicate): TBasedOnDescriptor;

var
  Arr  : TArray<TRttiType>;
begin
Result := TBasedOnDescriptor.Create (Arr, Self).IfCondition (Filter);
end;

//--------------------------------------------------------------------------------------------------
// TFromModuleDescriptor
//--------------------------------------------------------------------------------------------------

constructor TFromModuleDescriptor.Create(Module: TRttiPackage);

begin
inherited Create;
FModule := Module;
end;

//--------------------------------------------------------------------------------------------------

function TFromModuleDescriptor.SelectedTypes : TArray<TRttiType>;

begin
Result := FModule.GetTypes;
end;

//--------------------------------------------------------------------------------------------------
// TServiceDescriptor
//--------------------------------------------------------------------------------------------------

constructor TServiceDescriptor.Create(BasedOn: TBasedOnDescriptor);

begin
FBasedOnDescriptor := BasedOn;
end;

//--------------------------------------------------------------------------------------------------

function TServiceDescriptor.GetServices (RttiType: TRttiType; BaseTypes: TArray<TRttiType>): TArray<PTypeInfo>;

var
  List : TList<PTypeInfo>;
  BaseType : TRttiType;
  
begin
List := TList<PTypeInfo>.Create;
try
  //TODO : we should do some selection here
  for BaseType in BaseTypes do
    List.Add (BaseType.Handle);  
  Result := List.ToArray;
finally
  List.Free;
end;
end;

end.
