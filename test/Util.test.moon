describe "Util", ->

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/Util.moon"

  before_each ->
    export table = { 16, 12, 10 }

  describe ":isInTable()", ->

    it "returns the index/value pair of the first appearance of the value in the table", ->
      index, value = Util.isInTable table, 12
      assert.equals 2, index
      assert.equals 12, value

    it "returns nil if the value does not appear in the table", ->
      index = Util.isInTable table, 19
      assert.is.Nil index

  describe ":trueInTable()", ->

    it "returns an index/value pair of the first entry for which the lambda returns true", ->
      index, value = Util.trueInTable table, (v) -> v < 11
      assert.equals 3, index
      assert.equals 10, value

    it "returns nil if the lambda does not return true for any entry", ->
      index = Util.trueInTable table, (v) -> v > 20
      assert.is.Nil index
