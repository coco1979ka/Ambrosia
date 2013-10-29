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

unit Ambrosia.LifetimeScopeAccessor;

interface

uses
  Ambrosia.Lifestyle.CallContextLifetimeScope,
  Ambrosia.Interfaces;

type
  TLifetimeScopeAccessor = class (TInterfacedObject, IScopeAccessor)
    protected
      procedure Dispose;
    public
      function GetScope (Context : ICreationContext) : ILifetimeScope;
  end;

implementation

//--------------------------------------------------------------------------------------------------
// TLifetimeScopeAccessor
//--------------------------------------------------------------------------------------------------

procedure TLifetimeScopeAccessor.Dispose;

begin
end;

//--------------------------------------------------------------------------------------------------

function TLifetimeScopeAccessor.GetScope(Context: ICreationContext): ILifetimeScope;

begin
Result := TCallContextLifetimeScope.ObtainCurrentScope;
end;

end.
