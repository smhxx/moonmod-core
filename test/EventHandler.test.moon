describe "EventHandler", ->

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/EventHandler.moon"

  before_each ->
    export nameOfEvent = nil
    export filter = -> true
    export badFilter = -> false
    export handler = EventHandler "nameOfEvent"

  describe ".new()", ->

    it "creates a global-scope function with the given event name", ->
      assert.is.function nameOfEvent

    it "takes on a given table of initial callbacks if provided", ->
      callbacks = { { fn: -> } }
      handler = EventHandler "nameOfEvent", callbacks
      assert.equals callbacks, handler.callbacks

    it "creates a unique empty table to hold its callbacks if one is not provided", ->
      assert.are.same { }, handler.callbacks
      assert.is.not.inherited handler, "callbacks"

  describe ":addCallback()", ->

    it "registers a callback function with the handler", ->
      callback = ->
      handler\addCallback filter, callback
      assert.are.same { :filter, fn: callback }, handler.callbacks[1]

    it "registers the function owner object if specified", ->
      owner = {
        callback: =>
      }
      handler\addCallback filter, owner.callback, owner
      assert.are.same { :filter, fn: owner.callback, :owner }, handler.callbacks[1]

    it "returns true if the callback was added successfully", ->
      callback = ->
      ret = handler\addCallback filter, callback
      assert.equals true, ret

    it "returns false if the callback was already registered", ->
      callback = ->
      handler\addCallback filter, callback
      ret = handler\addCallback filter, callback
      assert.equals false, ret

  describe ":removeCallback()", ->

    it "removes an already-registered callback function from the handler", ->
      callback1 = ->
      callback2 = ->
      handler\addCallback filter, callback1
      handler\addCallback filter, callback2
      handler\removeCallback callback1
      assert.are.same {{ :filter, fn: callback2 }}, handler.callbacks

    it "removes an already-registered callback (with an owner) from the handler", ->
      owner = {
        callback: =>
      }
      handler\addCallback filter, owner.callback, owner
      handler\removeCallback owner.callback, owner
      assert.are.same { }, handler.callbacks

    it "leaves the callback in place if the owner does not match", ->
      owner = { }
      notOwner = { }
      callback = =>
      handler\addCallback filter, callback, owner
      handler\removeCallback callback, notOwner
      assert.are.same {{ :filter, fn: callback, :owner }}, handler.callbacks

    it "leaves the callback in place if there is an owner but none is specifed", ->
      owner = {
        callback: =>
      }
      handler\addCallback filter, callback, owner
      handler\removeCallback callback
      assert.are.same {{ :filter, fn: callback, :owner }}, handler.callbacks

  describe ":processEvent()", ->

    it "invokes any callbacks whose associated filters return a truthy value", ->
      owner = {
        callback: spy.new =>
      }
      badOwner = {
        callback: spy.new =>
      }
      handler\addCallback badFilter, badOwner.callback, badOwner
      handler\addCallback filter, owner.callback, owner
      handler\processEvent!
      assert.spy(badOwner.callback).was.not.called!
      assert.spy(owner.callback).was.called!

    it "passes the event's arguments to any triggered callbacks", ->
      owner = {
        callback: spy.new =>
      }
      handler\addCallback filter, owner.callback, owner
      handler\processEvent 1, 2, "foo"
      assert.spy(owner.callback).was.called!
      assert.equals owner, owner.callback.calls[1].refs[1]
      assert.equals 1, owner.callback.calls[1].vals[2]
      assert.equals 2, owner.callback.calls[1].vals[3]
      assert.equals "foo", owner.callback.calls[1].vals[4]

    it "is called when the global function is invoked", ->
      call = spy.on handler, "processEvent"
      nameOfEvent!
      call\revert!
      assert.spy(call).was.called!
