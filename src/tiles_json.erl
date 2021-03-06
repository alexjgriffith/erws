-module(tiles_json).
-export([to_message/1,to_json/1,process/1,jtime/0]).
-record(message,{
          type :: binary(),
          body :: binary(),
          id   :: binary(),
          date :: pos_integer()
}).

to_json(Record = #message{}) ->
    Plist = lists:zip(record_info(fields,message),tl(tuple_to_list(Record))),
    Rlist = [ {atom_to_binary(T,unicode),R} ||{T,R}<-Plist],
    jiffy:encode({Rlist}).

to_message(EJSON) ->
    {Record} = jiffy:decode(EJSON),
    Plist = [ {binary_to_existing_atom(T,unicode),R}
              ||{T,R}<-Record],
    #message{type = proplists:get_value(type,Plist),
             body = proplists:get_value(body,Plist),
             id   = proplists:get_value(id,Plist),
             date = proplists:get_value(date,Plist)}.

process(Message = #message{type=_Type,id=_Id,body=Body})
  when _Type =:= <<"req_id">>  ->
    {text,Message#message{id=tiles_serve_id:get_id(Body)}};
process(Message = #message{type=_Type,id=_Id})
  when _Type =:= <<"createExplosion">> , _Id =/= <<>> ->
    tiles_bcast:send_message(Message),
    ok;
process(Message = #message{type=_Type,id=_Id})
  when _Type =:= <<"createBullet">> , _Id =/= <<>> ->
    tiles_bcast:send_message(Message),
    ok;
process(Message = #message{type=_Type,id=_Id})
  when _Type =:= <<"createBullet">> , _Id =/= <<>> ->
    tiles_bcast:send_message(Message),
    ok;
process(Message = #message{type=_Type,id=_Id})
  when _Type =:= <<"updatePlayerPos">> , _Id =/= <<>> ->
    tiles_bcast:send_message(Message),
    ok;

process(Message = #message{id=_Id}) when _Id =/= 0->
    Message#message{type= <<"error">>,body= <<"0: invalid message type.">>};
process(Message = #message{}) ->
    Message#message{type= <<"error">>,body= <<"1: ID =:= \"\".">>}.


jtime()->
    binary_to_integer(
      lists:foldl(fun(El,Col) ->
                          Asap=integer_to_binary(El) ,
                          <<Col/binary, Asap/binary>>
                  end,
                  <<>>,tuple_to_list(erlang:timestamp()))).
