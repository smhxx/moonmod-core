export class EventHandler
  new: (eventName, callbacks) =>
    @callbacks = callbacks or { }
    if (type eventName == "String")
      _G[eventName] = (...) ->
        @processEvent ...

  addCallback: (filter, fn, owner) =>
    sameParams = (v) -> v.filter == filter and v.fn == fn and v.owner == owner
    if not Util.trueInTable @callbacks, sameParams
      table.insert @callbacks, { :filter, :fn, :owner }
      return true
    false

  removeCallback: (fn, owner) =>
    sameParams = (v) -> v.fn == fn and v.owner == owner
    i = Util.trueInTable @callbacks, sameParams
    if i
      table.remove @callbacks, i
      return true
    false

  processEvent: (...) =>
    args = ...
    i, v = Util.trueInTable @callbacks, (v) -> v.filter args
    if i
      if v.owner
        v.fn v.owner, ...
      else
        v.fn ...
