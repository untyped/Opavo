package opavo.chat_pane

import opavo.base

type ChatPane.pane =
  { body : xhtml 
    channel : Session.channel(message) 
  }

// A chat pane is a UI element to display chat messages
ChatPane = {{
  make(user_name : string, send : message -> void) : ChatPane.pane = 
    {
      body =
      <div class="chat">
        <div id=#conversation/>
        <input id=#entry onnewline={_ -> post(user_name, Dom.get_value(#entry), send)} placeholder="Message" />
      </div>

      channel = Session.make({}, message_handler)
    }

  send(pane : ChatPane.pane, message : message) = Session.send(pane.channel, message)

  @private post(author : string, message : string, send : message -> void) =
    do Dom.transform([#conversation +<- <div class="me">{message}</div>])
    do send(~{author message})
    Dom.clear_value(#entry)

  @private message_handler(state, message : message) =
    line = <div class="them">{message.author}: <strong>{message.message}</strong></div>    
    do Dom.transform([#conversation +<- line])
    {unchanged}
}}
