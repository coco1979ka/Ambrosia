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

unit Ambrosia.ComponentModelBuilder;

interface

uses
  Rtti,
  Generics.Collections,
  Ambrosia.Interfaces;

type
  TComponentModelBuilder = class (TInterfacedObject, IComponentModelBuilder)
    private
      FContributors : TList<IContributeComponentModelConstruction>;
      FKernel       : Pointer;

      function  GetKernel : IKernel;
      procedure InitializeContributors;
    protected
      procedure AddContributor (Contributor : IContributeComponentModelConstruction);
      function BuildModel (CustomDescriptors : TArray<IComponentModelDescriptor>) : TComponentModel;
      property Kernel : IKernel read GetKernel;
    public
      constructor Create (Kernel : IKernel);
      destructor Destroy; override;
  end;

implementation

uses
  Ambrosia.InterceptorInspector,
  Ambrosia.ConstructorModelInspector,
  Ambrosia.LifestyleModelInspector,
  Ambrosia.ConstructorCandidate;

//--------------------------------------------------------------------------------------------------
// TComponentModelBuilder
//--------------------------------------------------------------------------------------------------

procedure TComponentModelBuilder.AddContributor(Contributor: IContributeComponentModelConstruction);

begin
FContributors.Add (Contributor);
end;

//--------------------------------------------------------------------------------------------------

function TComponentModelBuilder.BuildModel (CustomDescriptors : TArray<IComponentModelDescriptor>) : TComponentModel;

var
  Descriptor            : IComponentModelDescriptor;
  Contributor           : IContributeComponentModelConstruction;

begin
Result := TComponentModel.Create;
for Descriptor in CustomDescriptors do
  Descriptor.BuildComponentModel (Kernel, Result);
for Contributor in FContributors do
  Contributor.ProcessModel (Kernel, Result);
for Descriptor in CustomDescriptors do
  Descriptor.ConfigureComponentModel (Kernel, Result);
end;

//--------------------------------------------------------------------------------------------------

constructor TComponentModelBuilder.Create(Kernel: IKernel);

begin
FContributors := TList<IContributeComponentModelConstruction>.Create;
FKernel := Pointer (Kernel);
InitializeContributors;
end;

//--------------------------------------------------------------------------------------------------

destructor TComponentModelBuilder.Destroy;

begin
FContributors.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TComponentModelBuilder.GetKernel: IKernel;

begin
Result := IKernel (FKernel);
end;

//--------------------------------------------------------------------------------------------------

procedure TComponentModelBuilder.InitializeContributors;

begin
AddContributor (TConstructorModelInspector.Create);
AddContributor (TLifestyleModelInspector.Create);
AddContributor (TInterceptorInspector.Create);
end;

end.
