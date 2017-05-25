export Util = {
  getKeys: (data) ->
    ret = { }
    for k, _ in pairs data
      table.insert ret, k
    ret

  getValues: (data) ->
    ret = { }
    for _, v in pairs data
      table.insert ret, v
    ret

  isInTable: (table, value) ->
    for i, v in ipairs table
      return i, v if v == value

  trueInTable: (table, lambda) ->
    for i, v in ipairs table
      return i, v if lambda v
}
