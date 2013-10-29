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

unit Ambrosia.InterceptorInspector;

interface

uses
  Generics.Collections,
  Ambrosia.Interception,
  Ambrosia.Interfaces;

type
  TInterceptorInspector = class (TInterfacedObject, IContributeComponentModelConstruction)
    protected
      procedure AddInterceptor (Reference : IReference<IInterceptor>; Interceptors : TList<IReference<IInterceptor>>);
      procedure CollectFromAttributes (Model : TComponentModel);
      procedure ProcessModel(Kernel: IKernel; Model: TComponentModel);

  end;

implementation

uses
  Ambrosia.Attributes,
  Ambrosia.Reflection;

//--------------------------------------------------------------------------------------------------
// TInterceptorInspector
//--------------------------------------------------------------------------------------------------

procedure TInterceptorInspector.AddInterceptor (Reference : IReference<IInterceptor>;
                                                Interceptors : TList<IReference<IInterceptor>>);

begin
Interceptors.Add (Reference);
end;

//--------------------------------------------------------------------------------------------------

procedure TInterceptorInspector.CollectFromAttributes (Model : TComponentModel);

var
  Attribute             : InterceptorAttribute;
  Attributes            : TArray<InterceptorAttribute>;

begin
Attributes := Model.ImplType.Attributes<InterceptorAttribute>;
for Attribute in Attributes do
  AddInterceptor (Attribute.Interceptor, Model.Interceptors);
end;

//--------------------------------------------------------------------------------------------------

procedure TInterceptorInspector.ProcessModel (Kernel : IKernel; Model : TComponentModel);

begin
CollectFromAttributes (Model);
end;


end.
