export class Vector
  new: (data) =>
    @data = { }
    data and @setAll data

  @add: (v1, v2) ->
    newVector = Vector v1.data
    newVector\increment v2.data

  @subtract: (v1, v2) ->
    newVector = Vector v1.data
    newVector\decrement v2.data

  increment: (vector) =>
    @setAll vector, (k, v) -> @data[k] and @data[k] + v

  decrement: (vector) =>
    @setAll vector, (k, v) -> @data[k] and @data[k] - v

  scaleByVector: (vector) =>
    @setAll vector, (k, v) -> @data[k] and @data[k] * v

  scaleByFactor: (factor) =>
    @setAll @data, (k, v) -> v * factor

  magnitude: =>
    sumOfSquares = 0
    for k, v in pairs @data
      sumOfSquares += math.pow v, 2
    math.sqrt(sumOfSquares)

  setAll: (data, lambda) =>
    if data.__class == Vector
      data = data.data
    for k, v in pairs data
      @data[k] = not lambda and v or lambda k, v
    return @

  strip: (keys) =>
    ret = { }
    for i = 1, #keys
      ret[i] = @data[keys[i]]
    ret
