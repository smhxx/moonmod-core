describe "Card", ->

  use "./test/mock/API.moon"

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/Card.moon"

  class Object
    new: (@guid) =>
    setPositionSmooth: =>
    setRotationSmooth: =>

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
