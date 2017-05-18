assert = require "luassert"
say = require "say"

export useDistMode = ->
  flag = false
  for i, v in pairs arg
    if v == "-Xhelper=--use-dist"
      flag = true
      break
  return flag

-- UTILITY FUNCTIONS
export use = (path, context) ->
  switch string.match path, ".*(%..*)$"
    when ".lua"
      export self = context
      (assert loadfile path)!
    when ".moon"
      export self = context
      (assert (require "moonscript").loadfile path)!

export dist = (dists) ->
  if useDistMode!
    dists!

export source = (sources) ->
  if not useDistMode!
    sources!

export inspect = (table, indent) ->
  if not table
    print "<nil>"
    return
  indent = indent or 0
  padLength = indent * 2
  if indent == 0 then print "{"
  for k, v in pairs table
    t = type v
    if t == "table" and not v.__class
      print (string.rep " ", padLength + 2) .. k .. ": {"
      inspect v, indent + 1
      print (string.rep " ", padLength + 2) .. "}"
    else
      val = nil
      switch t
        when "table"
          val = "<object> " .. v.__class.__name
        when "function"
          val = "<function>"
        when "boolean"
          val = v and "true" or "false"
        when "string"
          val = "\"" .. v .. "\""
        else
          val = v
      print (string.rep " ", padLength + 2) .. k .. ": " .. val
  if indent == 0 then print "}"

addAssertion = (name, definition, failPositive, failNegative) ->
  positiveKey = "assertion." .. name .. ".positive"
  negativeKey = "assertion." .. name .. ".negative"
  say\set positiveKey, failPositive
  say\set negativeKey, failNegative
  assert\register "assertion", name, definition, positiveKey, negativeKey

-- CUSTOM ASSERTIONS

-- "assert.is.of.class (class, object)"
is_of_class = (state, arguments) ->
  arguments[1] == arguments[2].__class

addAssertion "of_class", is_of_class,
  "Expected %s to be the class of %s.",
  "Expected %s not to be the class of %s."

-- "assert.are.about.equal (value1, value2)"
round = (number, place) ->
  multiplier = 10^(place or 0)
  math.floor(number * multiplier + 0.5) / multiplier

about_equal = (state, arguments) ->
  roundedArg1 = round(arguments[1], 8)
  roundedArg2 = round(arguments[2], 8)
  return roundedArg1 == roundedArg2

addAssertion "about_equal", about_equal,
  "Expected %s to be approximately equal to %s.",
  "Expected %s not to be approximately equal to %s."

-- "assert.is.a.table (reference)"
is_a_table = (state, arguments) ->
  (type arguments[1]) == "table"

addAssertion "a_table", is_a_table,
  "Expected %s to be a table, but it was not.",
  "Expected %s not to be a table, but it was one."

-- "assert.is.a.function (reference)"
is_a_function = (state, arguments) ->
  (type arguments[1]) == "function"

addAssertion "a_function", is_a_function,
  "Expected %s to be a function, but it was not.",
  "Expected %s not to be a function, but it was one."

-- "assert.is.inherited (object, property)"
is_inherited = (state, arguments) ->
  arguments[1][arguments[2]] == arguments[1].__class[arguments[2]]

addAssertion "inherited", is_inherited,
  "Expected %s to have inherited property %s from its class, but it did not.",
  "Expected %s not to have inherited property %s from its class, but it did."

-- "assert.contains.key (table)"
contains_key = (state, arguments) ->
  (type arguments[2]) == "table" and (type arguments[2][arguments[1]]) != nil

addAssertion "contains_key", contains_key,
  "Expected to find key %s in: \n%s",
  "Expected not to find key %s in: \n%s"

-- "assert.contains.value (table)"
contains_value = (state, arguments) ->
  if (type arguments[2]) != "table"
    return false
  for key, value in pairs arguments[2]
    if value == arguments[1]
      return true
  return false

addAssertion "contains_value", contains_value,
  "Expected to find value %s in: \n%s",
  "Expected not to find value %s in: \n%s"

-- "assert.has.method (name, object)"
has_method = (state, arguments) ->
  (type arguments[2]) == "table" and (type arguments[2][arguments[1]]) != "function"

addAssertion "method", has_method,
  "Expected to find a method called %s, but there was not one.",
  "Expected not to find a method called %s, but there was one."
