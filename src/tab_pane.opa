package opavo.tab_pane

import opavo.base
import opavo.chat_pane

type TabPane.pane = 
 { body : xhtml
   channel : Session.channel(message)
 }

type TabPane.state =
 { active : option(ChatPane.pane)
   tabs : list(ChatPane.pane)
 }

TabPane = {{
    make() : TabPane.pane = 
      { body = <ul class="tabs"></ul>
        
        channel = Session.make({active = ~{none} tabs = []}, message_handler)
      }

    @private message_handler(state, message) =
}}
