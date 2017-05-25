describe "CallbackHandler", ->

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/Util.moon"
    use "./src/CallbackHandler.moon"

  before_each ->
    export handler = CallbackHandler!

  describe ".new()", ->

    it "takes on a given table of initial callbacks if provided", ->
      callbacks = { { fn: -> } }
      handler = CallbackHandler callbacks
      assert.equals callbacks, handler.callbacks

    it "creates a unique empty table to hold its callbacks if one is not provided", ->
      assert.are.same { }, handler.callbacks
      assert.is.not.inherited handler, "callbacks"

  describe ":addCallback()", ->

    it "registers a callback function with the handler", ->
      callback = ->
      handler\addCallback callback
      assert.are.same { fn: callback }, handler.callbacks[1]

    it "registers the function owner object if specified", ->
      owner = {
        callback: =>
      }
      handler\addCallback owner.callback, owner
      assert.are.same { fn: owner.callback, :owner }, handler.callbacks[1]

    it "returns true if the callback was added successfully", ->
      callback = ->
      ret = handler\addCallback callback
      assert.equals true, ret

    it "returns false if the callback was already registered", ->
      callback = ->
      handler\addCallback callback
      ret = handler\addCallback callback
      assert.equals false, ret

  describe ":removeCallback()", ->

    it "removes an already-registered callback function from the handler", ->
      callback1 = ->
      callback2 = ->
      handler\addCallback callback1
      handler\addCallback callback2
      handler\removeCallback callback1
      assert.are.same {{ fn: callback2 }}, handler.callbacks

    it "removes an already-registered callback (with an owner) from the handler", ->
      owner = {
        callback: =>
      }
      handler\addCallback owner.callback, owner
      handler\removeCallback owner.callback, owner
      assert.are.same { }, handler.callbacks

    it "leaves the callback in place if the owner does not match", ->
      owner = { }
      notOwner = { }
      callback = =>
      handler\addCallback callback, owner
      handler\removeCallback callback, notOwner
      assert.are.same {{ fn: callback, :owner }}, handler.callbacks

    it "leaves the callback in place if there is an owner but none is specifed", ->
      owner = {
        callback: =>
      }
      handler\addCallback callback, owner
      handler\removeCallback callback
      assert.are.same {{ fn: callback, :owner }}, handler.callbacks

  describe ":triggerCallbacks()", ->

    it "calls each of the registered callbacks with the arguments provided", ->
      spy1 = spy.new ->
      spy2 = spy.new ->
      handler.callbacks = {{ fn: spy1 }, { fn: spy2 }}
      handler\triggerCallbacks "a", "b", "c"
      assert.spy(spy1).was.called!
      assert.equals "a", spy1.calls[1].vals[1]
      assert.equals "b", spy1.calls[1].vals[2]
      assert.equals "c", spy1.calls[1].vals[3]
      assert.spy(spy2).was.called!
      assert.equals "a", spy2.calls[1].vals[1]
      assert.equals "b", spy2.calls[1].vals[2]
      assert.equals "c", spy2.calls[1].vals[3]

    it "includes each callback owner's as the first argument, if it has one", ->
      unownedCallback = spy.new ->
      owner = {
        callback: spy.new =>
      }
      handler.callbacks = {{ fn: unownedCallback }, { fn: owner.callback, :owner }}
      handler\triggerCallbacks "a", "b", "c"
      assert.spy(unownedCallback).was.called!
      assert.equals "a", unownedCallback.calls[1].vals[1]
      assert.equals "b", unownedCallback.calls[1].vals[2]
      assert.equals "c", unownedCallback.calls[1].vals[3]
      assert.spy(owner.callback).was.called!
      assert.equals owner, owner.callback.calls[1].refs[1]
      assert.equals "a", owner.callback.calls[1].vals[2]
      assert.equals "b", owner.callback.calls[1].vals[3]
      assert.equals "c", owner.callback.calls[1].vals[4]
