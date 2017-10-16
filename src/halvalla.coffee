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
GreatEmptiness = null
dummyComponent = null
dummyElement = null

class Halvalla
  oracle=null
#
  constructor: (Oracle=null)->
    @stack = null
    GreatEmptiness = class GreatEmptiness
      constructor: (instantiator,Oracle={})->
        defaultObject =
          isValidElement: (c)->c.view?
          name: 'great-emptiness'
          Component: Oracle.Component || class Component
          Element: Oracle.Element || class Element
          createElement: (args...)-> new dummyElement args...
          summoner: null
          getProp: (element)->element.attrs
          getName: (element)->element._Halvalla?.tagName|| element.tag || element.type
          propertyName: 'attrs'
          conjurer: null
        # decorate this singleton with
        for key,value of Object.assign defaultObject, Oracle
          GreatEmptiness::[key] = value
        @teacup=new teacup instantiator,defaultObject
        @conjurer= @teacup.render.bind @teacup unless @conjurer
        @
    #
    oracle = new GreatEmptiness @instantiator,Oracle
    propertyName = oracle.propertyName
    dummyComponent = class Component extends oracle.Component
      constructor:(args...)->
        super args...
        @_Halvalla =
          propertyName:propertyName
          #children:@[properties].children
          #tagname: tagName[0].toLowerCase()+tagName.slice 1
        @

      render: ->

    dummyElement = class Element extends oracle.Component
      constructor:(tagName,properties={},@children...)->
        super tagName,properties,@children...
        @[propertyName]=properties
        @children = @children[0] if @children.length ==1
        @_Halvalla =
          tagName: tagName[0].toLowerCase()+tagName.slice 1
          propertyName:propertyName
          children:@[propertyName].children
        @
      view: ->

  mutator: (tagName,destination,withThis=null)=>
    allTags[tagName]= Halvalla::[tagName] = do ->
      (args...) -> destination tagName, args...
    allTags[tagName].Halvalla={tagName:tagName,boss:oracle.name}
    thing= allTags[tagName]
    return thing

