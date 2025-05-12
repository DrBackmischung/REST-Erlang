-module(login_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Data = jsx:decode(Body, [return_maps]),
    case cowboy_req:path(Req0) of
        <<"/registration">> ->
            handle_register(Data, Req1, State);
        <<"/login">> ->
            handle_login(Data, Req1, State)
    end.

handle_register(#{<<"email">> := Email, <<"password">> := Pass} = Data, Req, State) ->
    case user_store:find_by_email(Email) of
        [] ->
            Id = erlang:integer_to_binary(erlang:unique_integer([monotonic])),
            user_store:put(Id, maps:merge(Data, #{id => Id})),
            reply(201, #{message => <<"User registered">>, id => Id}, Req, State);
        _ ->
            reply(409, #{error => <<"Email already exists">>}, Req, State)
    end;

handle_login(#{<<"email">> := Email, <<"password">> := Pass}, Req, State) ->
    case user_store:find_by_email(Email) of
        [{_, #{<<"password">> := Pass} = User}] ->
            reply(200, #{message => <<"Login successful">>, user => User}, Req, State);
        _ ->
            reply(401, #{error => <<"Invalid credentials">>}, Req, State)
    end.

reply(Code, Json, Req, State) ->
    Resp = jsx:encode(Json),
    Req2 = cowboy_req:reply(Code, #{<<"content-type">> => <<"application/json">>}, Resp, Req),
    {ok, Req2, State}.