
{doctypes,elements,normalizeArray,mergeElements,allTags,escape,quote,BagMan} = require '../lib/html-tags'
module.exports = Teacup = class Teacup
  constructor: (@instantiator,@oracle)->
    @bagMan = new BagMan

  march: (bag)->
    while component = bag.inspect()
      console.log "March Teacup",component._Halvalla?.birthName || component.toString()
      switch n=component.constructor.name
        when 'Function' then bag.reinspect @instantiator component
        when 'String','Number' then bag.shipOut component.toString()
        when 'Array' then throw new Error 'invalid array from bagman'
        #render the node and append it to the htmlOout string
        else 
          #throw new Error "unclean component",component unless component._Halvalla
          tagName=@oracle.getName component
          if component.tag == '<'
            bag.shipOut @rawMithril component
          else if 'function' == typeof component.tagName
            #this component has not been instantiated yet
            tagConstructor = component.tagName
            if component.attrs
              attrs = component.attrs
            else
              attrs = component.props
            node = new tagConstructor tagName,attrs,component.children
            #console.log "newly instantiated node",node
            unless Teacup::[tagName]  #generate alias for stack dumps
              Teacup::[tagName]= (component, args...) -> @view component,args...
            bag.shipOut @view node
            break
          if @[tagName]
            bag.shipOut @[tagName] component
          else
            console.log "Component without teacup renderer: #{tagName}"
            if 'string' == typeof component.tag
              y= @tag component
            else 
              y= @view component
            bag.shipOut y
    return null          


  render: (component) ->
    oldBagger = @bagMan
    @bagMan = new BagMan
    @bagMan.context component
    @march @bagMan
    result = @bagMan.harvest().join ''
    @bagMan = oldBagger
    console.log "Final Render",result
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

    if name == 'style' && 'object' == typeof value
      return " #{name}=#{(@renderAttr n,v for k,v of value).join ' '}" 
      
    if name is 'data' and typeof value is 'object'
      return (@renderAttr "data-#{k}", v for k,v of value).join('')

    if value is true
      value = name
      
    return " #{name}=#{quote escape value.toString()}"

  attrOrder: ['id', 'class']
  renderAttrs: (obj) ->
    return '' unless obj
    if className=obj.class || obj.className
      obj.class = className
      delete obj.className 
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

  view: (cell) ->
    {children} = cell
    #console.log "VIEW",cell
    props=@oracle.getProp cell
    console.log "Teacup::tag Typeof props to render", typeof props
    result = ''
    if cell.tag?.view 
      x= cell.tag.view(props)
      result += @render x
    console.log "Teacup::view final result", result
    return result

  tag: (cell) ->
    {children} = cell
    console.log "CELL!",cell
    props=@oracle.getProp cell
    console.log "Teacup::tag Typeof props to render", typeof props
    tagName=@oracle.getName cell
    result = ''
    result += "<#{tagName}#{@renderAttrs props}>" unless tagName == 'text'
    console.log "Teacup::tag early result", result
    if cell.text
      result += cell.text
    else if props?.dangerouslySetInnerHTML
      result += props.dangerouslySetInnerHTML.__html
    else
      children = [ children ] if 'String' == children.constructor?.name || !children.length
      for child in children
        if 'String' == child.constructor?.name || 'string' == typeof child
          result += escape child.toString()
        else 
          result += @render child
        
    result += "</#{tagName}>" unless tagName == 'text'
    console.log "Teacup::tag final result", result
    return result


  rawMithril:(cell)->
    return cell.children

  rawTag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    result = "<#{tagName}#{@renderAttrs props}>"
    result += children
    result += "</#{tagName}>"
    return result

  scriptTag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    result = "<#{tagName}#{@renderAttrs props}>"
    result += children
    result += "</#{tagName}>"
    return result

  selfClosingTag: (cell) ->
    {children} = cell
    props=@oracle.getProp cell
    tagName=@oracle.getName cell
    if (normalizeArray children).length != 0
      throw new Error "Halvalla: <#{tagName}/> must not have content.  Attempted to nest #{children}"
    return "<#{tagName}#{@renderAttrs props} />"

  coffeescriptTag: (cell) ->
    fn = cell.children
    return """<script type="text/javascript">(function() {
      var __slice = [].slice,
          __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
          __hasProp = {}.hasOwnProperty,
          __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };
      (#{escape fn.toString()})();
    })();</script>"""

  commentTag: (text) ->
    return "<!--#{escape text.children}-->"

  doctypeTag: (type=5) ->
    return doctypes[type]

  ie: (cell)->
    props = @oracle.getProp cell
    result = "<!--[if #{escape props.condition}]>"
    result += @render cell.children
    result += "<![endif]-->"
    return result

  textOnly: (s) ->
    #console.log "text appends ",s? and escape(s.toString()) or ''
    return new String (s? and escape(s.toString()) or '')

# Define tag functions on the prototype for pretty stack traces
for tagName in mergeElements 'regular', 'obsolete'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @tag args...
Teacup::['<'] = (args...) -> @rawMithril args...
Teacup::['text'] = (args...) -> @tag args...

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

for tagName in 'ie'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @ie args...
    
for tagName in mergeElements 'void', 'obsolete_void'
  do (tagName) ->
    Teacup::[tagName] = (args...) -> @selfClosingTag args...
