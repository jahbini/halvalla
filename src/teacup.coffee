
{doctypes,elements,mergeElements} = require '../src/html-tags'
module.exports = Teacup = class Teacup
  constructor: ->
    @htmlOut = null

  resetBuffer: (html=null) ->
    previous = @htmlOut
    @htmlOut = html
    return previous

  march: (component)->
    return '' unless component
    switch typeof component
      when 'string' then @text component
      when 'array' then @march c for c in component
      when 'object'
        tagName = component.tagName
        @text @[tagName] component
        return
      else
        debugger
        @text "bad component?"
        @text component.toString()
        return


  render: (component) ->
    previous = @resetBuffer('')
    try
      @march component
    finally
      result = @resetBuffer previous
    return result

  # alias render for coffeecup compatibility
  cede: (args...) -> @render(args...)

  renderable: (template) ->
    teacup = @
    return (args...) ->
      if teacup.htmlOut is null
        teacup.htmlOut = ''
        try
          template.apply @, args
        finally
          result = teacup.resetBuffer()
        return result
      else
        template.apply @, args

  renderAttr: (name, value) ->
    if not value?
      return " #{name}"

    if value is false
      return ''

    if name is 'data' and typeof value is 'object'
      return (@renderAttr "data-#{k}", v for k,v of value).join('')

    if value is true
      value = name

    return " #{name}=#{@quote @escape value.toString()}"

  attrOrder: ['id', 'class']
  renderAttrs: (obj) ->
    result = ''

    # render explicitly ordered attributes first
    for name in @attrOrder when name of obj
      result += @renderAttr name, obj[name]

    # then unordered attrs
    for name, value of obj
      continue if name in @attrOrder
      result += @renderAttr name, value

    return result

  renderContents: (contents, rest...) ->
    if not contents?
      return
    else if typeof contents is 'function'
      result = contents.apply @, rest
      @text result if typeof result is 'string'
    else
      @text contents


  tag: (cell) ->
    {tagName, props, children} = cell
    @raw "<#{tagName}#{@renderAttrs props}>"
    @march children
    @raw "</#{tagName}>"

  rawTag: (cell) ->
    {tagName, props, children} = cell
    @raw "<#{tagName}#{@renderAttrs props}>"
    @raw children
    @raw "</#{tagName}>"

  scriptTag: (cell) ->
    {tagName, props, children} = cell
    @raw "<#{tagName}#{@renderAttrs props}>"
    @renderContents children
    @raw "</#{tagName}>"


  selfClosingTag: (cell) ->
    {tagName, props, children} = cell
    if children
      throw new Error "Chalice: <#{tagName}/> must not have content.  Attempted to nest #{children}"
    @raw "<#{tagName}#{@renderAttrs props}/>"

  coffeescript: (fn) ->
    @raw """<script type="text/javascript">(function() {
      var __slice = [].slice,
          __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
          __hasProp = {}.hasOwnProperty,
          __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };
      (#{@escape fn.toString()})();
    })();</script>"""

  comment: (text) ->
    @raw "<!--#{@escape text}-->"

  doctype: (type=5) ->
    @raw doctypes[type]

  ie: (condition, contents) ->
    @raw "<!--[if #{@escape condition}]>"
    @renderContents contents
    @raw "<![endif]-->"

  text: (s) ->
    unless @htmlOut?
      throw new Error("Chalice: can't call a tag function outside a rendering context")
    @htmlOut += s? and @escape(s.toString()) or ''
    null

  raw: (s) ->
    return unless s?
    @htmlOut += s
    null

  #
  # Filters
  # return strings instead of appending to buffer
  #

  # Don't escape single quote (') because we always quote attributes with double quote (")
  escape: (text) ->
    text.toString().replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')

  quote: (value) ->
    "\"#{value}\""


  component: (func) ->
    (args...) =>
      {selector, attrs, contents} = @normalizeArgs(args)
      renderContents = (args...) =>
        args.unshift contents
        @renderContents.apply @, args
      func.apply @, [selector, attrs, renderContents]
# Define tag functions on the prototype for pretty stack traces
for tagName in mergeElements 'regular', 'obsolete'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @tag args...

for tagName in mergeElements 'raw'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @rawTag args...

for tagName in mergeElements 'script'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @scriptTag args...

for tagName in mergeElements 'void', 'obsolete_void'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @selfClosingTag args...
