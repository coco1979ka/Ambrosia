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

unit Ambrosia.DependencyModel;

interface

uses
  Rtti;

type
  TDependencyModel = class
    private
      FIsOptional       : Boolean;
      FName             : string;
      FType             : TRttiType;
      FHasDefaultValue  : Boolean;
      FDefaultValue     : TValue;
    public
      constructor Create (AName : string; AType : TRttiType; AIsOptional : Boolean;
                          AHasDefaultValue : Boolean; ADefault : TValue);

      property DefaultValue : TValue read FDefaultValue;
      property DependencyKey : string read FName;
      property HasDefaultValue : Boolean read FHasDefaultValue;
      property IsOptional : Boolean read FIsOptional;
      property TargetItemType : TRttiType read FType;

  end;

  TConstructorDependencyModel = class (TDependencyModel)
    public
        constructor Create (Parameter : TRttiParameter);
  end;

implementation

{ TDependencyModel }

constructor TDependencyModel.Create (AName : string; AType : TRttiType; AIsOptional,
                                     AHasDefaultValue : Boolean; ADefault : TValue);

begin
FName := AName;
FType := AType;
FIsOptional := AIsOptional;
FHasDefaultValue := AHasDefaultValue;
FDefaultValue := ADefault;
end;


{ TConstructorDependencyModel }

constructor TConstructorDependencyModel.Create (Parameter: TRttiParameter);

begin
//TODO check how default values can be handled
inherited Create (Parameter.Name, Parameter.ParamType, False, False, TValue.Empty);
end;

end.
