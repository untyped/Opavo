package opavo.base

// Basic type definitions and functions

// Types

type message = {author: string message: string}
              
type add = {user: user_id channel: Session.channel(message)}
type delete = {user: user_id}
type response = {user: user_id message: message}
type router_msg = add / delete / response
