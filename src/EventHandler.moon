createCallback = (handler) ->
  return (...) ->
    handler\processEvent ...

export class EventHandler
  new: (eventName, callbacks) =>
    @callbacks = callbacks or { }
    if (type eventName == "String")
      _G[eventName] = createCallback @

  addCallback: (filter, fn, owner) =>
    for _, v in ipairs @callbacks
      if v.fn == fn and v.owner == owner
        return false
    table.insert @callbacks, { :filter, :fn, :owner }
    true

  removeCallback: (fn, owner) =>
    for i, v in ipairs @callbacks
      if v.fn == fn and v.owner == owner
        table.remove @callbacks, i
        return true
    false

  processEvent: (...) =>
    for _, v in ipairs @callbacks
      if v.filter ...
        if v.owner
          v.fn v.owner, ...
        else
          v.fn ...
