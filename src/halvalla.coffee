###
# Halvalla -- bindings for element creation and expression via teact and teacup
###

###
# The oracle, a globally supplied object to this module has this signature
Examples of oracle -- the default is to do Teacup to HTML
  ReactDom = require 'react-dom'
  Oracle =
    summoner: React
    name: 'React'
    isValidElement: React.isValidElement
    Component: React.Component
    createElement: React.createElement
    conjurer: ReactDom.renderToString
  Mithril = require 'mithril'
  Oracle =
    name: 'Mithril'
    isValidElement: (c)->c.view?
    createElement: Mithril
    Component: {}

###
#teact = require '../src/teact.coffee'
{doctypes,elements,normalizeArray,mergeElements,allTags,escape,quote} = require '../src/html-tags'
teacup = require '../src/teacup.coffee'
#if we are using React as the master, it supplies a class, otherwise an empty class with an empty view
propertyName = 'props'
dummyComponent = class Component
   constructor:(tagName,properties={},@children...)->
     @[propertyName]=properties
     @children = @children[0] if @children.length ==1
     @tagName = tagName
     @
   view: ->
   render: ->

GreatEmptiness = class GreatEmptiness
  constructor: (instantiator,Oracle={})->
    defaultObject =
      isValidElement: (c)->c.view?
      name: 'great-emptiness'
      Component: dummyComponent
      createElement: (args...)-> new dummyComponent args...
      summoner: null
      getProp: (element)->element.attrs
      getName: (element)->element.tag
      conjurer: null
    # decorate this singleton with
    for key,value of Object.assign defaultObject, Oracle
      GreatEmptiness::[key] = value
    @teacup=new teacup instantiator,defaultObject
    @conjurer= @teacup.render.bind @teacup
    @
#
# global Oracle
#

