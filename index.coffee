
crypto                    = require 'crypto'

#-----------------------------------------------------------------------------------------------------------
id_from_text = ( text, length, hash = 'sha1' ) ->
  ### Given a `text` and a `length`, return an ID with `length` hexadecimal digits (`[0-9a-f]`)—this is like
  `create_id`, but working on a text rather than a number of arbitrary values. The hash algorithm currently
  used is SHA-1, which returns 40 hex digits; it should be good enough for the task at hand and has the
  advantage of being widely implemented. ###
  ### TAINT should be a user option, or take 'good' algorithm universally available ###
  R = ( ( crypto.createHash hash ).update text, 'utf-8' ).digest 'hex'
  return if length? then R[ 0 ... length ] else R

text = ( require './permuted-index' )[ 'text' ]
# n = 1000
# urge "text length: #{text.length}"
# for hash in crypto.getHashes()
#   t0 = + new Date()
#   for idx in [ 0 .. n ]
#     try
#       id = @id_from_text text, 10, hash
#     catch error
#       warn error[ 'message' ]
#       break
#   t1 = + new Date()
#   dt = t1 - t0
#   debug '©BkVs0', hash, dt

#-----------------------------------------------------------------------------------------------------------
weak_maps_and_object_ids = ->
  last_oid  = 0
  oid_map   = new WeakMap()
  ID        = {}

  #---------------------------------------------------------------------------------------------------------
  ID._set = ( value, oid = null ) ->
    oid = ( last_oid += +1 ) unless oid?
    R   = "o##{oid}"
    oid_map.set value, R
    return R

  #---------------------------------------------------------------------------------------------------------
  ID.get = ( value ) ->
    return 'true'       if value is true
    return 'false'      if value is false
    return 'null'       if value is null
    return 'undefined'  if value is null
    switch type = CND.type_of value
      when 'jsnotanumber' then return 'nan'
      when 'number'       then return "n##{value}"
      when 'text'         then return "t##{id_from_text value, 12}"
      when 'jsinfinity'   then return ( if value > 0 then "+infinity" else "-infinity" )
    return R if ( R = oid_map.get value )?
    return @_set value

  debug '©cDOVp', CND.type_of 0 / 0
  #---------------------------------------------------------------------------------------------------------
  d = {}
  e = {}
  s = Symbol 'foo'
  help ID._set d
  help ID.get d
  help '+++', ID.get e
  help '+++', ID.get 'helo'
  help '+++', ID.get text
  help '+++', ID.get text.replace /.$/, '?'
  help '>>>', ID.get 42
  help '>>>', ID.get 42
  help '>>>', ID.get 1 / 0
  help '>>>', ID.get 0 / 0
  help '±±±', ID.get s
  help '±±±', ID.get Infinity
  help '±±±', ID.get -Infinity
  warn "running GC"
  gc()
  help '+++', ID.get e
  help '>>>', ID.get 42
  help '>>>', ID.get 42
  help '±±±', ID.get s
  help '±±±', ID.get u = Symbol 'foo'

  # t = Symbol.for 'foo'
  # console.log t
  # console.log t is s
  # console.log t is u


  # urge CND.type_of true
  # urge CND.type_of null
  # urge CND.type_of undefined
  # urge CND.type_of 42
  # urge CND.type_of 'String'
  # urge CND.type_of Symbol 'foo'



weak_maps_and_object_ids()
