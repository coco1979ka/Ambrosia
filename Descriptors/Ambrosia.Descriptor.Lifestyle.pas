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

unit Ambrosia.Descriptor.Lifestyle;

interface

uses
  Ambrosia.Types,
  Ambrosia.Interfaces;

type
  TLifestyleDescriptor = class (TInterfacedObject, IComponentModelDescriptor)
    private
      FLifestyle : TLifestyleType;
    public
      constructor Create (Lifestyle : TLifestyleType);
      procedure BuildComponentModel (Kernel: IKernel; ComponentModel: TComponentModel);
      procedure ConfigureComponentModel(Kernel: IKernel; ComponentModel: TComponentModel);
  end;

implementation


//--------------------------------------------------------------------------------------------------
// TLifestyleDescriptor
//--------------------------------------------------------------------------------------------------

procedure TLifestyleDescriptor.ConfigureComponentModel(Kernel: IKernel;
  ComponentModel: TComponentModel);

begin
end;

//--------------------------------------------------------------------------------------------------

constructor TLifestyleDescriptor.Create (Lifestyle : TLifestyleType);

begin
FLifestyle := Lifestyle;
end;

//--------------------------------------------------------------------------------------------------

procedure TLifestyleDescriptor.BuildComponentModel (Kernel : IKernel; ComponentModel : TComponentModel);

begin
ComponentModel.Lifestyle := FLifestyle;
end;

end.
