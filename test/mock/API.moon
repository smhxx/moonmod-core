assert = require "luassert"

-- This class mocks select methods from the TTS "Object" API, represented by the
-- global "self" in an object script. It contains *only* the Object-bound API
-- functions; the general API functions are exported separately (since they can
-- be called bare without having access to the Object context.) To prevent
-- cross-contamination between unit tests, only one instance of ApiContext can
-- be active at a time.
export class ApiContext
  new: =>
    @@instance = @
    @@objects = { }
    @@players = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
    @buttons = { }
    @scale = 1
    @position = { 0, 0, 0 }
    @rotation = { 0, 0, 0 }
    @coroutines = { }

  clearButtons: ->
    if ApiContext.instance != nil
      ApiContext.instance.buttons = { }
    return true

  createButton: (params) ->
    assert params != nil,
      "Mock API: Tried to call API.createButton with bad argument: params is nil!"
    assert type(params) == "table",
      "Mock API: Tried to call API.createButton with bad argument: params is not a table!"
    -- The actual in-game API will throw an error if the click_function is nil
    -- or an empty string, so we have to make sure that it's specified.
    assert params.click_function != nil,
      "Mock API: Tried to create button but no click_function was specified."
    assert type(params.click_function) == "string",
      "Mock API: Tried to create button but the click_function was not a string."
    assert params.click_function != "",
      "Mock API: Tried to create button but the click_function was an empty string."
    params.index = #ApiContext.instance.buttons
    ApiContext.instance.buttons[params.index + 1] = params
    return true

  editButton: (params) ->
    assert params != nil,
      "Mock API: Tried to call API.editButton with bad argument: params is nil!"
    assert type(params) == "table",
      "Mock API: Tried to call API.editButton with bad argument: params is not a table!"
    assert params.index != nil,
      "Mock API: Tried to call API.editButton with bad argument: params.index is nil!"
    assert type(params.index) == "number",
      "Mock API: Tried to call API.editButton with bad argument: params.index not a number!"
    assert ApiContext.instance.buttons[params.index + 1] != nil,
      "Mock API: Tried to call API.editButton with bad argument: there is no button with index " .. params.index .. "!"
    ApiContext.instance.buttons[params.index + 1] = params
    return true

  getButtons: ->
    newTable = { }
    for key, value in pairs(ApiContext.instance.buttons)
      newTable[key] = value
    return newTable

  removeButton: (index) ->
    assert index != nil,
      "Mock API: Tried to call API.removeButton with bad argument: index is nil!"
    assert type(index) == "number",
      "Mock API: Tried to call API.removeButton with bad argument: index not a number!"
    assert ApiContext.instance.buttons[index + 1] != nil,
      "Mock API: Tried to call API.removeButton with bad argument: button does not exist!"
    table.remove ApiContext.instance.buttons, index + 1
    return true

  getScale: =>
    scale = ApiContext.instance.scale
    { x: scale, y: scale, z: scale }

  setPosition: (position) ->
    assert position != nil,
      "Tried to call API.setPosition with bad argument: position is nil!"
    assert type(position) == "table",
      "Tried to call API.setPosition with bad argument: position is not a table!"
    assert #position <= 3,
      "Tried to call API.setPosition with bad argument: too many values!"
    assert type(position[1]) == "number",
      "Tried to call API.setPosition with bad x value!"
    assert type(position[2]) == "number",
      "Tried to call API.setPosition with bad y value!"
    assert type(position[3]) == "number",
      "Tried to call API.setPosition with bad z value!"
    ApiContext.instance.position = position
    return true

  setRotation: (rotation) ->
    assert rotation != nil,
      "Tried to call API.setRotation with bad argument: rotation is nil!"
    assert type(rotation) == "table",
      "Tried to call API.setRotation with bad argument: rotation is not a table!"
    assert #rotation <= 3,
      "Tried to call API.setRotation with bad argument: too many values!"
    assert type(rotation[1]) == "number",
      "Tried to call API.setRotation with bad x value!"
    assert type(rotation[2]) == "number",
      "Tried to call API.setRotation with bad y value!"
    assert type(rotation[3]) == "number",
      "Tried to call API.setRotation with bad z value!"
    ApiContext.instance.rotation = rotation
    return true

  destruct: ->
    ApiContext.instance = nil
    return true

-- The following API calls are not part of the context object, because they are
-- not part of the Object API, but rather the global API. (i.e. they are not
-- called using "self")
export JSON = {

}

export Player = {
  
}

export Timer = {

}

export getObjectFromGUID = (guid) ->
  for _, v in ipairs ApiContext.objects
    if v == guid
      return { }
    else if (type v) == "table" and v.guid == guid
      return v
  nil

export getAllObjects = ->
  return ApiContext.objects

export getSeatedPlayers = ->
  return ApiContext.players

export startLuaCoroutine = (context, name) ->
  table.insert ApiContext.instance.coroutines, { :context, :name }

-- Set up an initial instance automatically to avoid errors
ApiContext!
