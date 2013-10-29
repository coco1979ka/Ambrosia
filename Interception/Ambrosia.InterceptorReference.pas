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

unit Ambrosia.InterceptorReference;

interface

uses
  TypInfo,
  Ambrosia.Interception,
  Ambrosia.Interfaces;

type
  TInterceptorReference = class (TInterfacedObject, IReference<IInterceptor>)
    private
      FReferencedComponentName  : string;
      FReferencedComponentType  : PTypeInfo;
      function GetComponentType: PTypeInfo;
      function GetInterceptorHandler (Kernel : IKernel) : IHandler;
      function RebuildContext (HandlerType : PTypeInfo; Current : ICreationContext) : ICreationContext;
      property ComponentType : PTypeInfo read GetComponentType;
    protected
      procedure Attach (Component : TComponentModel);
      procedure Detach (Component : TComponentModel);
      function  Resolve (Kernel : IKernel; Context : ICreationContext) : IInterceptor;
    public
      constructor Create (ComponentName : string); overload;
      constructor Create (ComponentType : PTypeInfo); overload;
  end;

implementation

uses
  Ambrosia.CreationContext,
  Ambrosia.Types,
  Ambrosia.Reflection;

//--------------------------------------------------------------------------------------------------
// TInterceptorReference
//--------------------------------------------------------------------------------------------------

constructor TInterceptorReference.Create (ComponentName : string);

begin
Assert (ComponentName <> '');
FReferencedComponentName := ComponentName;
end;

//--------------------------------------------------------------------------------------------------

constructor TInterceptorReference.Create (ComponentType : PTypeInfo);

begin
Assert (ComponentType <> nil);
FReferencedComponentName := TComponentName.DefaultFor (ComponentType);
FReferencedComponentType := ComponentType;
end;

//--------------------------------------------------------------------------------------------------

procedure TInterceptorReference.Attach (Component : TComponentModel);

begin
//TODO : Component.Dependencies.ADD
end;

//--------------------------------------------------------------------------------------------------

procedure TInterceptorReference.Detach (Component : TComponentModel);

begin

end;

//--------------------------------------------------------------------------------------------------

function TInterceptorReference.GetComponentType : PTypeInfo;

begin
Result := FReferencedComponentType;
if not Assigned (Result) then
  Result := TypeInfo (IInterface);
end;

//--------------------------------------------------------------------------------------------------

function TInterceptorReference.GetInterceptorHandler (Kernel : IKernel) : IHandler;

begin
if (FReferencedComponentType <> nil) then
  Result := Kernel.GetHandler (FReferencedComponentType);
if not Assigned (Result) then
  Result := Kernel.GetHandler (FReferencedComponentName);
end;

//--------------------------------------------------------------------------------------------------

function TInterceptorReference.RebuildContext (HandlerType : PTypeInfo;
                                               Current : ICreationContext) : ICreationContext;

begin
Result := TCreationContext.Create (HandlerType, Current);
end;

//--------------------------------------------------------------------------------------------------

function TInterceptorReference.Resolve (Kernel : IKernel; Context : ICreationContext) : IInterceptor;

var
  Handler               : IHandler;
  InterceptorContext    : ICreationContext;

begin
Handler := GetInterceptorHandler (Kernel);
if not Assigned (Handler) then
  raise EResolutionException.Create ('Handler for Interceptor ' + FReferencedComponentName
                                     + ' could not be found');
if Handler.IsBeingResolvedInContext (Context) then
  raise EResolutionException.Create('Cyclic dependency detected for ' + FReferencedComponentName);
InterceptorContext := RebuildContext (ComponentType, Context);
//TODO: Test if this kind of reolution works correctly
Result := Handler.Resolve(InterceptorContext).AsType<IInterceptor>;
end;

end.
