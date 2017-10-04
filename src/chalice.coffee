###
# Chalice -- bindings for element creation and expression via teact and teacup
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
{doctypes,elements,mergeElements} = require '../src/html-tags'
teacup = require '../src/teacup.coffee'
#if we are using React as the master, it supplies a class, otherwise an empty class with an empty view
dummyComponent = class Component
   constructor:(@tagName,@props,@children)->
     @
   view: ->

GreatEmptiness = class GreatEmptiness
  constructor: (oracle = {})->
    return me if me?
    @teacup=new teacup
    defaultObject =
      isValidElement: (c)->c.view?
      name: 'great-emptiness'
      Component: {}
      createElement: (args...)-> new dummyComponent args...
      summoner: null
      conjurer: @teacup.render.bind @teacup
    # decorate this singleton with
    for key,value of Object.assign defaultObject, oracle
      GreatEmptiness::[key] = value
    GreatEmptiness::me = @
    @
#
# global Oracle
#
oracle = new GreatEmptiness Oracle?

#
class Chalice
  constructor: ->
    @stack = null

  resetStack: (stack=null) ->
    previous = @stack
    @stack = stack
    return previous

  crel: (tagName, args...) =>
    unless tagName?
      throw new Error "Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: #{tagName}"
    {attrs, contents} = @normalizeArgs args
    switch typeof contents
      when 'function'
        previous = @resetStack []
        contents()
        children = @resetStack previous
      else
        children = contents
    if children?.splice
      el = oracle.createElement tagName, attrs, children...
    else
      el = oracle.createElement tagName, attrs, children

    @stack?.push el
    return el

  pureComponent: (contents) ->
    return ->
      previous = @.resetStack null
      children = contents.apply @, arguments
      @.resetStack previous
      return children

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
    contents = null

    for arg, index in args when arg?
      switch typeof arg
        when 'string'
          if index is 0 and @isSelector(arg)
            selector = arg
            parsedSelector = @parseSelector(arg)
          else
            contents = arg
        when 'function', 'number', 'boolean'
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
          else
            contents = arg
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

    return {attrs, contents, selector}

  #
  # Plugins
  #
  use: (plugin) ->
    plugin @

  #
  # rendering
  #
  render: (nodes,rest...)->
    structure = nodes rest...
    oracle.conjurer structure


  #
  # Binding
  #
  tags: ->
    bound = {}
    boundMethodNames = [].concat(
      'cede coffeescript comment component doctype escape ie normalizeArgs raw render renderable script tag text use'.split(' ')
      mergeElements 'regular', 'obsolete', 'raw', 'void', 'obsolete_void'
    )
    for method in boundMethodNames
      do (method) =>
        bound[method] = (args...) => @[method].apply @, args

    return bound


  bless: (component,itsName=null)->
    component = component.default if component.__esModule && component.default
    name = itsName || component.name
    blessedTags[name]=name
    Chalice::[name] = (args...) => @crel component, args...

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
    Chalice::[tagName] = (args...) -> @crel tagName, args...

for tagName in mergeElements 'raw'
  do (tagName) ->
    Chalice::[tagName] = (args...) -> @crel tagName, args...

for tagName in mergeElements 'script'
  do (tagName) ->
    Chalice::[tagName] = (args...) -> @crel tagName, args...

for tagName in mergeElements 'void', 'obsolete_void'
  do (tagName) ->
    Chalice::[tagName] = (args...) -> @crel tagName, args...

if module?.exports
  module.exports = new Chalice().tags()
  module.exports.Chalice = Chalice
else if typeof define is 'function' and define.amd
  define('teacup', [], -> new Chalice().tags())
else
  window.teacup = new Chalice().tags()
  window.teacup.Chalice = Chalice
