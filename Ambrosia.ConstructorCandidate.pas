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

unit Ambrosia.ConstructorCandidate;

interface

uses
  Rtti,
  Generics.Collections,
  Ambrosia.Types,
  Ambrosia.DependencyModel;

type
  TConstructorCandidate = class
    private
      FConstructorMethod  : TRttiMethod;
      FDependencies       : TObjectList<TConstructorDependencyModel>;

      function GetDependencyCount : Integer;
    public
      constructor Create (ConstructorMethod : TRttiMethod; Dependencies : TArray<TConstructorDependencyModel>);
      destructor Destroy; override;
      property ConstructorMethod : TRttiMethod read FConstructorMethod;
      property Dependencies : TObjectList<TConstructorDependencyModel> read FDependencies;
      property DependencyCount : Integer read GetDependencyCount;

  end;

implementation

//--------------------------------------------------------------------------------------------------
// TConstructorCandidate
//--------------------------------------------------------------------------------------------------

constructor TConstructorCandidate.Create (ConstructorMethod : TRttiMethod;
                                          Dependencies : TArray<TConstructorDependencyModel>);

begin
FDependencies := TObjectList<TConstructorDependencyModel>.Create;
FConstructorMethod := ConstructorMethod;
FDependencies.AddRange (Dependencies);
end;


//--------------------------------------------------------------------------------------------------

destructor TConstructorCandidate.Destroy;

begin
FDependencies.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TConstructorCandidate.GetDependencyCount: Integer;

begin
Result := FDependencies.Count;
end;

end.
