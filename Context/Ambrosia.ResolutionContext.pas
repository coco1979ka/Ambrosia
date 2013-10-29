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

unit Ambrosia.ResolutionContext;

interface

uses
  Ambrosia.Interfaces;

type
  TResolutionContext = class (TInterfacedObject, IResolutionContext)
    private
      FBurden       : IBurden;
      FContext      : Pointer;
      FHandler      : Pointer;
      FTrackContext : Boolean;
    protected
      function  GetBurden  : IBurden;
      function  GetContext : ICreationContext;
      function  GetHandler : IHandler;
      procedure AttachBurden (Burden : IBurden);
      function  CreateBurden (TrackExternally : Boolean) : IBurden;
    public
      constructor Create (Context : ICreationContext; Handler : IHandler; TrackContext : Boolean);
      destructor Destroy; override;
  end;

implementation

uses
  Ambrosia.Burden;

//--------------------------------------------------------------------------------------------------
// TResolutionContext
//--------------------------------------------------------------------------------------------------

procedure TResolutionContext.AttachBurden (Burden : IBurden);

begin
//FBurden := Pointer (Burden);
FBurden := Burden;
end;

//--------------------------------------------------------------------------------------------------

constructor TResolutionContext.Create (Context : ICreationContext; Handler : IHandler;
                                       TrackContext : Boolean);

begin
FContext := Pointer (Context);
FHandler := Pointer (Handler);
FTrackContext := TrackContext;
end;

//--------------------------------------------------------------------------------------------------

function TResolutionContext.CreateBurden (TrackExternally : Boolean) : IBurden;

begin
if Assigned (FBurden) then Exit (GetBurden);
FBurden := TBurden.Create (GetHandler, TrackExternally);
Result := FBurden;
end;

//--------------------------------------------------------------------------------------------------

destructor TResolutionContext.Destroy;

begin
//GetContext.ExitResolutionContext (GetBurden, FTrackContext);   //TODO : check this
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TResolutionContext.GetBurden : IBurden;

begin
Result := IBurden (FBurden);
end;

//--------------------------------------------------------------------------------------------------

function TResolutionContext.GetContext : ICreationContext;

begin
Result := ICreationContext (FContext);
end;

//--------------------------------------------------------------------------------------------------

function TResolutionContext.GetHandler : IHandler;

begin
Result := IHandler (FHandler);
end;

end.
