describe "Vector", ->

  dist ->
    use "./dist/moonmod-core.lua"

  source ->
    use "./src/Vector.moon"

  before_each ->
    export data1 = { a: 2, b: 3, c: 6 }
    export data2 = { a: 2, b: -4, c: 0 }
    export data3 = { a: 2, b: -4, d: 6 }
    export dataSum = { a: 4, b: -1, c: 6 }
    export dataDiff = { a: 0, b: 7, c: 6 }
    export dataMult = { a: 4, b: -12, c: 0 }
    export dataTimes2 = { a: 4, b: 6, c: 12 }
    export magnitude = 7

  describe ":new()", ->

    it "accepts a table as starting data and creates a copy of it", ->
      vector = Vector data1
      assert.are.same data1, vector.data
      assert.not.equal data1, vector.data

    it "accepts a Vector as starting data and creates a copy of its data", ->
      vector1 = Vector data1
      vector2 = Vector vector1
      assert.are.same vector1.data, vector2.data
      assert.not.equal vector1.data, vector2.data

    it "creates an empty table if no starting data is provided", ->
      vector = Vector!
      assert.are.same { }, vector.data
      assert.is.not.inherited vector, "data"

  describe ".add()", ->

    it "creates a new Vector from the sum of two existing Vectors", ->
      vector1 = Vector data1
      vector2 = Vector data2
      vector3 = Vector.add vector1, vector2
      assert.are.same dataSum, vector3.data
      assert.are.not.equal vector1.data, vector3.data
      assert.are.not.equal vector2.data, vector3.data

  describe ".subtract()", ->

    it "creates a new Vector from the difference between two existing Vectors", ->
      vector1 = Vector data1
      vector2 = Vector data2
      vector3 = Vector.subtract vector1, vector2
      assert.are.same dataDiff, vector3.data
      assert.are.not.equal vector1.data, vector3.data
      assert.are.not.equal vector2.data, vector3.data

  describe ":increment()", ->

    it "adds the contents of a table to its existing data", ->
      vector = Vector data1
      vector\increment data2
      assert.are.same dataSum, vector.data

    it "adds the contents of a Vector to its existing data", ->
      vector1 = Vector data1
      vector2 = Vector data2
      vector1\increment vector2
      assert.are.same dataSum, vector1.data

    it "ignores keys not present in its own data", ->
      vector = Vector data1
      vector\increment data3
      assert.is.Nil vector.data.d

  describe ":decrement()", ->

    it "subtracts the contents of a table from its existing data", ->
      vector = Vector data1
      vector\decrement data2
      assert.are.same dataDiff, vector.data

    it "subtracts the contents of a Vector from its existing data", ->
      vector1 = Vector data1
      vector2 = Vector data2
      vector1\decrement vector2
      assert.are.same dataDiff, vector1.data

    it "ignores keys not present in its own data", ->
      vector = Vector data1
      vector\decrement data3
      assert.is.Nil vector.data.d

  describe ":scaleByVector()", ->

    it "multiplies its existing data by the contents of a table", ->
      vector = Vector data1
      vector\scaleByVector data2
      assert.are.same dataMult, vector.data

    it "multiplies its existing data by the contents of a Vector", ->
      vector1 = Vector data1
      vector2 = Vector data2
      vector1\scaleByVector vector2
      assert.are.same dataMult, vector1.data

    it "ignores keys not present in its own data", ->
      vector = Vector data1
      vector\scaleByVector data3
      assert.is.Nil vector.data.d

  describe ":scaleByFactor()", ->

    it "multiplies its existing data by a scalar value", ->
      vector = Vector data1
      vector\scaleByFactor 2
      assert.are.same dataTimes2, vector.data

  describe ":magnitude()", ->

    it "returns the magnitude of an n-dimensional vector defined by its values", ->
      vector = Vector data1
      assert.are.equal magnitude, vector\magnitude!

  describe ":setAll()", ->

    it "takes multiple values from a given input table", ->
      vector = Vector!
      vector\setAll data1
      assert.are.same data1, vector.data
      assert.not.equal data1, vector.data

    it "takes multiple values from a given inupt Vector", ->
      vector1 = Vector data1
      vector2 = Vector!
      vector2\setAll vector1
      assert.are.same vector1.data, vector2.data
      assert.not.equal vector1.data, vector2.data

    it "performs an optional lambda function on the data beforehand", ->
      vector = Vector!
      lambda = spy.new (k, v) -> 2 * v
      vector\setAll data1, lambda
      for k, v in pairs data1
        assert.spy(lambda).was.called.with k, v
      assert.are.same dataTimes2, vector.data

  describe ":strip()", ->

    it "creates a table of its own data, ordered according to the provided indices", ->
      vector = Vector data1
      assert.are.same { 6, 3, 2 }, vector\strip "c", "b", "a"
