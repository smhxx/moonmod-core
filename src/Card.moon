getAllContainers = ->
  returns = { }
  for _, obj in ipairs getAllObjects!
    if obj.tag == "Deck" or obj.tag == "Bag"
      table.insert returns, obj
  returns

hasCard = (container, guid) ->
  for _, v in ipairs container\getObjects!
    return true if v.guid == guid
  false

export Card = {
  find: (guid) ->
    if getObjectFromGUID guid
      return guid
    for _, container in ipairs getAllContainers!
      if hasCard container, guid
        return container.guid
    return nil

  put: (guid, position, rotation) ->
    location = Card.find guid
    if location
      object = getObjectFromGUID location
      if location == guid
        object\setPositionSmooth position
        object\setRotationSmooth rotation
      else
        object\takeObject { :guid, :position, :rotation }

  isFaceDown: (guid) ->
    obj = getObjectFromGUID guid
    rot = obj\getRotation!
    rot[3] > 90 and rot[3] < 270

  isFaceUp: (guid) ->
    not Card.isFaceDown guid
}
