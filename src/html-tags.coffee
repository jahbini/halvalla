#
# doctypes server-side 'only' -- client side only if you really, really know what you do
doctypes =
  'default': '<!DOCTYPE html>'
  '5': '<!DOCTYPE html>'
  'xml': '<?xml version="1.0" encoding="utf-8" ?>'
  'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
  '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
  'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
  'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
  'ce': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'

elements =
  # Valid HTML 5 elements requiring a closing tag.
  # Note: the `var` element is out for obvious reasons, please use `tag 'var' or crel 'var'.
  regular: 'a abbr address article aside audio b bdi bdo blockquote body button
 canvas caption cite code colgroup datalist dd del details dfn div dl dt em
 fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
 html i iframe ins kbd label legend li map mark menu meter nav noscript object
 ol optgroup option output p pre progress q rp rt ruby s samp section
 select small span strong sub summary sup table tbody td text textarea tfoot
 th thead time title tr u ul video'

  raw: 'style'

  script: 'script'
  coffeescript: 'coffeescript'
  comment: 'comment'

  # Valid self-closing HTML 5 elements.
  void: 'area base br col command embed hr img input keygen link meta param
 source track wbr'

  obsolete: 'applet acronym bgsound dir frameset noframes isindex listing
 nextid noembed plaintext rb strike xmp big blink center font marquee multicol
 nobr spacer tt'

  obsolete_void: 'basefont frame'

normalizeArray= (b)->
  #turn b to an array of non-empty elements. useful for making all children
  # look uniform as an array for subsequent iteration
  # 123 turns into [123], [bob,null,sue] turns into [bob,sue]
  # nullish input turns into []
  c=if b?.length then b else [b]
  return c if c.normalized?
  d = (v for v in c when v)
  Object.defineProperty d,'normalized',{value:true,enumerable: false}
  return d

# Create a unique list of element names merging the desired groups.
mergeElements = (args...) ->
  result = []
  for a in args
    for element in (elements[a] || a).split ' '
      result.push element unless element in result
  result

# utility pure functions

# Don't escape single quote (') because we always quote attributes with double quote (")
escape= (text) ->
  text.toString().replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')

quote= (value) ->
  "\"#{value}\""

module.exports=
  doctypes: doctypes
  elements: elements
  mergeElements: mergeElements
  normalizeArray: normalizeArray
  escape:escape
  quote:quote
  allTags:{}
