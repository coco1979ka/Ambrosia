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

unit Ambrosia.ConstructorModelInspector;

interface

uses
  System.Rtti,
  Ambrosia.DependencyModel,
  Ambrosia.ConstructorCandidate,
  Ambrosia.Interfaces;

type
  TConstructorModelInspector = class (TInterfacedObject, IContributeComponentModelConstruction)
    private
      function  GetDependencies (Method : TRttiMethod) : TArray<TConstructorDependencyModel>;
      procedure ProcessDeclaredConstructors (RttiInstanceType : TRttiInstanceType;
                                             Model : TComponentModel);
    protected
      procedure ProcessModel (Kernel : IKernel; Model : TComponentModel);
  end;

implementation

uses
  Generics.Collections;


//--------------------------------------------------------------------------------------------------
// TConstructorModelInspector
//--------------------------------------------------------------------------------------------------

function TConstructorModelInspector.GetDependencies (Method : TRttiMethod) : TArray<TConstructorDependencyModel>;

var
  RttiParameter         : TRttiParameter;
  DependencyList        : TList<TConstructorDependencyModel>;

begin
DependencyList := TList<TConstructorDependencyModel>.Create;
try
  for RttiParameter in Method.GetParameters do
    DependencyList.Add (TConstructorDependencyModel.Create(RttiParameter));
  Result := DependencyList.ToArray;
finally
  DependencyList.Free;
end;
end;

//--------------------------------------------------------------------------------------------------

procedure TConstructorModelInspector.ProcessDeclaredConstructors (RttiInstanceType: TRttiInstanceType;
                                                                  Model : TComponentModel);

var
  RttiMethod            : TRttiMethod;
  HasConstructor        : Boolean;

begin
HasConstructor := False;
for RttiMethod in RttiInstanceType.GetDeclaredMethods do
  if RttiMethod.IsConstructor then
    begin
    HasConstructor := True;
    Model.Constructors.Add (TConstructorCandidate.Create (RttiMethod, GetDependencies (RttiMethod)));
    end;
if not HasConstructor then
  if (RttiInstanceType.BaseType <> nil) then
    ProcessDeclaredConstructors (RttiInstanceType.BaseType, Model);
end;

//--------------------------------------------------------------------------------------------------

procedure TConstructorModelInspector.ProcessModel(Kernel: IKernel; Model: TComponentModel);

var
  Methods               : TArray<TRttiMethod>;

begin
Methods := Model.ImplType.GetMethods;
ProcessDeclaredConstructors (Model.ImplType, Model);
Model.Constructors.Sort;
end;

end.
