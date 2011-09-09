// Embeddable Opa chat client/server

import stdlib.themes.bootstrap

type message = {author: string message: string}
              
type response = {recipient: string, message: message}
  
@publish admin_room = Network.cloud("admin_room"): Network.network(message)

// Admin

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
    <input id=#entry/>
    <input type="button" value="Post"/>
  </div>)

admin_start() = admin_page

// Routing

router_handler(table, msg: response) =
  {unchanged}

router_channel = Session.make({ users: Map(string, channel(response)) }, router_handler)

// User

post() = 
 text = Dom.get_value(#entry)
 message = {author="user" message=text}
 do Network.broadcast(message, admin_room)//Session.send(admin_channel, message)
 Dom.clear_value(#entry)

start() = Resource.styled_page("Chat", [], <div class="container">
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

