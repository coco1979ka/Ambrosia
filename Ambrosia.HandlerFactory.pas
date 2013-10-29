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

unit Ambrosia.HandlerFactory;

interface

uses
  Ambrosia.Interfaces;

type
  TDefaultHandlerFactory = class (TInterfacedObject, IHandlerFactory)
    private
      FKernel : Pointer;
    function GetKernel: IKernelInternal;
    protected
      property Kernel : IKernelInternal read GetKernel;
    public
      constructor Create (Kernel : IKernelInternal);
      function IHandlerFactory.Create = CreateHandler;
      function CreateHandler (Model : TComponentModel) : IHandler;
  end;

implementation

uses
  Ambrosia.Handlers;

//--------------------------------------------------------------------------------------------------
// TDefaultHandlerFactory
//--------------------------------------------------------------------------------------------------

constructor TDefaultHandlerFactory.Create(Kernel: IKernelInternal);

begin
FKernel := Pointer (Kernel);
end;

function TDefaultHandlerFactory.CreateHandler (Model : TComponentModel): IHandler;

begin
Result := TDefaultHandler.Create (Model);
Result.Init(Kernel)
end;

//--------------------------------------------------------------------------------------------------

function TDefaultHandlerFactory.GetKernel: IKernelInternal;

begin
Result := IKernelInternal (FKernel);
end;

end.
