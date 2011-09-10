// Embeddable Opa chat client/server

import stdlib.themes.bootstrap

// Types

type message = {author: string message: string}
              
type add = {user: user_id channel: Session.channel(message)}
type delete = {user: user_id}
type response = {user: user_id message: message}
type router_msg = add / delete / response

// General


// Admin

@publish admin_room = Network.cloud("admin_room"): Network.network(message)

admin_post() = 
  user = Dom.get_value(#user_name)
  text = Dom.get_value(#entry)
  message = {author="admin" message=text}
  do Session.send(router_channel, {user=user_id_of_string(user) message=message})
  do Dom.transform([#conversation +<- <div>{text}</div>])
  Dom.clear_value(#entry)


admin_msg_handler(msg : message) = 
  line = <div>{msg.author}: <strong>{msg.message}</strong></div>    
  do Debug.warning(msg.message)                   
  do Dom.transform([#conversation +<- line])
  {}

//@publish admin_channel = Session.make({none}, admin_msg_handler)

admin_page = Resource.styled_page("Admin", [], <div class="container">
    <h1>Hi admin!</h1>
    <div id=#conversation onready={_ -> Network.add_callback(admin_msg_handler, admin_room)}>
      Text goes here!
    </div>
    <input id=#user_name placeholder="Recipient" />
    <input id=#entry onnewline={_ -> admin_post()} placeholder="Message" />
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

user_msg_handler(state, msg: message) =
  line = <div>admin: <strong>{msg.message}</strong></div>
  do Dom.transform([#conversation +<- line])
  {unchanged}

user_post(user) =
  text = Dom.get_value(#entry)
  message = {author=user message=text}
  do Dom.transform([#conversation +<- <div>{text}</div>])
  do Network.broadcast(message, admin_room)
  Dom.clear_value(#entry)

start() =
  user_name = Random.string(8)
  user_channel =  Session.make({}, user_msg_handler)
  do Session.send(router_channel, {user = user_id_of_string(user_name) channel = user_channel}) 
  Resource.styled_page("Chat", [], <div class="container">
   <h1>What up dawg?</h1>
   <div id=#conversation/>
   <input id=#entry onnewline={_ -> user_post(user_name)} placeholder="Message" />
   </div>)

// Dispatch

dispatch =
  | {path = [] ...}  -> start()
  | {path = ["admin"] ...} -> admin_start()
  | {path = _ ...} -> Resource.styled_page("Error", [], <p>These are not the droids you're looking for.</p>)


server = Server.of_bundle([@static_include_directory("resources")])
server = Server.simple_dispatch(dispatch)

