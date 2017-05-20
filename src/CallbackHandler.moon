export class CallbackHandler
  new: (callbacks) =>
    @callbacks = callbacks or { }

  addCallback: (fn, owner) =>
    for _, v in ipairs @callbacks
      if v.fn == fn and v.owner == owner
        return false
    table.insert @callbacks, { :fn, :owner }
    true

  removeCallback: (fn, owner) =>
    for i, v in ipairs @callbacks
      if v.fn == fn and v.owner == owner
        table.remove @callbacks, i
        return true
    false

  triggerCallbacks: (...) =>
    for _, callback in ipairs @callbacks
      if callback.owner != nil
        callback.fn callback.owner, ...
      else
        callback.fn ...
