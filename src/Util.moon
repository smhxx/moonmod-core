export Util = {
  isInTable: (table, value) ->
    for i, v in ipairs table
      return i, v if v == value

  trueInTable: (table, lambda) ->
    for i, v in ipairs table
      return i, v if lambda v
}
