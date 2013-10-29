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

unit Ambrosia.Interception;


interface

uses
  TypInfo,
  Rtti;

type
  AspectAttribute = class (TCustomAttribute)
    private
      FAspectName : string;
    public
      constructor Create (AspectName : string = '');
      function IsAspect (AClass : TClass) : Boolean;
  end;

  IInvocation = interface
    ['{FD8551F6-26C8-4D15-BD1E-0D92A6A42919}']
      function  GetName : string;
      function  GetParameter (Name : string) : TValue;
      function  GetResult : TValue;
      procedure SetParameter (Name : string; Value : TValue);
      procedure SetResult (const Value : TValue);
      procedure Proceed;
      property  Name : string read GetName;
      property  Result : TValue read GetResult write SetResult;
      property  Parameter [Name : string] : TValue read GetParameter write SetParameter;
  end;

  IInterceptor = interface
    ['{A8E4A50F-1959-4FDA-8B39-360E2A45329C}']
      procedure Intercept (Invocation : IInvocation);
  end;

  TAspectEvent = reference to procedure (Invocation : IInvocation);



  TInterceptor<T: IInterface> = class (TVirtualInterface, IInterceptor)
    private
//      class var FInterfaceTable : PInterfaceTable;
      FInstance : T;
//      function  GetSelf : T;
      function  IsAspectOf (Method : TRttiMethod) : Boolean;
      procedure MethodInvoked (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    protected

      procedure Intercept (Invocation : IInvocation); virtual;
    public
//      class constructor Create;
//      class destructor Destroy;
      constructor Create (Instance : T);
      destructor Destroy; override;
  end;

  TRttiInvocation = class (TInterfacedObject, IInvocation)
    private
      FInstance : TValue;
      FMethod   : TRttiMethod;
      FArgs     : TArray <TValue>;
      FResult   : TValue;
    protected
      function  GetName : string;
      function  GetParameter (Name : string) : TValue;
      function  GetResult: TValue;
      procedure SetParameter (Name : string; Value : TValue);
      procedure SetResult (const Value : TValue);
      procedure Proceed;
    public
      constructor Create (Instance : TValue; Method : TRttiMethod; Args : TArray <TValue>);
  end;


implementation

uses
//  DI.InterceptorReference,
  SysUtils,
  StrUtils,
  Windows;


//--------------------------------------------------------------------------------------------------
//--- AspectAttribute
//--------------------------------------------------------------------------------------------------

constructor AspectAttribute.Create (AspectName : string);

begin
FAspectName := AspectName;
end;

//--------------------------------------------------------------------------------------------------

function AspectAttribute.IsAspect (AClass: TClass) : Boolean;

var
  AspectClassName : string;

begin
if FAspectName = '' then Exit (True);
Result := False;
AspectClassName := 'T' + FAspectName + 'Aspect';
if StartsText (AspectClassName, AClass.ClassName)
  then Result := True;
end;

//--------------------------------------------------------------------------------------------------
//--- TInterceptor<T>
//--------------------------------------------------------------------------------------------------

constructor TInterceptor<T>.Create (Instance : T);

begin
//Writeln ('Creating Interceptor<T>');
inherited Create (TypeInfo (T), MethodInvoked);
FInstance := Instance;
end;

//--------------------------------------------------------------------------------------------------

destructor TInterceptor<T>.Destroy;

begin
//FInstance.Empty;
//Writeln ('Destroying Interceptor<T>');
inherited;
end;

////--------------------------------------------------------------------------------------------------
//
//class constructor TInterceptor<T>.Create;
//
//var
//  Count                 : NativeUInt;
//
//begin
//New (FInterfaceTable);
//FInterfaceTable.EntryCount := 1;
//FInterfaceTable.Entries [0].IID     := GetTypeData (TypeInfo (T)).GUID;
//FInterfaceTable.Entries [0].VTable  := nil;
//FInterfaceTable.Entries [0].IOffset := 0;
//FinterfaceTable.Entries [0].ImplGetter := NativeUInt (@TInterceptor <T>.GetSelf);
//WriteProcessMemory (GetCurrentProcess,
//                    PPointer (NativeInt (TInterceptor <T>) + vmtIntfTable),
//                    @FInterfaceTable,
//                    SizeOf (Pointer),
//                    Count);
//end;

////--------------------------------------------------------------------------------------------------
//
//class destructor TInterceptor<T>.Destroy;
//
//begin
//Dispose(FInterfaceTable);
//end;

//--------------------------------------------------------------------------------------------------
//
//function TInterceptor<T>.GetSelf: T;
//
//begin
//Self.QueryInterface (GetTypeData (TypeInfo (T)).GUID, Result);
//end;

//--------------------------------------------------------------------------------------------------

procedure TInterceptor<T>.Intercept (Invocation : IInvocation);

begin
Invocation.Proceed;
end;

//--------------------------------------------------------------------------------------------------

function TInterceptor<T>.IsAspectOf(Method: TRttiMethod): Boolean;

var
  Attr :  TCustomAttribute;

begin
Result := False;
for Attr in Method.GetAttributes do
  if Attr is AspectAttribute then
    if AspectAttribute (Attr).IsAspect (Self.ClassType) then Exit (True);
end;

//--------------------------------------------------------------------------------------------------

procedure TInterceptor<T>.MethodInvoked (Method : TRttiMethod; const Args: TArray<TValue>;
                                         out Result: TValue);

var
  Invocation            : IInvocation;
  Attr                  : TCustomAttribute;
  DoIntercept           : Boolean;

begin
Invocation := TRttiInvocation.Create (TValue.From<T> (FInstance) , Method, Args);
if IsAspectOf (Method)
  then Intercept (Invocation)
  else Invocation.Proceed;
Result := Invocation.Result;
end;


//--------------------------------------------------------------------------------------------------
//--- TRttiInvocation
//--------------------------------------------------------------------------------------------------

constructor TRttiInvocation.Create (Instance: TValue; Method: TRttiMethod; Args: TArray<TValue>);

begin
FInstance := Instance;
FMethod := Method;
FArgs := Args;
end;

//--------------------------------------------------------------------------------------------------

function TRttiInvocation.GetName: string;

begin
Result := FMethod.Name;
end;

//--------------------------------------------------------------------------------------------------

function TRttiInvocation.GetParameter (Name: string): TValue;

var
  I                     : Integer;
  Parameter             : TRttiParameter;

begin
Result := TValue.Empty;
I := 1;
for Parameter in FMethod.GetParameters do
  begin
  if Parameter.Name = Name then
    Exit (FArgs [I]);
  Inc (I);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TRttiInvocation.GetResult: TValue;

begin
Result := FResult;
end;

//--------------------------------------------------------------------------------------------------

procedure TRttiInvocation.Proceed;

var
  Args : TArray <TValue>;
  I : Integer;

begin
if Length (FArgs) > 1 then
  begin
  SetLength (Args, Length (FArgs) - 1);
  for I := 0 to Length (Args) - 1 do
    Args [I] := FArgs [I + 1]
  end;

FResult := FMethod.Invoke (FInstance, Args);
SetLength (Args, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TRttiInvocation.SetParameter (Name : string; Value : TValue);

var
  Parameter : TRttiParameter;
  I : Integer;

begin
I := 1;
for Parameter in FMethod.GetParameters do
  begin
  if Parameter.Name = Name then
    FArgs [I] := Value;
  Inc (I);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TRttiInvocation.SetResult(const Value: TValue);

begin
FResult := Value;
end;

end.
