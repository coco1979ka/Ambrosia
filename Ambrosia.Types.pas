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

unit Ambrosia.Types;

interface

uses
  SysUtils,
  Rtti,
  Generics.Collections;

{$SCOPEDENUMS ON}

type
  ERegistrationException = class (Exception);
  EResolutionException = class (Exception);
  ENoResolvableConstructorFound = class (Exception);
  EDependencyResolverException = class (Exception);

  TArguments = TDictionary<string, TValue>;

  TFilterPredicate = reference to function (RttiType : TRttiType) : Boolean;

  TLifestyleType = (  Transient,
                      Singleton,
                      PerThread,
                      Pooled,
                      Scoped,
                      Custom  );

implementation

end.
