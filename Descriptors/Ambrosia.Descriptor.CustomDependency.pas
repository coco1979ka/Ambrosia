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

unit Ambrosia.Descriptor.CustomDependency;

interface

uses
  Rtti,
  Generics.Collections,
  Ambrosia.Interfaces;

type
  TCustomDependencyDescriptor = class (TInterfacedObject, IComponentModelDescriptor)
    private
      FMap : TDictionary<string, TValue>;
    public
      constructor Create (ConfigurationMap : TDictionary<string, TValue>);
      destructor  Destroy; override;
      procedure  BuildComponentModel(Kernel: IKernel; ComponentModel : TComponentModel);
      procedure  ConfigureComponentModel (Kernel : IKernel; ComponentModel : TComponentModel);
  end;

implementation


//--------------------------------------------------------------------------------------------------
// TCustomDependencyDescriptor
//--------------------------------------------------------------------------------------------------

procedure TCustomDependencyDescriptor.BuildComponentModel (Kernel : IKernel;
                                                           ComponentModel : TComponentModel);

begin

end;

//--------------------------------------------------------------------------------------------------

procedure TCustomDependencyDescriptor.ConfigureComponentModel (Kernel : IKernel;
                                                               ComponentModel : TComponentModel);

var
  Name                  : string;

begin
for Name in FMap.Keys do
  ComponentModel.CustomDependencies.Add (Name, FMap [Name]);
end;

//--------------------------------------------------------------------------------------------------
constructor TCustomDependencyDescriptor.Create (ConfigurationMap : TDictionary<string, TValue>);

begin
FMap := TDictionary < string, TValue>.Create (ConfigurationMap);
end;

//--------------------------------------------------------------------------------------------------

destructor TCustomDependencyDescriptor.Destroy;

begin
FMap.Free;
inherited;
end;

end.
