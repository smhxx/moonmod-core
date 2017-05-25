matrixMultiply = (rowData, colData) ->
  sum = 0
  for i, v in ipairs rowData
    sum += v * colData[i]
  sum

applyRotationMatrix = (matrix) =>
  rowData = @position\strip "x", "y", "z"
  @position.data = {
    x: matrixMultiply rowData, matrix[1]
    y: matrixMultiply rowData, matrix[2]
    z: matrixMultiply rowData, matrix[3]
  }

getRotationMatrix = (axis, degrees) ->
  radians = math.rad degrees
  sin = math.sin radians
  cos = math.cos radians
  if axis == "x"
    return {
      { 1, 0, 0 }
      { 0, cos, -sin }
      { 0, sin, cos }
    }
  if axis == "y"
    return {
      { cos, 0, sin }
      { 0, 1, 0 }
      { -sin, 0, cos }
    }
  if axis == "z"
    return {
      { cos, -sin, 0 }
      { sin, cos, 0 }
      { 0, 0, 1 }
    }

rotateAboutAxis = (axis, theta) =>
  matrix = getRotationMatrix axis, theta
  applyRotationMatrix @, matrix
  @rotation.data[axis] += theta
  @normalizeRotation!

export class Transform
  new: (options) =>
    options = options or { }
    if options.__class == Transform
      options = {
        position: Vector options.position
        rotation: Vector options.rotation
      }
    @position = options.position or
      Vector { x: options.xPos or 0, y: options.yPos or 0, z: options.zPos or 0 }
    @rotation = options.rotation or
      Vector { x: options.xRot or 0, y: options.yRot or 0, z: options.zRot or 0 }

  translate: (vector) =>
    @position\increment vector

  rotateLocally: (vector) =>
    @rotation\increment vector
    @normalizeRotation!

  rotateAboutXAxis: (theta) =>
    rotateAboutAxis @, "x", theta

  rotateAboutYAxis: (theta) =>
    rotateAboutAxis @, "y", theta

  rotateAboutZAxis: (theta) =>
    rotateAboutAxis @, "z", theta

  normalizeRotation: =>
    @rotation\setAll @rotation, (k, v) -> v % 360
