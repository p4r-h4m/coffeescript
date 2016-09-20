# Compilation
# -----------

# helper to assert that a string should fail compilation
cantCompile = (code) ->
  throws -> CoffeeScript.compile code


test "ensure that carriage returns don't break compilation on Windows", ->
  doesNotThrow -> CoffeeScript.compile 'one\r\ntwo', bare: on

test "#3089 - don't mutate passed in options to compile", ->
  opts = {}
  CoffeeScript.compile '1 + 1', opts
  ok !opts.scope 

test "--bare", ->
  eq -1, CoffeeScript.compile('x = y', bare: on).indexOf 'function'
  ok 'passed' is CoffeeScript.eval '"passed"', bare: on, filename: 'test'

test "header (#1778)", ->
  header = "// Generated by CoffeeScript #{CoffeeScript.VERSION}\n"
  eq 0, CoffeeScript.compile('x = y', header: on).indexOf header

test "header is disabled by default", ->
  header = "// Generated by CoffeeScript #{CoffeeScript.VERSION}\n"
  eq -1, CoffeeScript.compile('x = y').indexOf header

test "multiple generated references", ->
  a = {b: []}
  a.b[true] = -> this == a.b
  c = 0
  d = []
  ok a.b[0<++c<2] d...

test "splat on a line by itself is invalid", ->
  cantCompile "x 'a'\n...\n"

test "Issue 750", ->

  cantCompile 'f(->'

  cantCompile 'a = (break)'

  cantCompile 'a = (return 5 for item in list)'

  cantCompile 'a = (return 5 while condition)'

  cantCompile 'a = for x in y\n  return 5'

test "Issue #986: Unicode identifiers", ->
  λ = 5
  eq λ, 5

test "#2516: Unicode spaces should not be part of identifiers", ->
  a = (x) -> x * 2
  b = 3
  eq 6, a b # U+00A0 NO-BREAK SPACE
  eq 6, a b # U+1680 OGHAM SPACE MARK
  eq 6, a b # U+2000 EN QUAD
  eq 6, a b # U+2001 EM QUAD
  eq 6, a b # U+2002 EN SPACE
  eq 6, a b # U+2003 EM SPACE
  eq 6, a b # U+2004 THREE-PER-EM SPACE
  eq 6, a b # U+2005 FOUR-PER-EM SPACE
  eq 6, a b # U+2006 SIX-PER-EM SPACE
  eq 6, a b # U+2007 FIGURE SPACE
  eq 6, a b # U+2008 PUNCTUATION SPACE
  eq 6, a b # U+2009 THIN SPACE
  eq 6, a b # U+200A HAIR SPACE
  eq 6, a b # U+202F NARROW NO-BREAK SPACE
  eq 6, a b # U+205F MEDIUM MATHEMATICAL SPACE
  eq 6, a　b # U+3000 IDEOGRAPHIC SPACE

  # #3560: Non-breaking space (U+00A0) (before `'c'`)
  eq 5, {c: 5}[ 'c' ]

  # A line where every space in non-breaking
  eq 1 + 1, 2  

test "don't accidentally stringify keywords", ->
  ok (-> this == 'this')() is false

test "#1026: no if/else/else allowed", ->
  cantCompile '''
    if a
      b
    else
      c
    else
      d
  '''

test "#1050: no closing asterisk comments from within block comments", ->
  cantCompile "### */ ###"

test "#1273: escaping quotes at the end of heredocs", ->
  cantCompile '"""\\"""' # """\"""
  cantCompile '"""\\\\\\"""' # """\\\"""

test "#1106: __proto__ compilation", ->
  object = eq
  @["__proto__"] = true
  ok __proto__

test "reference named hasOwnProperty", ->
  CoffeeScript.compile 'hasOwnProperty = 0; a = 1'

test "#1055: invalid keys in real (but not work-product) objects", ->
  cantCompile "@key: value"

test "#1066: interpolated strings are not implicit functions", ->
  cantCompile '"int#{er}polated" arg'

test "#2846: while with empty body", ->
  CoffeeScript.compile 'while 1 then', {sourceMap: true}

test "#2944: implicit call with a regex argument", ->
  CoffeeScript.compile 'o[key] /regex/'

test "#3001: `own` shouldn't be allowed in a `for`-`in` loop", ->
  cantCompile "a for own b in c"

test "#2994: single-line `if` requires `then`", ->
  cantCompile "if b else x"
