getAllContainers = ->
  returns = { }
  for _, obj in ipairs getAllObjects!
    if obj.tag == "Deck" or obj.tag == "Bag"
      table.insert returns, obj
  returns

hasCard = (container, guid) ->
  Util.trueInTable container\getObjects!, (v) -> v.guid == guid

export retryCardPut = (...) ->
  Card.put ...

export Card = {
  find: (guid) ->
    if getObjectFromGUID guid
      return guid
    _, location = Util.trueInTable getAllContainers!, (v) -> hasCard v, guid
    return location.guid if location

  put: (guid, position, rotation, retry = true) ->
    location = Card.find guid
    if location
      object = getObjectFromGUID location
      if location == guid
        object\setPositionSmooth position
        object\setRotationSmooth rotation
      else
        object\takeObject { :guid, :position, :rotation }
    else if retry
      Timer.create {
        identifier: "Card.put " .. guid
        function_name: "retryCardPut"
        parameters: { guid, position, rotation, false }
      }

  isFaceDown: (guid) ->
    obj = getObjectFromGUID guid
    if obj
      rot = obj\getRotation!
      rot[3] > 90 and rot[3] < 270

  isFaceUp: (guid) ->
    obj = getObjectFromGUID guid
    if obj
      rot = obj\getRotation!
      rot[3] < 90 or rot[3] > 270
}
