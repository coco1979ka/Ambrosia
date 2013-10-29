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

unit Ambrosia.Configuration;

interface

uses
  Rtti,
  Generics.Collections,
  Ambrosia.Interfaces;

type
  TConfiguration  = class (TInterfacedObject, IConfiguration)
    private
      FArguments : TDictionary<string, TValue>;
    protected
      constructor Create;
      destructor Destroy; override;
      function  GetArguments : TDictionary<string, TValue>;
    public
      function  Add (Name : string; Value : TValue) : TConfiguration; overload;
      function  Add<T> (Name : string; Value : T) : TConfiguration; overload;
  end;

  function CreateConfiguration : TConfiguration;

implementation

function CreateConfiguration : TConfiguration;

begin
Result := TConfiguration.Create;
end;

//--------------------------------------------------------------------------------------------------
// TConfiguration
//--------------------------------------------------------------------------------------------------

function TConfiguration.Add (Name : string; Value : TValue) : TConfiguration;

begin
FArguments.AddOrSetValue (Name, Value);
Writeln (Value.TypeInfo^.Name);
Result := Self;
end;

//--------------------------------------------------------------------------------------------------

function TConfiguration.Add<T>(Name: string; Value: T) : TConfiguration;

begin
Result := Add (Name, TValue.From<T> (Value));
end;

//--------------------------------------------------------------------------------------------------

constructor TConfiguration.Create;

begin
FArguments := TDictionary<string, TValue>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TConfiguration.Destroy;

begin
FArguments.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TConfiguration.GetArguments: TDictionary<string, TValue>;

begin
Result := FArguments;
end;

end.
