// Embeddable Opa chat client/server

import stdlib.themes.bootstrap

type message = {author: string message: string}
              
//type user_id = string
type add = {user: user_id channel: Session.channel(message)}
type delete = {user: user_id}
type response = {user: user_id message: message}
type router_msg = add / delete / response

  
@publish admin_room = Network.cloud("admin_room"): Network.network(message)

// Admin

admin_post() = 
 text = Dom.get_value(#entry)
 message = {author="admin" message=text}
 do Session.send(router_channel, {user=user_id_of_string("newuser") message=message})
 Dom.clear_value(#entry)


admin_msg_handler(msg : message) = 
  line = <div>{msg.author}: {msg.message}</div>    
  do Debug.warning(msg.message)                   
  do Dom.transform([#conversation +<- line])
  {}

//@publish admin_channel = Session.make({none}, admin_msg_handler)

admin_page = Resource.styled_page("Admin", [], <div class="container">
    <h1>Hi admin!</h1>
    <div id=#conversation onready={_ -> Network.add_callback(admin_msg_handler, admin_room)}>
      Text goes here!
    </div>
    <input id=#entry onnewline={_ -> admin_post()} />
    <input type="button" value="Post" onclick={_ -> admin_post()}/>
  </div>)

admin_start() = admin_page

// Routing

router_handler(table: map(user_id, channel(message)), msg: router_msg) =
  new_table =
    match msg with
      | ~{user channel} -> Map.add(user, channel, table)
      | ~{user} -> Map.remove(user, table)
      | ~{user message} -> 
           do match Map.get(user, table) with
               | ~{some} -> Session.send(some, message)
               | ~{none} -> {}
           table
  {set = new_table}

router_channel = Session.make(Map.empty : map(user_id, channel(message)), router_handler)

// User

response_handler(state, msg: message) =
  line = <div>admin: {msg.message}</div>
  do Dom.transform([#conversation +<- line])
  {unchanged}

post() = 
 text = Dom.get_value(#entry)
 message = {author="user" message=text}
 do Network.broadcast(message, admin_room)//Session.send(admin_channel, message)
 Dom.clear_value(#entry)

start() =
  user_channel =  Session.make({}, response_handler)
  do Session.send(router_channel, {user = user_id_of_string("newuser") channel = user_channel}) 
  Resource.styled_page("Chat", [], <div class="container">
   <h1>What up dawg</h1>
   <div id=#conversation/>
   <input id=#entry onnewline={_ -> post()} />
   <input type="button" value="Post" onclick={_ -> post()}/>
   </div>)

// Dispatch

dispatch =
 | {path = [] ...}  -> start()
 | {path = ["admin"] ...} -> admin_start()
 | {path = _ ...} -> Resource.styled_page("Error", [], <p>These are not the droids you're looking for.</p>)


server = Server.of_bundle([@static_include_directory("resources")])
server = Server.simple_dispatch(dispatch)

