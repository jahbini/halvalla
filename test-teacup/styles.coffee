
  bind = (fn, me) ->
    ->
      fn.apply me, arguments

  extend = (child, parent) ->

    ctor = ->
      @constructor = child
      return

    for key of parent
      if hasProp.call(parent, key)
        child[key] = parent[key]
    ctor.prototype = parent.prototype
    child.prototype = new ctor
    child.__super__ = parent.prototype
    child

  hasProp = {}.hasOwnProperty
  slice = [].slice
  expect = require('expect.js')
  ref = T = require('../lib/halvalla')
  tag = ref.tag
  Component = ref.Component
  p = ref.p
  use = ref.use
  div = ref.div
  text = ref.text
  script = ref.script
  span = ref.span
  render = ref.render
  renderable = ref.renderable
  bless = ref.bless
  
  describe 'quoting style objects', ->
    classNames = undefined
    color = undefined
    src = undefined
    y = undefined
    it 'converts camel to kebab, allows multiple and quotes the whole mess', ->
    classNames = '.square.left'
    color = 'blue'
    src = 'celarien.com'
    y = 711
    
    expect(render(->
      T.div classNames + '.' + color, {
        width: y + 'px'
        height: y + 'px'
        style:
          width: y + 'px'
          height: y + 'px'
          WebkitTransform: 'scale(.1618)'
      }, ->
        T.iframe
          width: '1150px'
          height: '800px'
          src: 'http://' + src
    )).to.equal '<div class="square left blue" width="711px" height="711px" style="width:711px;height:711px;-webkit-transform:scale(.1618)"><iframe width="1150px" height="800px" src="http://celarien.com"></iframe></div>'
    
    expect(render(->
      T.tag 'svg', classNames + '.' + color, {
        width: y + 'px'
        height: y + 'px'
        style:
          width: y + 'px'
          height: y + 'px'
          WebkitTransform: 'scale(.1618)'
      }, ->
        T.iframe
          width: '1150px'
          height: '800px'
          src: 'http://' + src
    )).to.equal '<svg class="square left blue" width="711px" height="711px" style="width:711px;height:711px;WebkitTransform:scale(.1618)"><iframe width="1150px" height="800px" src="http://celarien.com"></iframe></svg>'
  return
