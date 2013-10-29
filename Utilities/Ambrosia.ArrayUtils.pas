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

unit Ambrosia.ArrayUtils;

interface

type
  TArrayUtils<T> = class
    public
      class function Contains (const SrcArray : TArray<T>; Element : T) : Boolean; static;
  end;

implementation

uses
  Generics.Defaults;

//--------------------------------------------------------------------------------------------------
// TArrayUtils<T>
//--------------------------------------------------------------------------------------------------

class function TArrayUtils<T>.Contains(const SrcArray: TArray<T>; Element: T): Boolean;

var
  I                     : Integer;
  Comparer              : IEqualityComparer<T>;

begin
Comparer := TEqualityComparer<T>.Default;
Result   := False;
for I := 0 to High (SrcArray) do
  if Comparer.Equals (SrcArray [I], Element) then Exit (True);
end;

end.
