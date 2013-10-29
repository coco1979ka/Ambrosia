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

unit Ambrosia.Descriptor.Services;

interface

uses
  TypInfo,
  Ambrosia.Interfaces;

type
  TServicesDescriptor = class (TInterfacedObject, IComponentModelDescriptor)
    private
      FServices : TArray<PTypeInfo>;
    public
      constructor Create (Services : TArray<PTypeInfo>);
      procedure BuildComponentModel(Kernel: IKernel; ComponentModel: TComponentModel);
      procedure ConfigureComponentModel(Kernel: IKernel; ComponentModel: TComponentModel);

  end;

implementation


//--------------------------------------------------------------------------------------------------
// TServicesDescriptor
//--------------------------------------------------------------------------------------------------

procedure TServicesDescriptor.BuildComponentModel(Kernel: IKernel; ComponentModel: TComponentModel);

var
  Service               : PTypeInfo;

begin
for Service in FServices do
  ComponentModel.AddService (Service);
end;

//--------------------------------------------------------------------------------------------------

procedure TServicesDescriptor.ConfigureComponentModel(Kernel: IKernel;
  ComponentModel: TComponentModel);
begin

end;

constructor TServicesDescriptor.Create(Services: TArray<PTypeInfo>);

begin
FServices := Services;
end;

end.
