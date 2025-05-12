-module(user_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Path = cowboy_req:path_info(Req0),
    handle(Method, Path, Req0, State).

handle(<<"GET">>, [IdStr], Req0, State) ->
    case user_store:get(IdStr) of
        [] -> reply(404, #{error => <<"User not found">>}, Req0, State);
        [{_, User}] -> reply(200, User, Req0, State)
    end;

handle(<<"POST">>, [], Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    User = jsx:decode(Body, [return_maps]),
    Id = erlang:integer_to_binary(erlang:unique_integer([monotonic])),
    user_store:put(Id, maps:merge(#{id => Id}, User)),
    reply(201, #{message => <<"User created">>, id => Id}, Req1, State);

handle(<<"PUT">>, [Id], Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    User = jsx:decode(Body, [return_maps]),
    user_store:put(Id, maps:merge(#{id => Id}, User)),
    reply(200, #{message => <<"User updated">>}, Req1, State);

handle(<<"DELETE">>, [Id], Req0, State) ->
    user_store:delete(Id),
    reply(200, #{message => <<"User deleted">>}, Req0, State);

handle(_, _, Req0, State) ->
    reply(400, #{error => <<"Bad Request">>}, Req0, State).

reply(Code, Json, Req, State) ->
    Resp = jsx:encode(Json),
    Req2 = cowboy_req:reply(Code, #{<<"content-type">> => <<"application/json">>}, Resp, Req),
    {ok, Req2, State}.