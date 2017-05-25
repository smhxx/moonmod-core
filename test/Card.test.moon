describe "Card", ->

  use "./test/mock/API.moon"

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/Util.moon"
    use "./src/Card.moon"

  class Object
    new: (@guid) =>
    setPositionSmooth: =>
    setRotationSmooth: =>
    getRotation: =>
      @rotation

  class Container
    new: (@tag, @guid) =>
      @objects = { }
    getObjects: =>
      @objects
    takeObject: =>

  before_each ->
    export api = ApiContext!
    export card = Object "123456"
    export deck = Container "Deck", "567890"
    export bag = Container "Bag", "654321"
    ApiContext.objects = { deck, bag }

  describe ".find()", ->

    it "returns the card's guid if it exists in the game world", ->
      table.insert ApiContext.objects, card
      assert.equals card.guid, Card.find card.guid

    it "returns the deck's guid if the card is in a Deck", ->
      table.insert ApiContext.objects[1].objects, card
      assert.equals deck.guid, Card.find card.guid

    it "returns the bag's guid if the card is in a Bag", ->
      table.insert ApiContext.objects[2].objects, card
      assert.equals bag.guid, Card.find card.guid

    it "returns nil if the card is not found at all", ->
      assert.is.Nil Card.find card.guid

  describe ".put()", ->

    before_each ->
      export position = { 0, 0, 0 }
      export rotation = { 0, 180, 0 }

    it "sets the card's position smoothly if it exists in the game world", ->
      table.insert ApiContext.objects, card
      call = spy.on card, "setPositionSmooth"
      Card.put card.guid, position, rotation
      call\revert!
      assert.spy(call).was.called!
      assert.equals card, call.calls[1].refs[1]
      assert.equals position, call.calls[1].refs[2]

    it "sets the card's rotation smoothly if it exists in the game world", ->
      table.insert ApiContext.objects, card
      call = spy.on card, "setRotationSmooth"
      Card.put card.guid, position, rotation
      call\revert!
      assert.spy(call).was.called!
      assert.equals card, call.calls[1].refs[1]
      assert.equals rotation, call.calls[1].refs[2]

    it "fetches the card from the container if the card is in one", ->
      table.insert deck.objects, card
      call = spy.on deck, "takeObject"
      Card.put card.guid, position, rotation
      call\revert!
      assert.spy(call).was.called!
      assert.equals deck, call.calls[1].refs[1]
      assert.are.same { guid: card.guid, :position, :rotation }, call.calls[1].vals[2]

    it "retries on the next frame if the card is not immediately found", ->
      -- This is in the spec due to strange behavior in the game when the
      -- second-to-last card is removed from a deck; the Deck entity is
      -- destroyed and, for one frame, there is no representation of the last
      -- remaining card ANYWHERE in the game world. As a failsafe, we wait for
      -- one frame and try again any time the named card cannot be found. If
      -- this fails, too, then the card REALLY doesn't exist.
      Timer.create = spy.new ->
      Card.put card.guid, position, rotation
      assert.spy(Timer.create).was.called!
      params = Timer.create.calls[1].vals[1]
      assert.equals "Card.put " .. card.guid, params.identifier
      assert.not.nil "retryCardPut", params.function_name
      assert.equals card.guid, params.parameters[1]
      assert.are.same position, params.parameters[2]
      assert.are.same rotation, params.parameters[3]
      assert.equals false, params.parameters[4]

    it "does not retry if the supplied retry parameter is false", ->
      Timer.create = spy.new ->
      Card.put card.guid, position, rotation, false
      assert.spy(Timer.create).was.not.called!

    it "is called with retry = false when retryCardPut is invoked", ->
      call = spy.on Card, "put"
      retryCardPut card.guid, position, rotation, false
      call\revert!
      assert.spy(call).was.called!
      assert.equals card.guid, call.calls[1].vals[1]
      assert.are.same position, call.calls[1].vals[2]
      assert.are.same rotation, call.calls[1].vals[3]
      assert.equals false, call.calls[1].vals[4]

  describe ".isFaceDown()", ->

    before_each ->
      table.insert ApiContext.objects, card

    it "returns true if the object's zRot is closer to 180 than to 0 or 360", ->
      card.rotation = { 0, 180, 192.7 }
      assert.equals true, Card.isFaceDown card.guid
      card.roattion = { 0, 180, 174.3 }
      assert.equals true, Card.isFaceDown card.guid

    it "returns false if the object's zRot is closer to 0 or 360 than to 180", ->
      card.rotation = { 0, 180, 34.2 }
      assert.equals false, Card.isFaceDown card.guid
      card.roattion = { 0, 180, 348.1 }
      assert.equals false, Card.isFaceDown card.guid

    it "fails gracefully if the card does not exist", ->
      ApiContext.objects = { }
      assert.no.error -> Card.isFaceDown card.guid
      assert.is.Nil Card.isFaceDown card.guid

  describe ".isFaceUp()", ->

    before_each ->
      table.insert ApiContext.objects, card

    it "returns true if the object's zRot is closer to 0 or 360 than to 180", ->
      card.rotation = { 0, 180, 34.2 }
      assert.equals true, Card.isFaceUp card.guid
      card.roattion = { 0, 180, 348.1 }
      assert.equals true, Card.isFaceUp card.guid

    it "returns false if the object's zRot is closer to 180 than to 0 or 360", ->
      card.rotation = { 0, 180, 192.7 }
      assert.equals false, Card.isFaceUp card.guid
      card.roattion = { 0, 180, 174.3 }
      assert.equals false, Card.isFaceUp card.guid

    it "fails gracefully if the card does not exist", ->
      ApiContext.objects = { }
      assert.no.error -> Card.isFaceUp card.guid
      assert.is.Nil Card.isFaceUp card.guid
