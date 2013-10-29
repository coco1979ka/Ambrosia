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

unit Ambrosia.Descriptor.Defaults;

interface

uses
  Rtti,
  Ambrosia.Interfaces;

type
  TDefaultsDescriptor = class (TInterfacedObject, IComponentModelDescriptor)
    private
      FName           : string;
      FImplementation : TRttiInstanceType;
    protected
      procedure BuildComponentModel(Kernel: IKernel; ComponentModel: TComponentModel);
      procedure ConfigureComponentModel(Kernel: IKernel; ComponentModel: TComponentModel);
    public
      constructor Create (Name : string; Impl : TRttiInstanceType);

  end;

implementation

//--------------------------------------------------------------------------------------------------
// TDefaultsDescriptor
//--------------------------------------------------------------------------------------------------

procedure TDefaultsDescriptor.BuildComponentModel (Kernel : IKernel; ComponentModel : TComponentModel);

var
  Name : string;
begin
ComponentModel.ImplType := FImplementation;
if ComponentModel.Name = ''
  then
    begin
    Name := ComponentModel.ImplType.Name;
    Name := ComponentModel.ImplType.DeclaringUnitName + '.' + Name;
    ComponentModel.Name := Name;
    end
  else
    ComponentModel.Name := FName;
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultsDescriptor.ConfigureComponentModel(Kernel: IKernel;
  ComponentModel: TComponentModel);
begin
end;

constructor TDefaultsDescriptor.Create (Name : string; Impl : TRttiInstanceType);

begin
FName := Name;
FImplementation := Impl;
end;

end.
