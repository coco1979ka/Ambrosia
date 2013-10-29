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

unit Ambrosia.SegmentedList;

interface

uses
  Generics.Collections;

type
  TSegmentedList<T> = class
    private
      FSegments : array of TList<T>;
      function GetSegment (Index : Integer) : TList<T>;
    public
      constructor Create (SegmentCount : Integer = 1);
      destructor Destroy; override;
      procedure AddFirst (Segment : Integer; Item : T);
      procedure AddLast (Segment : Integer; Item : T);
      function  ToArray : TArray<T>;
  end;

implementation

uses
  Math;

//--------------------------------------------------------------------------------------------------
// TSegmentedList<T>
//--------------------------------------------------------------------------------------------------

procedure TSegmentedList<T>.AddFirst(Segment: Integer; Item: T);

begin
GetSegment (Segment).Insert (0, Item);
end;

//--------------------------------------------------------------------------------------------------

procedure TSegmentedList<T>.AddLast(Segment: Integer; Item: T);

begin
GetSegment (Segment).Add (Item);
end;

//--------------------------------------------------------------------------------------------------

constructor TSegmentedList<T>.Create(SegmentCount: Integer);

begin
Assert (SegmentCount > 1);
SetLength (FSegments, SegmentCount);
end;

//--------------------------------------------------------------------------------------------------

destructor TSegmentedList<T>.Destroy;

var
  Segment               : TList<T>;

begin
for Segment in FSegments do
  Segment.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TSegmentedList<T>.GetSegment(Index: Integer): TList<T>;

begin
Assert (InRange (Index, 0, Length (FSegments)-1));
if not Assigned (FSegments [Index]) then
  FSegments [Index] := TList<T>.Create;
Result := FSegments [Index];
end;

//--------------------------------------------------------------------------------------------------

function TSegmentedList<T>.ToArray: TArray<T>;

var
  Segment,
  TmpList               : TList<T>;

begin
TmpList := TList<T>.Create;
try
  for Segment in FSegments do
    if Assigned (Segment) then
      TmpList.AddRange (Segment);
  Result := TmpList.ToArray;
finally
  TmpList.Free;
end;
end;

end.
