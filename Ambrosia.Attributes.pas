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

unit Ambrosia.Attributes;

interface

uses
  TypInfo,
  Ambrosia.Interfaces,
  Ambrosia.Interception,
  Ambrosia.BaseAttributes,
  Ambrosia.Types;

type
  SingletonAttribute = class sealed (TLifestyleAttribute)
    public
      constructor Create;
  end;

  TransientAttribute = class sealed (TLifestyleAttribute)
    public
      constructor Create;
  end;

  ScopedAttribute = class sealed (TLifestyleAttribute)
    public
      constructor Create;
  end;

  PerThreadAttribute = class sealed (TLifestyleAttribute)
    public
      constructor Create;
  end;

  InterceptorAttribute = class (TCustomAttribute)
    private
      FInterceptorReference : IReference<IInterceptor>;
    public
      constructor Create (InterceptorType : PTypeInfo); overload;
      constructor Create (InterceptorName : string); overload;
      property Interceptor : IReference<IInterceptor> read FInterceptorReference;
  end;



implementation

uses
  Ambrosia.InterceptorReference;

//--------------------------------------------------------------------------------------------------
// SingletonAttribute
//--------------------------------------------------------------------------------------------------

constructor SingletonAttribute.Create;

begin
inherited Create (TLifestyleType.Singleton);
end;

//--------------------------------------------------------------------------------------------------
// TransientAttribute
//--------------------------------------------------------------------------------------------------

constructor TransientAttribute.Create;

begin
inherited Create (TLifestyleType.Transient);
end;

//--------------------------------------------------------------------------------------------------
// ScopedAttribute
//--------------------------------------------------------------------------------------------------

constructor ScopedAttribute.Create;

begin
inherited Create (TLifestyleType.Scoped);
end;

//--------------------------------------------------------------------------------------------------
// PerThreadAttribute
//--------------------------------------------------------------------------------------------------

constructor PerThreadAttribute.Create;

begin
inherited Create (TLifestyleType.PerThread);
end;

//--------------------------------------------------------------------------------------------------
// InterceptorAttribute
//--------------------------------------------------------------------------------------------------

constructor InterceptorAttribute.Create(InterceptorType: PTypeInfo);

begin
FInterceptorReference := TInterceptorReference.Create (InterceptorType);
end;

//--------------------------------------------------------------------------------------------------

constructor InterceptorAttribute.Create (InterceptorName : string);

begin
FInterceptorReference := TInterceptorReference.Create (InterceptorName);
end;

end.
