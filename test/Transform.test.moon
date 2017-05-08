describe "Transform", ->

  source "./dist/moonmod-core.lua", ->
    use "./src/Vector.moon"
    use "./src/Transform.moon"

  before_each ->
    export posData = { x: 123, y: 456, z: 789 }
    export rotData = { x: 45, y: 90, z: 135 }
    export posData2 = { x: 22, y: -26, z: -49 }
    export rotData2 = { x: 45, y: -20, z: 25 }
    export position = Vector posData
    export rotation = Vector rotData
    export position2 = Vector posData2
    export rotation2 = Vector rotData2
    export posResult = Vector { x: 145, y: 430, z: 740 }
    export rotResult = Vector { x: 90, y: 70, z: 160 }
    export options = {
      xPos: posData.x
      yPos: posData.y
      zPos: posData.z
      xRot: rotData.x
      yRot: rotData.y
      zRot: rotData.z
    }
    export transform = Transform { :position, :rotation }

  describe ":new()", ->

    it "accepts its position and rotation as an existing Transform object", ->
      transform2 = Transform transform
      assert.are.same transform.position, transform2.position
      assert.are.same transform.rotation, transform2.rotation
      assert.not.equal transform.position, transform2.position
      assert.not.equal transform.rotation, transform2.rotation

    it "accepts its position and rotation as existing Vector objects", ->
      assert.are.same position, transform.position
      assert.are.same rotation, transform.rotation

    it "accepts its position and rotation as individual values", ->
      transform = Transform options
      assert.are.same position, transform.position
      assert.are.same rotation, transform.rotation

    it "assumes a default of 0 for all values", ->
      transform = Transform!
      assert.equals 0, transform.position.data.x
      assert.equals 0, transform.position.data.y
      assert.equals 0, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 0, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z

  describe ":translate()", ->

    it "accepts the amount to translate by as a table", ->
      transform\translate posData2
      assert.are.same posResult, transform.position

    it "accepts the amount to translate by as a Vector", ->
      transform\translate position2
      assert.are.same posResult, transform.position

  describe ":rotateLocally()", ->

    it "accepts the amount to rotate as a table", ->
      transform\rotateLocally rotData2
      assert.are.same rotResult, transform.rotation

    it "accepts the amount to rotate as a Vector", ->
      transform\rotateLocally rotation2
      assert.are.same rotResult, transform.rotation

    it "handles the overflow of rotations below 0 or above 360 degrees", ->
      for k, v in pairs transform.rotation.data
        transform.rotation.data[k] += 360
        rotData2[k] += 360
      transform\rotateLocally rotData2
      assert.are.same rotResult, transform.rotation

  describe ":rotateAboutXAxis()", ->

    before_each ->
      export transform = Transform { xPos: 2, zPos: 2 }

    it "rotates the entire transform (including position) about the X axis", ->
      transform\rotateAboutXAxis 90
      assert.about.equal 2, transform.position.data.x
      assert.about.equal -2, transform.position.data.y
      assert.about.equal 0, transform.position.data.z
      assert.equals 90, transform.rotation.data.x
      assert.equals 0, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z

    it "properly handles negative angles & angles over 360 degrees", ->
      transform\rotateAboutXAxis -180
      assert.about.equal 2, transform.position.data.x
      assert.about.equal 0, transform.position.data.y
      assert.about.equal -2, transform.position.data.z
      assert.equals 180, transform.rotation.data.x
      assert.equals 0, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z

  describe ":rotateAboutYAxis()", ->

    before_each ->
      export transform = Transform { xPos: 2, zPos: 2 }

    it "rotates the entire transform (including position) about the Y axis", ->
      transform = Transform { xPos: 2, zPos: 2 }
      transform\rotateAboutYAxis 45
      assert.about.equal 2 * (math.sqrt 2), transform.position.data.x
      assert.about.equal 0, transform.position.data.y
      assert.about.equal 0, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 45, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z

    it "properly handles negative angles & angles over 360 degrees", ->
      transform\rotateAboutYAxis 540
      assert.about.equal -2, transform.position.data.x
      assert.about.equal 0, transform.position.data.y
      assert.about.equal -2, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 180, transform.rotation.data.y
      assert.equals 0, transform.rotation.data.z

  describe ":rotateAboutZAxis()", ->

    before_each ->
      export transform = Transform { xPos: 2, zPos: 2 }

    it "rotates the entire transform (including position) about the Z axis", ->
      transform = Transform { xPos: 2, zPos: 2 }
      transform\rotateAboutZAxis 90
      assert.about.equal 0, transform.position.data.x
      assert.about.equal 2, transform.position.data.y
      assert.about.equal 2, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 0, transform.rotation.data.y
      assert.equals 90, transform.rotation.data.z

    it "properly handles negative angles & angles over 360 degrees", ->
      transform\rotateAboutZAxis -180
      assert.about.equal -2, transform.position.data.x
      assert.about.equal 0, transform.position.data.y
      assert.about.equal 2, transform.position.data.z
      assert.equals 0, transform.rotation.data.x
      assert.equals 0, transform.rotation.data.y
      assert.equals 180, transform.rotation.data.z

  describe ":normalizeRotation()", ->

    it "normalizes each element of the rotation as 0 <= theta < 360", ->
      for k, v in pairs transform.rotation.data
        transform.rotation.data[k] += 360
      transform\normalizeRotation!
      assert.are.same rotData, transform.rotation.data
