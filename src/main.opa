// Embeddable Opa chat client/server

import stdlib.themes.bootstrap

type message = {author: string message: string}
                
//@publish room = Network.cloud("room"): Network.network(message)

// Admin

admin_msg_handler(state, msg : message) = 
  line = <div>{msg.author}: {msg.message}</div>    
  do Debug.warning(msg.message)                   
  do Dom.transform([#conversation +<- line])
  {unchanged}

@publish admin_channel = Session.make({none}, admin_msg_handler)

@publish admin_start() = Resource.styled_page("Admin", [], <div class="container">
    <h1>Hi admin!</h1>
    <div id=#conversation>
      Text goes here!
    </div>
    <input id=#entry/>
    <input type="button" value="Post"/>
  </div>)

// User

post() = 
 text = Dom.get_value(#entry)
 message = {author="user" message=text}
 do Session.send(admin_channel, message)
 Dom.clear_value(#entry)

@publish start() = Resource.styled_page("Chat", [], <div class="container">
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

