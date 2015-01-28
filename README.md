

- [jsoid](#jsoid)
	- [Motivation](#motivation)
	- [Usage](#usage)
	- [Source](#source)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsoid

`jsoid` provides unique Object IDs for NodeJS (io.js at this time, really).

## Motivation

When comparing classical JavaScript to a language like Python, there are (among many others)
two things that JavaScript lacks and for which workarounds are sometimes necessary:

* Classical JS has no concept of a 'unique Object ID' (OID).
* Classical JS has no true Maps; you only get objects which accept strings as keys;
* Classical JS has no Weak Maps, meaning when you have to cache objects, you must
	always make sure to appropriately clear the cache when objects get out of scope.
* Because classical JS has only strings as keys, there are quite a few opportunities for
	key collsions in case you're not careful (i.e. `x[ '123' ]` shadows `x[ 123 ]`,
	`x[ 'NaN' ] shadows `x[ 0 / 0 ]` and so on).
* Because classical JS has only strings as keys, it is somewhat hard to tack private attributes
	such as `x.__FOOBAR_ID` to objects; in the general case, you should make those keys
	non-iterable in the general case (which has only been possible at all for a few years).
* Because classical JS has no OIDs, it is hard to efficiently look into a given cache or somesuch
	collection for the existence of a given object; an easy way to achieve that is to put
	everything in an array and then query for `cache.indexOf( x )`, but that isn't bound to scale
	very well (and is prone to leak memory).

All this has quite recently changed; for NodeJS people, the most obvious change is
the release of [io.js](https://iojs.org/) in January 2015, which out-of-the box provides
ES6 Symbols, Maps, Sets, WeakMaps, generators / `yield`, you name it.

> For a quick-and-easy instruction how to install the latest `iojs` binaries on your
> machine, have a look at my [how-to](https://github.com/loveencounterflow/how-to).

It turns out that Symbols, Maps, Sets, WeakMaps have some amount of overlap in their
features that make all of the above tasks a lot easier, including a tiny, pure-JS
implementation of OIDs, which is all that `jsoid` is there for.

## Usage

Install as `npm install --save jsoid`.

Be aware that this is not a mature module; i just slapped something together that seems
to work with a tiny test (run `node --harmony jsoid.js` or, better still, `iojs jsoid.js`;
if you get no output, the tests have passed).

From with your module, use

```js
var jsoid = require( 'jsoid' )();
var d = {};
var e = {};
console.log( jsoid( d ) );
console.log( jsoid( e ) );
console.log( jsoid( 42 ) );
console.log( jsoid( 42 ) );
console.log( jsoid( 'helo' ) );
console.log( jsoid( 'helo!' ) );
```

to see the generated OIDs; you should get something like:

```js
o#0
o#1
n#42
n#42
t#c6efaf27673d
t#8e95a23efc4e
```

Basically, that's a running ID for objects, and some kind of stringification for
primitive values. Ah yes, and the IDs are all (short) strings, because with the
more traditional numerical IDs, it's obviously logically impossible to represent all
of JS numbers and all the other possible values uniquely; only strings can do that, and
only strings can act as object keys, so there's an added value there.

As it stands, each call to `require( 'jsoid' )` will return a new
instance of a OID-generating function; that function will generated unqiue IDs that
are consistent with the IDs of all other instances of the `jsoid` function, but
since a simple counter is used in the case of objects, you must make sure to use only
one and the same `jsoid` function for all your IDs. I'm willing to look into ways to fix that,
but that may not be worthwhile: when you can transfer an object from one point of
your application to another point, you can also transfer the `jsoid` function. All
other solutions are mosre cumbersome.

## Source

The source is so short it fits into the readme:

```coffee
@new_jsoid = new_jsoid = ( settings ) ->
  throw new Error "settings not yet supported" if settings?
  last_oid  = -1
  oid_map   = new WeakMap()
  R         = {}

  set = ( value ) ->
    R = "o##{last_oid += +1}"
    oid_map.set value, R
    return R

  R = ( value ) ->
    return 'true'       if value is true
    return 'false'      if value is false
    return 'null'       if value is null
    return 'undefined'  if value is null
    if is_number value
      return 'nan' if isNaN value
      return ( if value > 0 then "+infinity" else "-infinity" ) unless isFinite value
      return "n##{value}"
    return "t##{id_from_text value, 12}" if is_string value
    return R if ( R = oid_map.get value )?
    return set value

  return R
```



