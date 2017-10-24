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
{doctypes,elements,normalizeArray,mergeElements,allTags,escape,quote,BagMan} = require '../lib/html-tags'
teacup = require '../lib/teacup'
#if we are using React as the master, it supplies a class, otherwise an empty class with an empty view
propertyName = 'props'
GreatEmptiness = null
dummyComponent = null
dummyElement = null

class Halvalla
  oracle=null
#
  constructor: (Oracle=null)->
    @bagMan = new BagMan
    GreatEmptiness = class GreatEmptiness
      constructor: (instantiator,Oracle={})->
        defaultObject =
          isValidElement: (c)->c.view?
          name:  Oracle.name || 'great-emptiness'
          Component: Oracle.Component || class Component
          Element: Oracle.Element || class Element
          createElement: (args...)-> new dummyElement args...
          summoner: null
          getChildren: (element)->element.children
          getProp: (element)->element.attrs
          getName: (element)->element.type||element._Halvalla?.tagName|| element.tagName
          propertyName: 'attrs'
          conjurer: null
        # decorate this singleton with
        for key,value of Object.assign defaultObject, Oracle
          GreatEmptiness::[key] = value
        @teacup=new teacup instantiator,defaultObject
        @conjurer= @teacup.render.bind @teacup unless @conjurer
        @
    #
    oracle = new GreatEmptiness ((component)=>@create component),Oracle
    propertyName = oracle.propertyName
    dummyComponent = class Component extends oracle.Component
      constructor:(tagName,properties,children...)->
        super properties,children...
        @tagName=tagName
        @[propertyName] = properties unless @[propertyName]
        @children = @render
        @_Halvalla =
          propertyName:propertyName
          children:@render
          tagname: tagName[0].toLowerCase()+tagName.slice 1
        return @

      render: ->

    dummyElement = class Element extends oracle.Component
      constructor:(tagName,properties={},@children...)->
        super properties,@children...
        @tagName=tagName
        @[propertyName]=properties
        @children = @children[0] if @children.length ==1
        if typeof tagName == 'function'
          name = tagName.name
        else name = tagName
        @_Halvalla =
         
          tagName: name[0].toLowerCase()+name.slice 1
          propertyName:propertyName
          children:@[propertyName].children
        @
      view: ->

  mutator: (tagName,destination,withThis=null)->
    do (tagName)=>
      Halvalla::[tagName] = (args...) => destination.apply @, [tagName].concat args
    thing= Halvalla::[tagName]
    thing.Halvalla={tagName:tagName,boss:oracle.name}
    allTags[tagName] = thing
    return thing

