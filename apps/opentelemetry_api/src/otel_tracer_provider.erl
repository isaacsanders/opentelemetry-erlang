%%%------------------------------------------------------------------------
%% Copyright 2019, OpenTelemetry Authors
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% @doc This module defines the API for a TracerProvider. A TracerProvider
%% stores Tracer configuration and is how Tracers are accessed. An
%% implementation must be a `gen_server' that handles the API's calls. The
%% SDK should register a TracerProvider with the name `otel_tracer_provider'
%% which is used as the default global Provider.
%% @end
%%%-------------------------------------------------------------------------
-module(otel_tracer_provider).

-export([register_tracer/2,
         register_tracer/3,
         get_tracer/1,
         get_tracer/2,
         resource/0,
         resource/1,
         force_flush/0,
         force_flush/1]).

-spec register_tracer(atom(), binary()) -> boolean().
register_tracer(Name, Vsn) ->
    register_tracer(?MODULE, Name, Vsn).

-spec register_tracer(atom() | pid(), atom(), binary()) -> boolean().
register_tracer(ServerRef, Name, Vsn) ->
    try
        gen_server:call(ServerRef, {register_tracer, Name, Vsn})
    catch exit:{noproc, _} ->
            %% ignore register_tracer because no SDK has been included and started
            false
    end.

-spec get_tracer(opentelemetry:instrumentation_library()) -> opentelemetry:tracer() | undefined.
get_tracer(InstrumentationLibrary) ->
    get_tracer(?MODULE, InstrumentationLibrary).

-spec get_tracer(atom() | pid(), opentelemetry:instrumentation_library()) -> opentelemetry:tracer() | undefined.
get_tracer(ServerRef, InstrumentationLibrary) ->
    try
        gen_server:call(ServerRef, {get_tracer, InstrumentationLibrary})
    catch exit:{noproc, _} ->
            %% ignore because likely no SDK has been included and started
            {otel_tracer_noop, []}
    end.

-spec resource() -> term() | undefined.
resource() ->
    resource(?MODULE).

-spec resource(atom() | pid()) -> term() | undefined.
resource(ServerRef) ->
    try
        gen_server:call(ServerRef, resource)
    catch exit:{noproc, _} ->
            %% ignore because no SDK has been included and started
            undefined
    end.

-spec force_flush() -> ok | {error, term()} | timeout.
force_flush() ->
    force_flush(?MODULE).

-spec force_flush(atom() | pid()) -> ok | {error, term()} | timeout.
force_flush(ServerRef) ->
    try
        gen_server:call(ServerRef, force_flush)
    catch exit:{noproc, _} ->
            %% ignore because likely no SDK has been included and started
            ok
    end.
