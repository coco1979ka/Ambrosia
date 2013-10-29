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

unit Ambrosia.BaseAttributes;

interface

uses
  Ambrosia.Types;

type
  TLifestyleAttribute = class (TCustomAttribute)
    private
      FLifestyleType : TLifestyleType;
    public
      constructor Create (LifestyleType : TLifestyleType);
      property Lifestyle : TLifestyleType read FLifestyleType;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TLifestyleAttribute
//--------------------------------------------------------------------------------------------------

constructor TLifestyleAttribute.Create(LifestyleType: TLifestyleType);

begin
FLifestyleType := LifestyleType;
end;

end.
