
{doctypes,elements,normalizeArray,mergeElements,allTags,escape,quote} = require '../src/html-tags'
module.exports = Teacup = class Teacup
  constructor: (@instantiator,@oracle)->
    @htmlOut = null
    @functionOut = null

  resetFunctionBuffer: (html=null) ->
    previous = @functionOut
    @functionOut = html
    return previous

  resetBuffer: (html=null) ->
    previous = @htmlOut
    @htmlOut = html
    return previous

  march: (component)->
      return '' unless (value=component?.toString())
      switch typeof component
        when 'function' then @march @instantiator component
        when 'string','number' then @raw component.toString()
        when (Array.isArray component) && 'object'
          @march c for c in component
        when (value != '[object Object]') && 'object'
          @textOnly component
        when 'object'
          try
            tagName = @oracle.getName component
            if 'function' == typeof tagName
              #debugger
              #this component has not been instantiated yet
              tagConstructor = tagName
              tagName = tagConstructor.name
              if component.attrs
                attrs = component.attrs
              else
                attrs = component.props
              node = new tagConstructor tagName,attrs,component.children
              unless Teacup::[tagName]  #generate alias for stack dumps
                Teacup::[tagName]= (component, args...) -> @tag component,args...
              @march node
            else
              #node has been istantiated
              unless Teacup::[tagName]  #generate alias for stack dumps
                Teacup::[tagName]= (component, args...) -> @tag component,args...
              #render the node and append it to the htmlOout string
              @[tagName] component
          catch
            debugger
        else
          debugger
          @textOnly "bad component?"
          @textOnly component.toString()
          return
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
    return '' if name == 'className' # && !oracle.useClassName
    if not value?
      return " #{name}"

    if value is false
      return ''

    if name is 'data' and typeof value is 'object'
      return (@renderAttr "data-#{k}", v for k,v of value).join('')

    if value is true
      value = name

    return " #{name}=#{quote escape value.toString()}"

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
      @textOnly result if typeof result is 'string'
    else
      @textOnly contents


  tag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    @raw "<#{tagName}#{@renderAttrs props}>" unless tagName == 'text'
    if props.dangerouslySetInnerHTML
      @raw props.dangerouslySetInnerHTML.__html
    else
      @march children
    @raw "</#{tagName}>" unless tagName == 'text'

  rawTag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    @raw "<#{tagName}#{@renderAttrs props}>"
    @raw children
    @raw "</#{tagName}>"

  scriptTag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    @raw "<#{tagName}#{@renderAttrs props}>"
    @renderContents children
    @raw "</#{tagName}>"


  selfClosingTag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    if (normalizeArray children).length != 0
      throw new Error "Chalice: <#{tagName}/> must not have content.  Attempted to nest #{children}"
    @raw "<#{tagName}#{@renderAttrs props} />"

  coffeescriptTag: (cell) ->
    fn = cell.children
    @raw """<script type="text/javascript">(function() {
      var __slice = [].slice,
          __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
          __hasProp = {}.hasOwnProperty,
          __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };
      (#{escape fn.toString()})();
    })();</script>"""

  commentTag: (text) ->
    @raw "<!--#{escape text.children}-->"

  doctypeTag: (type=5) ->
    @raw doctypes[type]

  ie: (cell)->
    @raw "<!--[if #{escape cell.props.condition}]>"
    @march cell.children
    @raw "<![endif]-->"

  textOnly: (s) ->
    unless @htmlOut?
      throw new Error("Chalice: can't call a tag function outside a rendering context")
    @htmlOut += s? and escape(s.toString()) or ''
    #console.log "text appends ",s? and escape(s.toString()) or ''
    null

  raw: (s) ->
    return unless s?
    @htmlOut += s
    #console.log "raw appends ",s? and escape(s.toString()) or ''
    null

# Define tag functions on the prototype for pretty stack traces
for tagName in mergeElements 'regular', 'obsolete'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @tag args...

for tagName in mergeElements 'raw'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @rawTag args...

for tagName in mergeElements 'coffeescript'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @coffeescriptTag args...

for tagName in mergeElements 'comment'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @commentTag args...

for tagName in mergeElements 'script'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @scriptTag args...

for tagName in mergeElements 'void', 'obsolete_void'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @selfClosingTag args...
