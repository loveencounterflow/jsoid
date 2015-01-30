



############################################################################################################
crypto                    = require 'crypto'
util                      = require 'util'
is_number                 = util.isNumber
is_string                 = util.isString
help                      = debug = console.log

#-----------------------------------------------------------------------------------------------------------
id_from_text = ( text, length, hash = 'sha1' ) ->
  ### Given a `text` and a `length`, return an ID with `length` hexadecimal digits (`[0-9a-f]`)—this is like
  `create_id`, but working on a text rather than a number of arbitrary values. The hash algorithm currently
  used is SHA-1, which returns 40 hex digits; it should be good enough for the task at hand and has the
  advantage of being widely implemented. ###
  ### TAINT should be a user option, or take 'good' algorithm universally available ###
  R = ( ( crypto.createHash hash ).update text, 'utf-8' ).digest 'hex'
  return if length? then R[ 0 ... length ] else R

# #-----------------------------------------------------------------------------------------------------------
# ### Miller Device ###
# type_of = ( x ) -> Object::toString.call x

#-----------------------------------------------------------------------------------------------------------
@new_jsoid = new_jsoid = ( settings ) ->
  throw new Error "settings not yet supported" if settings?
  last_oid  = -1
  oid_map   = new WeakMap()
  R         = {}

  #---------------------------------------------------------------------------------------------------------
  set = ( value ) ->
    R = "o##{last_oid += +1}"
    oid_map.set value, R
    return R

  #---------------------------------------------------------------------------------------------------------
  R = ( value ) ->
    return 'true'       if value is true
    return 'false'      if value is false
    return 'null'       if value is null
    return 'undefined'  if value is undefined
    #.......................................................................................................
    if is_number value
      ### `isNan is broken as per
      https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/isNaN;
      however, we already know that `value` tests `true` for `util.isNumber`, so using `isNan` here should
      be alright. ###
      return 'nan' if isNaN value
      return ( if value > 0 then "+infinity" else "-infinity" ) unless isFinite value
      return "n##{value}"
    #.......................................................................................................
    return "t##{id_from_text value, 12}" if is_string value
    #.......................................................................................................
    return R if ( R = oid_map.get value )?
    return set value

  #---------------------------------------------------------------------------------------------------------
  return R

#-----------------------------------------------------------------------------------------------------------
test = ->
  jsoid = new_jsoid()
  #---------------------------------------------------------------------------------------------------------
  d = {}
  e = {}
  s = Symbol 'foo'
  throw new Error "test case #1 failed"  unless ( jsoid d                ) is 'o#0'
  throw new Error "test case #2 failed"  unless ( jsoid e                ) is 'o#1'
  throw new Error "test case #3 failed"  unless ( jsoid 'helo'           ) is 't#c6efaf27673d'
  throw new Error "test case #4 failed"  unless ( jsoid 'helo!'          ) is 't#8e95a23efc4e'
  throw new Error "test case #5 failed"  unless ( jsoid 42               ) is 'n#42'
  throw new Error "test case #6 failed"  unless ( jsoid 1e3              ) is 'n#1000'
  throw new Error "test case #7 failed"  unless ( jsoid 1e12             ) is 'n#1000000000000'
  throw new Error "test case #8 failed"  unless ( jsoid 42               ) is 'n#42'
  throw new Error "test case #9 failed"  unless ( jsoid 1 / 0            ) is '+infinity'
  throw new Error "test case #10 failed" unless ( jsoid 0 / 0            ) is 'nan'
  throw new Error "test case #11 failed" unless ( jsoid s                ) is 'o#2'
  throw new Error "test case #12 failed" unless ( jsoid Infinity         ) is '+infinity'
  throw new Error "test case #13 failed" unless ( jsoid -Infinity        ) is '-infinity'
  throw new Error "test case #14 failed" unless ( jsoid e                ) is 'o#1'
  throw new Error "test case #15 failed" unless ( jsoid 42               ) is 'n#42'
  throw new Error "test case #16 failed" unless ( jsoid 42               ) is 'n#42'
  throw new Error "test case #17 failed" unless ( jsoid s                ) is 'o#2'
  throw new Error "test case #18 failed" unless ( jsoid u = Symbol 'foo' ) is 'o#3'
  throw new Error "test case #18 failed" unless ( jsoid undefined        ) is 'undefined'


############################################################################################################
unless module.parent?
  test()


