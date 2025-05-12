-module(myapp_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) ->
    user_store:init(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/user/[...]", user_handler, []},
            {"/login", login_handler, []},
            {"/registration", login_handler, [register]}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    myapp_sup:start_link().

stop(_State) ->
    ok.