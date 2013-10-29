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

unit Ambrosia.LifestyleModelInspector;

interface

uses
  Ambrosia.Reflection,
  Ambrosia.Interfaces;

type
  TLifestyleModelInspector = class (TInterfacedObject, IContributeComponentModelConstruction)
    protected
      procedure ReadLifestyleFromType (Model : TComponentModel);
    public
      procedure ProcessModel (Kernel: IKernel; Model : TComponentModel);
  end;

implementation

uses
  Ambrosia.BaseAttributes;

//--------------------------------------------------------------------------------------------------
// TLifestyleModelInspector
//--------------------------------------------------------------------------------------------------

procedure TLifestyleModelInspector.ProcessModel(Kernel: IKernel; Model: TComponentModel);

begin
ReadLifestyleFromType (Model);
end;

//--------------------------------------------------------------------------------------------------

procedure TLifestyleModelInspector.ReadLifestyleFromType (Model : TComponentModel);

var
  Attributes            : TArray<TLifestyleAttribute>;

begin
Attributes := Model.ImplType.Attributes<TLifestyleAttribute>;
if Length (Attributes) = 0 then Exit;
Model.Lifestyle := Attributes [0].Lifestyle;
end;


end.
