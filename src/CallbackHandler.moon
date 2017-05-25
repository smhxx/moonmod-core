export class CallbackHandler
  new: (callbacks) =>
    @callbacks = callbacks or { }

  addCallback: (fn, owner) =>
    sameParams = (v) -> v.fn == fn and v.owner == owner
    if not Util.trueInTable @callbacks, sameParams
      table.insert @callbacks, { :fn, :owner }
      return true
    false

  removeCallback: (fn, owner) =>
    sameParams = (v) -> v.fn == fn and v.owner == owner
    i = Util.trueInTable @callbacks, sameParams
    if i
      table.remove @callbacks, i
      return true
    false

  triggerCallbacks: (...) =>
    for _, callback in ipairs @callbacks
      if callback.owner != nil
        callback.fn callback.owner, ...
      else
        callback.fn ...
