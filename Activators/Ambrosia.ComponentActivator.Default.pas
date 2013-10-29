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

unit Ambrosia.ComponentActivator.Default;

interface

uses
  Rtti,
  Ambrosia.Burden,
  Ambrosia.ConstructorCandidate,
  Ambrosia.Interfaces,
  Ambrosia.ComponentActivator.Base,
  Ambrosia.DependencyModel;

type
  TDefaultComponentActivator = class (TComponentActivator)
    private
      function  BestScoreSoFar (CandidatePoints, WinnerPoints : Integer;
                                WinnerCandidate : TConstructorCandidate) : Boolean;
      function  BestPossibleScore (Candidate : TConstructorCandidate; Score : Integer) : Boolean;
      function  CanSatisfyDependency (Context : ICreationContext;
                                      DependencyModel : TDependencyModel) : Boolean;
      function  CheckCandidate (Candidate : TConstructorCandidate; Context : ICreationContext;
                                var Points : Integer) : Boolean;
      function  CreateConstructorArguments (Candidate : TConstructorCandidate;
                                            Context : ICreationContext) : TArray<TValue>;
      function  CreateInstance (Context : ICreationContext; Candidate : TConstructorCandidate;
                                Arguments : TArray<TValue>) : TObject;
      function  RttiCreate (ImplType : TRttiInstanceType; Arguments : TArray<TValue>;
                            ConstructorCandidate : TConstructorCandidate) : TObject;
    protected
      function  SelectEligableConstructor (Context : ICreationContext) : TConstructorCandidate;
      function  Instantiate (Context : ICreationContext) : TObject;
      function  InternalCreate (Context : ICreationContext) : TObject; override;
      procedure InternalDestroy (Instance : TValue; ReleaseInterface : Boolean); override;
  end;

implementation

uses
  TypInfo,
  Ambrosia.Types;

//--------------------------------------------------------------------------------------------------
// TDefaultComponentActivator
//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.BestPossibleScore (Candidate : TConstructorCandidate;
                                                       Score : Integer) : Boolean;

begin
Result := (Score = Candidate.DependencyCount * 100);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.BestScoreSoFar (CandidatePoints, WinnerPoints : Integer;
                                                    WinnerCandidate : TConstructorCandidate) : Boolean;

begin
Result := (WinnerCandidate = nil) or (WinnerPoints < CandidatePoints);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.CanSatisfyDependency (Context : ICreationContext;
                                                          DependencyModel : TDependencyModel) : Boolean;

begin
Result := Kernel.Resolver.CanResolve (Context, Context.Handler, Model, DependencyModel);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.CheckCandidate (Candidate : TConstructorCandidate;
                                                    Context : ICreationContext;
                                                    var Points : Integer) : Boolean;

var
  Dependency            : TDependencyModel;

begin
Points := 0;
for Dependency in Candidate.Dependencies do
  begin
  if CanSatisfyDependency (Context, Dependency) then
    Points := Points + 100
  else if Dependency.HasDefaultValue then
    Points := Points + 1
  else
    begin
    Points := 0;
    Exit (False);
    end;
  end;
Result := True;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.CreateConstructorArguments (Candidate : TConstructorCandidate;
                                                                Context : ICreationContext) : TArray<TValue>;

var
  I                     : Integer;

begin
SetLength (Result, Candidate.DependencyCount);
try
  for I := 0 to Candidate.DependencyCount - 1 do
    begin
    Result [I] := Kernel.Resolver.Resolve (Context, Context.Handler, Model, Candidate.Dependencies [I]);
    end;
except
//  for Argument in Result do
//    Kernel.ReleaseComponent (Argument);
end;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.CreateInstance (Context   : ICreationContext;
                                                    Candidate : TConstructorCandidate;
                                                    Arguments : TArray<TValue>) : TObject;

var
  CreateProxy           : Boolean;

begin
CreateProxy := Kernel.ProxyFactory.ShouldCreateProxy (Model);
Result := RttiCreate (Model.ImplType, Arguments, Candidate);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.Instantiate (Context : ICreationContext) : TObject;

var
  Candidate             : TConstructorCandidate;
  Arguments             : TArray<TValue>;

begin
Candidate := SelectEligableConstructor (Context);
Arguments := CreateConstructorArguments (Candidate, Context);
Result := CreateInstance (Context, Candidate, Arguments);
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.InternalCreate (Context : ICreationContext) : TObject;

begin
Result := Instantiate (Context);
end;

//--------------------------------------------------------------------------------------------------

procedure TDefaultComponentActivator.InternalDestroy (Instance : TValue; ReleaseInterface : Boolean);

var
  IntfObj               : TInterfacedObject;
  I                     : Integer;

begin
if (Instance.Kind = tkInterface) then
  begin
  if ReleaseInterface then
    begin
    IntfObj := TInterfacedObject (Instance.AsInterface);
    if (IntfObj is TVirtualInterface) or (IntfObj.ClassName = 'TEbInterfacedObject')
      then
        for I := 0 to IntfObj.RefCount - 3 do   //TODO : Make some special treatment for proxy objects
          Instance.AsInterface._Release
      else
        for I := 0 to IntfObj.RefCount - 1 do   //TODO : Make some special treatment for proxy objects
          Instance.AsInterface._Release

    end;
  end;
if Instance.Kind = tkClass then
  Instance.AsObject.Free;
Instance := TValue.Empty;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.RttiCreate (ImplType : TRttiInstanceType; Arguments : TArray<TValue>;
                                                ConstructorCandidate: TConstructorCandidate): TObject;

begin
Result := ConstructorCandidate.ConstructorMethod.Invoke (ImplType.MetaclassType, Arguments).AsObject;
end;

//--------------------------------------------------------------------------------------------------

function TDefaultComponentActivator.SelectEligableConstructor (Context : ICreationContext) : TConstructorCandidate;

var
  Candidate,
  WinnerCandidate       : TConstructorCandidate;
  CandidatePoints,
  WinnerPoints          : Integer;


begin
if Model.Constructors.Count = 1 then
  Exit (Model.Constructors [0]);
WinnerCandidate := nil;
WinnerPoints := 0;
for Candidate in Model.Constructors do
  begin
  CandidatePoints := 0;
  if not CheckCandidate (Candidate, Context, CandidatePoints) then
    Continue;
  if (BestScoreSoFar (CandidatePoints, WinnerPoints, WinnerCandidate)) then
    begin
    if (BestPossibleScore (Candidate, CandidatePoints)) then
      Exit (Candidate);
    WinnerCandidate := Candidate;
    WinnerPoints := CandidatePoints;
    end;
  end;
if not Assigned (WinnerCandidate) then
  raise ENoResolvableConstructorFound.Create('Error Message');
Result := WinnerCandidate;
end;

end.