# global Oracle
#
# bring in some pure utility text functions
  escape:escape

  quote:quote
  noDups:(newElement)->
    return newElement unless stack=@.stack
    stack.push newElement unless stack.length >0
    stack.push newElement unless newElement == stack[stack.length-1]
    return newElement

  resetStack: (stack=null) =>
    #console.log "STACK",@stack
    previous = @stack
    @stack = stack
    return previous

  pureComponent: (contents) ->
    return =>
      previous = @.resetStack []
      result = contents.apply @, arguments
      stackHad=@resetStack previous
      #console.log "Pure ", stackHad
      #console.log "WAS ",previous
      return stackHad

  raw: (text)->
    unless text.toString
      throw new Error "raw allows text only: expected a string"
    if oracle.trust
      el = oracle.trust text
    else
      el = oracle.createElement 'text', dangerouslySetInnerHTML: __html: text.toString()
    return @noDups el

  doctype: (type=5) ->
    @raw doctypes[type]

  ie: (condition,contents)=>
    @crel 'ie',condition:condition,contents

  tag: (tagName,args...) =>
    unless tagName? && 'string'== typeof tagName
      throw new Error "HTML tag type is invalid: expected a string but got #{typeof tagName?}"
    {attrs, contents} = @normalizeArgs args
    children = contents
    el = oracle.createElement tagName, attrs, children
    allTags[tagName]= Halvalla::[tagName] = el

  bless: (component,itsName=null)->
    component = component.default if component.__esModule && component.default
    name = itsName || component.name
    creator= (name,args...)=>
      y = oracle.createElement component,args...
      #console.log "newly instnce",y
      return y
    return @mutator name,creator,component

  renderContents: (contents, rest...) ->
    #for Teacup style signatures, we expect a single parameter-less function
    # we call it and it wil leave stuff on the 'stack'
    if not contents?
      return
    if typeof contents is 'function'
      contents = contents.apply @, rest
    if typeof contents is 'number'
      return @noDups contents
    if typeof contents is 'string'
      return @noDups contents
    if contents.length >0
      @stack.push contents...
    return

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
    return @noDups el

  crel: (tagName, args...) =>
    unless tagName?
      throw new Error "Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: #{tagName}"
    {attrs, contents} = @normalizeArgs args
    previous = @.resetStack []
    @march contents
    stackHad= @resetStack previous
    children = stackHad
    #if !children || children == [stackHad.slice -1][0]
    if children?.splice
      el = oracle.createElement tagName, attrs, children...
    else
      el = oracle.createElement tagName, attrs, children
    return @noDups el

  text: (s) ->
    return s unless s?.toString
    return @noDups s.toString()

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
    args = [args] if !args.length
    attrs = {}
    selector = null
    contents = null
    for arg, index in args when arg?
      switch typeof arg
        when 'string'
          if index is 0 and @isSelector(arg)
            selector = arg
            parsedSelector = @parseSelector(arg)
          else
            contents= arg
        when 'number', 'boolean'
          contents= arg
        when 'function'
          if oracle.preInstantiate
            stuff = @render arg
            stuff = normalizeArray stuff
            contents= stuff
          else
            contents= arg
        when 'object'
          if arg.constructor == Object
            attrs = arg
          arg = arg.default if arg.default && arg.__esModule
          if arg.constructor == Object and not oracle.isValidElement arg
            attrs = Object.keys(arg).reduce(
              (clone, key) -> clone[key] = arg[key]; clone
              {}
            )
          if arg.toString?() != '[object Object]'
            contents = arg.toString()
          else if arg.length?
            contents= arg
        else
          contents = arg

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
      oracle.conjurer @render stuff, args...
  #
  # rendering
  cede: (args...)->
    @render args...

  #liftedd from teacup renderer.  This side only does the instantiation
  march: (component)->
    return null unless (value=component?.toString())
    #console.log "March - component",component
    switch typeof component
      when 'function'
        # this is likeley a function outsode of halvalla,
        # 'we' all look like functions on the backbone and return null.
        # otherwise it's 'outside' and returns a result both are marchable
        # the exceptions are crel and crelVoid they do too much
        l = @stack.length
        result = component()
        @march result if l== @stack.length
        return null
      when 'string','number'
        return @noDups component
      when (Array.isArray component) && 'object'
        @march c for c in component
      when (value != '[object Object]') && 'object'
       return null
      when 'object'
        try
          tagName = oracle.getName component
          #console.log 'Tagname of March component type object',tagName
          if 'function' == typeof tagName
            #this component has not been instantiated yet
            tagConstructor = tagName
            tagName = tagConstructor.name
            if component.attrs
              attrs = component.attrs
            else
              attrs = component.props
            if tagName[0] != tagName[0].toLowerCase()
              tagName = tagName[0].toLowerCase()+tagName.slice 1
              #console.log "Activvating NEW"
              unless Halvalla::[tagName]  #generate alias for stack dumps
                Halvalla::[tagName]= (component, args...) -> @crel tagName,component,args...
              crell= @crel tagConstructor,attrs,component.props.children
              #console.log "calling crel A", crell
            else
              crell=@[tagName] args...
              #console.log "calling crel B", crell
            return null
            #@march node
          else
            #node has been instantiated and may be pushed to the output stack
            return @noDups component
        catch badDog
          console.error badDog
          debugger
          throw badDog
      else
        debugger
        throw new Error "bad component?",component
        return
    return

  render: (node,rest...)->
    previous = @.resetStack []
    try
      @march node rest...
    catch badDog
      debugger
      throw badDog
    structure= @.resetStack previous
    if previous != null
      debugger
      #console.log "Bad Previous"
      #throw new Error "Stack structure violation"
    @.resetStack()
    #console.log "Render Structure sent to oracle.conjurer",structure
    result = for element in structure
      switch typeof element
        when 'string','number'
          element = @crel 'text','', element

      #console.log "Render element sent to oracle.conjurer",element
      oracle.conjurer element
    #console.log "And it ends with a caboom",result
    return result.join ''
  #
  # Binding
  #
  tags: ->
    bound = {}
    bound.Oracle = oracle
    bound.Component = dummyComponent
    bound.Element = dummyElement
    boundMethodNames = [].concat(
      'bless cede component doctype escape ie normalizeArgs pureComponent raw render renderable tag text use'.split(' ')
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
      do (tagName) =>
        @mutator tagName,@crel

    for tagName in mergeElements 'raw'
      do (tagName) =>
        @mutator tagName,@crel

    for tagName in mergeElements 'script','coffeescript','comment'
      do (tagName) =>
        @mutator tagName,@crel

    #allTags['ie']= Halvalla::['ie'] = (args...) -> @ie args...

    for tagName in mergeElements 'void', 'obsolete_void'
      do (tagName) =>
        @mutator tagName,@crelVoid
    return bound

if module?.exports
  module.exports = new Halvalla().tags()
  module.exports.Halvalla = Halvalla
else
  window.Halvalla = new Halvalla().tags()
  window.Halvalla.Halvalla = Halvalla
