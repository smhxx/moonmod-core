describe "Util", ->

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/Util.moon"

  describe ":getKeys()", ->

    before_each ->
      export data = { a: 16, b: 12, c: 10 }

    it "returns a table containing the original table's keys in no specific order", ->
      keys = Util.getKeys data
      assert.not.Nil Util.isInTable keys, "a"
      assert.not.Nil Util.isInTable keys, "b"
      assert.not.Nil Util.isInTable keys, "c"

  describe ":getValues()", ->

    before_each ->
      export data = { a: 16, b: 12, c: 10 }

    it "returns a table containing the original table's values in no specific order", ->
      values = Util.getValues data
      assert.not.Nil Util.isInTable values, 16
      assert.not.Nil Util.isInTable values, 12
      assert.not.Nil Util.isInTable values, 10

  describe ":isInTable()", ->

    before_each ->
      export data = { 16, 12, 10 }

    it "returns the index/value pair of the first appearance of the value in the table", ->
      index, value = Util.isInTable data, 12
      assert.equals 2, index
      assert.equals 12, value

    it "returns nil if the value does not appear in the table", ->
      index = Util.isInTable data, 19
      assert.is.Nil index

  describe ":trueInTable()", ->

    before_each ->
      export data = { 16, 12, 10 }

    it "returns an index/value pair of the first entry for which the lambda returns true", ->
      index, value = Util.trueInTable data, (v) -> v < 11
      assert.equals 3, index
      assert.equals 10, value

    it "returns nil if the lambda does not return true for any entry", ->
      index = Util.trueInTable data, (v) -> v > 20
      assert.is.Nil index