#
class Halvalla
  oracle=null
  constructor: (Oracle=null)->
    @stack = null
    oracle = new GreatEmptiness @instantiator,Oracle
    propertyName = oracle.propertyName
  escape:escape
  quote:quote

  resetStack: (stack=null) ->
    previous = @stack
    @stack = stack
    return previous

  pureComponent: (contents) ->
    return ->
      previous = @.resetStack null
      children = contents.apply @, arguments
      stackHad=@resetStack previous
      stackHad.push result if stackHad.length == 0
      return stackHad

  instantiator: (funct,args...)=>
    previous = @resetStack []
    result=funct args...
    stackHad=@resetStack previous
    stackHad.push result if stackHad.length == 0
    return stackHad

  raw: (text)->
    unless text.toString
      throw new Error "raw allows text only: expected a string"
    if oracle.trust
      el = oracle.trust text
    else
      el = oracle.createElement 'text', dangerouslySetInnerHTML: __html: text.toString()
    @stack?.push el
    return el

  doctype: (type=5) ->
    @raw doctypes[type]

  oracle: ()-> oracle
  ie: (condition,contents)=>
    @crel 'ie',condition:condition,contents

  tag: (tagName,args...) =>
    unless tagName? && 'string'== typeof tagName
      throw new Error "HTML tag type is invalid: expected a string but got #{typeof tagName?}"
    {attrs, contents} = @normalizeArgs args
    children = contents
    if children?.splice
      el = oracle.createElement tagName, attrs, children...
    else
      el = oracle.createElement tagName, attrs, children
    allTags[tagName]= Halvalla::[tagName] = el

  bless: (component,itsName=null)->
    component = component.default if component.__esModule && component.default
    name = itsName || component.name
    allTags[name]= Halvalla::[name] = (args...) => @crel component, args...

  component: (func) ->
    (args...) =>
      {selector, attrs, contents} = @normalizeArgs(args)
      renderContents = (args...) =>
        args.unshift contents
        @renderContents.apply @, args
      func.apply @, [selector, attrs, renderContents]


  crelVoid: (tagName, args...) =>
    {attrs, contents} = @normalizeArgs args
    if contents.length > 0
      throw new Error "Element type is invalid: must not have content: #{tagName}"
    el = oracle.createElement tagName, attrs,null
    #debugger
    #console.log "CrelVoid created el=",el
    @stack?.push el
    return el

  crel: (tagName, args...) =>
    unless tagName?
      throw new Error "Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: #{tagName}"
    {attrs, contents} = @normalizeArgs args
    children = contents
    if children?.splice
      el = oracle.createElement tagName, attrs, children...
    else
      el = oracle.createElement tagName, attrs, children
    #debugger
    #console.log "Crel created el=",el
    @stack?.push el
    return el


  text: (s) ->
    return s unless s?.toString
    @stack?.push(s.toString())
    return s.toString()

  isSelector: (string) ->
    string.length > 1 and string.charAt(0) in ['#', '.']

  parseSelector: (selector) ->
    id = null
    classes = []
    for token in selector.split '.'
      token = token.trim()
      if id
        classes.push token
      else
        [klass, id] = token.split '#'
        classes.push token unless klass is ''
    return {id, classes}

  normalizeArgs: (args) ->
    attrs = {}
    selector = null
    contents = []
    for arg, index in args when arg?
      switch typeof arg
        when 'string'
          if index is 0 and @isSelector(arg)
            selector = arg
            parsedSelector = @parseSelector(arg)
          else
            contents.push arg
        when 'number', 'boolean'
          contents.push arg
        when 'function'
          #debugger
          if oracle.preInstantiate
            stuff = @instantiator arg
            stuff = normalizeArray stuff
            for x in stuff
              contents.push x
          else
            contents.push arg
        when 'object'
          if arg.constructor == Object
            attrs = arg
          arg = arg.default if arg.default && arg.__esModule
          if arg.constructor == Object and not oracle.isValidElement arg
            attrs = Object.keys(arg).reduce(
              (clone, key) -> clone[key] = arg[key]; clone
              {}
            )
          else if arg.length?
            for a in arg
              contents.push a if a
        else
          contents.push = arg

    if parsedSelector?
      {id, classes} = parsedSelector
      attrs.id = id if id?
      if classes?.length
        if attrs.class
          classes.push attrs.class
        attrs.class = classes.join(' ')
        if attrs.className
          classes.push attrs.className
        attrs.className = classes.join(' ')

    # Expand data attributes
    dataAttrs = attrs.data
    if typeof dataAttrs is 'object'
      delete attrs.data
      for k, v of dataAttrs
        attrs["data-#{k}"] = v
    contents = normalizeArray contents
    return {attrs, contents, selector}

  #
  # Plugins
  #
  use: (plugin) ->
    plugin @

  renderable: (stuff)=>
    return (args...) =>
      oracle.conjurer @instantiator stuff, args...
  #
  # rendering
  cede: (args...)->
    @render args...

  render: (node,rest...)->
    previous = @.resetStack null
    try
      structure = node rest...
    catch
      debugger
    @.resetStack previous
    oracle.conjurer structure
  #
  # Binding
  #
  tags: ->
    bound = {}
    boundMethodNames = [].concat(
      'bless cede component doctype escape ie normalizeArgs pureComponent oracle raw render renderable tag text use'.split(' ')
      mergeElements 'regular', 'obsolete', 'raw', 'void', 'obsolete_void', 'script','coffeescript','comment'
    )
    for method in boundMethodNames
      do (method) =>
        allTags[method]= bound[method] = (args...) =>
          if !@[method]
            throw "no method named #{method} in Halvalla"
          @[method].apply @, args


    # Define tag functions on the prototype for pretty stack traces
    for tagName in mergeElements 'regular', 'obsolete'
      do (tagName) ->
        allTags[tagName]= Halvalla::[tagName] = (args...) -> @crel tagName, args...

    for tagName in mergeElements 'raw'
      do (tagName) ->
        allTags[tagName]= Halvalla::[tagName] = (args...) -> @crel tagName, args...

    for tagName in mergeElements 'script','coffeescript','comment'
      do (tagName) ->
        allTags[tagName]= Halvalla::[tagName] = (args...) -> @crel tagName, args...

    #allTags['ie']= Halvalla::['ie'] = (args...) -> @ie args...

    for tagName in mergeElements 'void', 'obsolete_void'
      do (tagName) ->
        allTags[tagName]= Halvalla::[tagName] = (args...) -> @crelVoid tagName, args...
    return bound

if module?.exports
  module.exports = new Halvalla().tags()
  module.exports.Halvalla = Halvalla
else
  window.Halvalla = new Halvalla().tags()
  window.Halvalla.Halvalla = Halvalla
