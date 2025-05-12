-module(user_store).
-export([init/0, get/1, put/2, delete/1, all/0, find_by_email/1]).

-define(DB, <<"myappdb">>).
-define(COLL, <<"users">>).

init() ->
    {ok, _} = application:ensure_all_started(mongodb),
    {ok, Conn} = mongo:connect([{host, "localhost"}, {port, 27017}]),
    put(conn, Conn),
    ok.

conn() ->
    get(conn).

put(Id, User) ->
    Document = maps:merge(#{<<"_id">> => Id}, User),
    mongo:save(conn(), ?DB, ?COLL, Document).

get(Id) ->
    mongo:find_one(conn(), ?DB, ?COLL, #{<<"_id">> => Id}).

delete(Id) ->
    mongo:delete(conn(), ?DB, ?COLL, #{<<"_id">> => Id}).

all() ->
    mongo:find_all(conn(), ?DB, ?COLL, #{}).

find_by_email(Email) ->
    mongo:find_all(conn(), ?DB, ?COLL, #{<<"email">> => Email}).