# global Oracle
#
# bring in some pure utility text functions
  escape:escape

  quote:quote


  pureComponent: (contents) ->
    return =>
      @bagMan.context []
      @bagMan.shipOut contents.apply @, arguments
      stackHad=@bagMan.harvest()
      #console.log "Pure ", st
      #console.log "WAS ",previous
      return stackHad

  raw: (text)->
    unless text.toString
      throw new Error "raw allows text only: expected a string"
    if oracle.trust
      el = oracle.trust text
    else
      el = oracle.createElement 'text', dangerouslySetInnerHTML: __html: text.toString()
    return @bagMan.shipOut el

  doctype: (type=5) ->
    @raw doctypes[type]

  ie: (condition,contents)->
    @crel 'ie',condition:condition,contents

  tag: (tagName,args...) ->
    unless tagName? && 'string'== typeof tagName
      throw new Error "HTML tag type is invalid: expected a string but got #{typeof tagName?}"
    {attrs, contents} = @normalizeArgs args
    children = contents
    el = oracle.createElement tagName, attrs, children
    allTags[tagName]= Halvalla::[tagName] = el

  bless: (component,itsName=null)->
    component = component.default if component.__esModule && component.default
    name = itsName || component.name
    name = name[0].toLowerCase()+name.slice 1
    allTags[name]= Halvalla::[name] = (args...) => @crel component, args...

  renderContents: (contents, rest...) ->
    #for Teacup style signatures, we expect a single parameter-less function
    # we call it and it wil leave stuff on the 'stack'
    if not contents?
      return
    if typeof contents is 'function'
      contents = contents.apply @, rest
    if typeof contents is 'number'
      return @bagMan.shipOut new Number contents
    if typeof contents is 'string'
      return @bagMan.shipOut new String contents
    if contents.length >0
      return @bagMan.shipOut contents...
    return []

  component: (func) ->
    (args...) =>
      {selector, attrs, contents} = @normalizeArgs(args)
      renderContents = (args...) =>
        args.unshift contents
        @renderContents.apply @, args
      func.apply @, [selector, attrs, renderContents]


  crelVoid: (tagName, args...) ->
    {attrs, contents} = @normalizeArgs args
    if contents.length > 0
      throw new Error "Element type is invalid: must not have content: #{tagName}"
    el = oracle.createElement tagName, attrs,null
    return @bagMan.shipOut el

  crel: (tagName, args...) ->
    unless tagName?
      throw new Error "Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: #{tagName}"
    {attrs, contents} = @normalizeArgs args
    children =  if contents.length > 0
        oldBagger = @bagMan
        @bagMan = new BagMan
        @bagMan.context contents
        @march @bagMan
        contents = @bagMan.harvest()
        @bagMan = oldBagger
        #console.log "Children",contents
        contents
      else
        []
    el = oracle.createElement tagName, attrs, children...
    @bagMan.shipOut el
    return el

  text: (s) ->
    return s unless s?.toString
    return @bagMan.shipOut s.toString()

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
            contents= new String arg
        when 'number', 'boolean'
          contents= new String arg
        when 'function'
          contents = arg

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

  renderable: (stuff)->
    return (args...) =>
      oracle.conjurer @render stuff, args...
  #
  # rendering
  cede: (args...)->
    @render args...

  #liftedd from teacup renderer.  This side only does the instantiation
  march: (bag)->
    while component = bag.inspect()
      #console.log "March - to component",component
      switch n=component.constructor.name
        when 'Function'
          y=bag.harvest()
          x = component() # evaluate and push back
          if 'function' == typeof x
            w = x()
            x=w
          z=bag.harvest()
          bag.reinspect if z.length>0 then z else x
          break
        when 'String','Number' then bag.shipOut component
        when  n[0].toLowerCase()+n.slice 1 then bag.shipOut component
        else
          tagName = oracle.getName component
          #console.log 'Tagname of March component type object',tagName
          if 'string'== typeof tagName
            bag.shipOut component
            break
          if 'function' == typeof tagName
            #this component has not been instantiated yet
            tagConstructor = tagName
            tagName = tagConstructor.name
            tagNameLC = tagName[0].toLowerCase()+tagName.slice 1
            if component.attrs
              attrs = component.attrs
            else
              attrs = component.props
            if tagName[0] != tagNameLC[0]
              #console.log "Activvating NEW"
              unless Halvalla::[tagNameLC]  #generate alias for stack dumps
                Halvalla::[tagNameLC]= (component, args...) -> @crel tagNameLC,component,args...
              #crell = new tagConstructor tagNameLC,attrs,component.children
              #console.log "calling crel A", crell
              crellB = @[tagNameLC] attrs,oracle.getChildren component
              #console.log "calling crel B", crellB
              bag.shipOut crellB
              break
            else
              #render the node and append it to the htmlOout string
              bag.shipOut @[tagNameLC] '.selectorCase',attrs,oracle.getChildren component
    return null
    
  create: (node,rest...)->
    if 'function' == typeof node
      @bagMan.context ()=>node rest...
      @march @bagMan
      structure= @bagMan.harvest()
    else
      structure = new String node
    #console.log "Render Structure sent to oracle.conjurer",structure
    return structure 
  
  render: (funct)->
    structure = @create funct
    result = for element in structure
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
      'create bless cede component doctype escape ie normalizeArgs pureComponent raw render renderable tag text use'.split(' ')
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
