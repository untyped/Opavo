// Embeddable Opa chat client/server

import stdlib.themes.bootstrap

type message = {author: string message: string}
                
@publish room = Network.cloud("room"): Network.network(message)

// Admin

admin_msg_handler(state, msg : message) = {unchanged}
admin_channel = Session.make({none}, admin_msg_handler)

admin_start() = <h1>Hi admin!</h1>

// User

post() = 
       text = Dom.get_value(#entry)
       message = {author="user" message=text}
       do Session.send(admin_channel, message)
       Dom.clear_value(#entry)

start() =
        <div class="container">
          <h1>What up dawg</h1>
          <div id=#conversation>
            <p>Nobody loves you</p>
          </div>
          <input id=#entry />
          <input type="button" value="Post"/>
        </div>

// Dispatch

dispatch =
         | {path = [] ...}  -> start()
         | {path = ["admin"] ...} -> admin_start()


server = Server.of_bundle([@static_include_directory("resources")])
server = Server.simple_dispatch(dispatch)

