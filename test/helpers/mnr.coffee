isArray = (thing) ->
  thing != '[object Array]' and Object::toString.call(thing) == '[object Array]'

isObject = (thing) ->
  typeof thing == 'object'

camelToDash = (str) ->
  str.replace(/\W+/g, '-').replace /([a-z\d])([A-Z])/g, '$1-$2'

removeEmpties = (n) ->
  n != ''

# Lifted from the Mithril rewrite

copy = (source) ->
  res = source
  if isArray(source)
    res = Array(source.length)
    i = 0
    while i < source.length
      res[i] = source[i]
      i++
  else if typeof source == 'object'
    res = {}
    for k of source
      res[k] = source[k]
  res

# shameless stolen from https://github.com/punkave/sanitize-html

escapeHtml = (s, replaceDoubleQuote) ->
  if s == 'undefined'
    s = ''
  if typeof s != 'string'
    s = s + ''
  s = s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  if replaceDoubleQuote
    return s.replace(/"/g, '&quot;')
  s

setHooks = (component, vnode, hooks) ->
  if component.oninit
    component.oninit.call vnode.state, vnode
  if component.onremove
    hooks.push component.onremove.bind(vnode.state, vnode)
  return

createAttrString = (view, escapeAttributeValue) ->
  attrs = view.attrs
  if !attrs or !Object.keys(attrs).length
    return ''
  Object.keys(attrs).map((name) ->
    value = attrs[name]
    if typeof value == 'undefined' or value == null or typeof value == 'function'
      return
    if typeof value == 'boolean'
      return if value then ' ' + name else ''
    if name == 'style'
      if !value
        return
      styles = attrs.style
      if isObject(styles)
        styles = Object.keys(styles).map((property) ->
          if styles[property] != '' then [
            camelToDash(property).toLowerCase()
            styles[property]
          ].join(':') else ''
        ).filter(removeEmpties).join(';')
      return if styles != '' then ' style="' + escapeAttributeValue(styles, true) + '"' else ''
    # Handle SVG <use> tags specially
    if name == 'href' and view.tag == 'use'
      return ' xlink:href="' + escapeAttributeValue(value, true) + '"'
    ' ' + (if name == 'className' then 'class' else name) + '="' + escapeAttributeValue(value, true) + '"'
  ).join ''

createChildrenContent = (view, options, hooks) ->
  if view.text
    return options.escapeString(view.text)
  if isArray(view.children) and !view.children.length
    return ''
  _render view.children, options, hooks

render = (view, attrs, options) ->
  options = options or {}
  if view.view
    # root component
    view = m(view, attrs)
  else
    options = attrs or {}
  hooks = []
  defaultOptions = 
    escapeAttributeValue: escapeHtml
    escapeString: escapeHtml
    strict: false
  Object.keys(defaultOptions).forEach (key) ->
    if !options.hasOwnProperty(key)
      options[key] = defaultOptions[key]
    return
  result = _render(view, options, hooks)
  hooks.forEach (hook) ->
    hook()
    return
  result

_render = (view, options, hooks) ->
  if !view
    return ''
  console.log 'pre render', view if view.tag == 'br'
  type = typeof view
  if type == 'string'
    return options.escapeString(view)
  if type == 'number' or type == 'boolean'
    return view
  if isArray(view)
    return view.map((view) ->
      _render view, options, hooks
    ).join('')
  component = undefined
  vnode = undefined
  if isObject(view.tag)
    # embedded component
    component = view.tag
    vnode =
      state: copy(component)
      children: copy(view.children)
      attrs: view.attrs or {}
  else if view.view
    # root component
    component = view
    vnode =
      state: copy(component)
      children: copy(view.children)
      attrs: options.attrs or {}
  if view.attrs
    setHooks view.attrs, view, hooks
  # component
  if isObject(view.tag)
    vnode = 
      state: copy(view.tag)
      children: copy(view.children)
      attrs: view.attrs
    setHooks view.tag, vnode, hooks
    return _render(view.tag.view.call(vnode.state, vnode), options, hooks)
  if view.tag == '<'
    return '' + view.children
  children = createChildrenContent(view, options, hooks)
  if view.tag == '#'
    return options.escapeString(children)
  if view.tag == '['
    return '' + children
  children = ''  if '' == children.join? ''
  if !children and (options.strict or VOID_TAGS.indexOf(view.tag.toLowerCase()) >= 0)
    return '<' + view.tag + createAttrString(view, options.escapeAttributeValue) + (if options.strict then '/' else '') + '>'
  [
    '<'
    view.tag
    createAttrString(view, options.escapeAttributeValue)
    '>'
    children
    '</'
    view.tag
    '>'
  ].join ''
'use strict'
m = require('mithril/hyperscript')
VOID_TAGS = [
  'area'
  'base'
  'br'
  'col'
  'command'
  'embed'
  'hr'
  'img'
  'input'
  'keygen'
  'link'
  'meta'
  'param'
  'source'
  'track'
  'wbr'
  '!doctype'
]
render.escapeHtml = escapeHtml
module.exports = render
