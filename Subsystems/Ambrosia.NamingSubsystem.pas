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

unit Ambrosia.NamingSubsystem;

interface

uses
  SyncObjs,
  Generics.Collections,
  TypInfo,
  Ambrosia.SortedDictionary,
  Ambrosia.Interfaces;

type
  THandlerWithPriority = record
    private
      FHandler  : IHandler;
      FPriority : Integer;
    public
      class function Create (Priority : Integer; Handler : IHandler) : THandlerWithPriority; static;
      class operator GreaterThan (const A, B  : THandlerWithPriority) : Boolean;
      property Handler : IHandler read FHandler;
  end;

  TServiceSelector = reference to function (Service : PTypeInfo) : THandlerWithPriority;

  TNamingSubsystem = class (TInterfacedObject, INamingSubsystem)
    private
      FWriteLock             : TCriticalSection;
      FHandlerByServiceCache : TDictionary<PTypeInfo,IHandler>;
      FHandlersByTypeCache   : TDictionary<PTypeInfo,TArray<IHandler>>;
      FNameToHandler         : TSortedDictionary<string, IHandler>;
      FServiceToHandler      : TDictionary<PTypeInfo, THandlerWithPriority>;
      function  GetHandlerByServiceCache : TDictionary<PTypeInfo, IHandler>;
      function  GetHandlersNoLock (Service : PTypeInfo) : TArray<IHandler>;
      function  GetServiceSelector (Handler : IHandler) : TServiceSelector;
      procedure InvalidateCache;
      function  IsDefault (Handler : IHandler; Service : PTypeInfo) : Boolean;
      function  IsFallback (Handler : IHandler; Service : PTypeInfo) : Boolean;
    protected
      property HandlerByServiceCache : TDictionary<PTypeInfo, IHandler> read GetHandlerByServiceCache;
    public
      constructor Create;
      destructor Destroy; override;
      function  GetHandler (Service: PTypeInfo) : IHandler; overload;
      function  GetHandler (Name : string) : IHandler; overload;
      function  GetHandlers(Service: PTypeInfo) : TArray<IHandler>;
      procedure Register (Handler : IHandler);

  end;

implementation

uses
  Generics.Defaults,
  Ambrosia.SegmentedList;

//--------------------------------------------------------------------------------------------------
// TNamingSubsystem
//--------------------------------------------------------------------------------------------------

constructor TNamingSubsystem.Create;

begin
FWriteLock := TCriticalSection.Create;
FNameToHandler := TSortedDictionary<string, IHandler>.Create;
FServiceToHandler := TDictionary<PTypeInfo, THandlerWithPriority>.Create;
FHandlersByTypeCache := TDictionary<PTypeInfo, TArray<IHandler>>.Create;
end;

//--------------------------------------------------------------------------------------------------

destructor TNamingSubsystem.Destroy;

var
  Handler : IHandler;

begin
for Handler in FNameToHandler.Values do
  (Handler as IDisposable).Dispose;
FNameToHandler.Free;
FServiceToHandler.Free;
FHandlersByTypeCache.Free;
FHandlerByServiceCache.Free;
FWriteLock.Free;
inherited;
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.GetHandler (Service: PTypeInfo): IHandler;

begin
Assert (Service<>nil);
if HandlerByServiceCache.TryGetValue (Service, Result)
  then Exit;
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.GetHandler (Name : string) : IHandler;

begin
Assert (Name <> '');
Result := FNameToHandler [Name];
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.GetHandlerByServiceCache: TDictionary<PTypeInfo, IHandler>;

var
  Item : TPair<PTypeInfo,THandlerWithPriority>;

begin
if Assigned (FHandlerByServiceCache) then
  Exit (FHandlerByServiceCache);
FWriteLock.Enter;
try
  FHandlerByServiceCache := TDictionary<PTypeInfo, IHandler>.Create;
  for Item in FServiceToHandler do
    FHandlerByServiceCache.Add (Item.Key, Item.Value.Handler);
  Result := FHandlerByServiceCache;
finally
  FWriteLock.Leave;
end;
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.GetHandlers (Service : PTypeInfo) : TArray<IHandler>;

begin
if FHandlersByTypeCache.TryGetValue (Service, Result) then
  Exit;
Result := GetHandlersNoLock (Service);
FHandlersByTypeCache.Add (Service, Result);
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.GetHandlersNoLock(Service: PTypeInfo): TArray<IHandler>;

var
  Handlers              : TSegmentedList<IHandler>;
  Handler               : IHandler;

const
  Defaults              = 0;
  Regulars              = 1;
  Fallbacks             = 2;

begin
Handlers := TSegmentedList<IHandler>.Create (3);
try
  for Handler in FNameToHandler.Values do
    begin
    if not Handler.Supports (Service) then Continue;
    if IsDefault (Handler, Service) then
      Handlers.AddFirst (Defaults, Handler);
    if IsFallBack (Handler, Service) then
      Handlers.AddLast (Fallbacks, Handler);
    Handlers.AddLast (Regulars, Handler);
    end;
  Result := Handlers.ToArray;
finally
  Handlers.Free;
end;
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.GetServiceSelector (Handler : IHandler) : TServiceSelector;

begin
Result := function (Service : PTypeInfo) : THandlerWithPriority
          begin
          Result := THandlerWithPriority.Create (0, Handler);
          end;

end;

//--------------------------------------------------------------------------------------------------

procedure TNamingSubsystem.InvalidateCache;

begin

end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.IsDefault(Handler: IHandler; Service: PTypeInfo): Boolean;

begin
//TODO : Get Default Handler predicate from model
Result := False;
end;

//--------------------------------------------------------------------------------------------------

function TNamingSubsystem.IsFallback(Handler: IHandler; Service: PTypeInfo): Boolean;

begin
//TODO : Get Fallback Handler predicate from model
Result := False;
end;

//--------------------------------------------------------------------------------------------------

procedure TNamingSubsystem.Register (Handler : IHandler);

var
  Name                  : string;
  Service               : PTypeInfo;
  ServiceSelector       : TServiceSelector;
  ServiceHandler        : THandlerWithPriority;

begin
Name := Handler.ComponentModel.Name;
FWriteLock.Enter;
try
  FNameToHandler.Add (Name, Handler);
  ServiceSelector := GetServiceSelector (Handler);
  for Service in Handler.ComponentModel.Services do
    begin
    ServiceHandler := ServiceSelector (Service);
    if not FServiceToHandler.ContainsKey (Service) or (ServiceHandler > FServiceToHandler [Service]) then
      FServiceToHandler.Add (Service, ServiceHandler);
      //FServiceToHandler [Service] := ServiceHandler;
    end;
  InvalidateCache;
finally
  FWritelock.Leave;
end;
end;

//--------------------------------------------------------------------------------------------------
// THandlerWithPriority
//--------------------------------------------------------------------------------------------------

class function THandlerWithPriority.Create (Priority : Integer; Handler : IHandler) : THandlerWithPriority;

begin
Result.FPriority := Priority;
Result.FHandler := Handler;
end;

//--------------------------------------------------------------------------------------------------

class operator THandlerWithPriority.GreaterThan(const A, B: THandlerWithPriority): Boolean;

begin
Result := False;
if (A.FPriority > B.FPriority) then
  Exit (True);
if (A.FPriority = B.FPriority) and (A.FPriority>0) then
  Result := True;
end;

end.
