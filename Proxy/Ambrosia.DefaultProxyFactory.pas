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

unit Ambrosia.DefaultProxyFactory;

interface

uses
  Rtti,
  TypInfo,
  Ambrosia.Interception,
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  TInterfaceProxy = class (TVirtualInterface)
    protected
      procedure MethodInvoked (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    public
      constructor Create (Service : PTypeInfo; Target : TObject);
  end;

  TProxyGenerator = class
    function CreateInterfaceProxyWithTarget (Service : PTypeInfo; AdditionalInterfaces : TArray<PTypeInfo>;
                                             Target : TObject; Interceptors : TArray<IInterceptor>) : TObject;
  end;


  TDefaultProxyFactory = class (TInterfacedObject, IProxyFactory)
    protected
      function  CreateProxy (Kernel : IKernel; Instance : TObject; Model : TComponentModel;
                             Context : ICreationContext; Arguments : TArguments) : TObject;
      function  RequiresTargetInstance (Kernel : IKernel; Model : TComponentModel) : Boolean;
      function  ShouldCreateProxy(Model: TComponentModel): Boolean;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TDefaultProxyFactory
//--------------------------------------------------------------------------------------------------

function TDefaultProxyFactory.CreateProxy (Kernel : IKernel; Instance : TObject;
                                           Model : TComponentModel; Context : ICreationContext;
                                           Arguments : TArguments) : TObject;

begin

end;

//--------------------------------------------------------------------------------------------------

function TDefaultProxyFactory.RequiresTargetInstance (Kernel : IKernel;
                                                      Model : TComponentModel) : Boolean;

begin

end;

//--------------------------------------------------------------------------------------------------

function TDefaultProxyFactory.ShouldCreateProxy (Model : TComponentModel) : Boolean;

begin
Result := Model.HasInterceptors;
end;


//--------------------------------------------------------------------------------------------------
// TProxyGenerator
//--------------------------------------------------------------------------------------------------

function TProxyGenerator.CreateInterfaceProxyWithTarget (Service : PTypeInfo;
                                                         AdditionalInterfaces : TArray<PTypeInfo>;
                                                         Target : TObject;
                                                         Interceptors : TArray<IInterceptor>) : TObject;

begin
//Result := TVirtualInterface.Create (Service
end;


//--------------------------------------------------------------------------------------------------
// TInterfaceProxy
//--------------------------------------------------------------------------------------------------

constructor TInterfaceProxy.Create (Service : PTypeInfo; Target : TObject);

begin
inherited Create (Service, MethodInvoked);

end;

//--------------------------------------------------------------------------------------------------

procedure TInterfaceProxy.MethodInvoked (Method: TRttiMethod; const Args: TArray<TValue>;
                                         out Result: TValue);

begin
//TRttiInvocation.Create ();
end;



end.
