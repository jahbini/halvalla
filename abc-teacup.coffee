expect = require 'expect.js'
{tag,Component, p,use, div,text, script, span,render,renderable,bless} = require '../lib/halvalla-react'
re=require 'react'

dooDad = bless class DooDad extends Component
  render: =>
    props = @props
    div className: 'doodad', ->
      text props.label
      if props.children
        use (obj)->
          obj.stack.push props.children
      span "some last text"
describe 'components with child', ->
  it 'renders child with dooDad', ->
    bogus=render ->
      dooDad label: 'Boo',->
        x=div ".aclass",'some text'
        return x
    expect(bogus).to.equal '<div class="doodad">Boo<div class="aclass">some text</div><span>some last text</span></div>'

widget = bless class Widget extends Component
  constructor: (args...)->
    super(args...)
    @

  render: =>
    div className: 'foo', ->
      dooDad label: 'Doo', ->
        span "I'm passed to DooDad.props.children"


describe 'components', ->
  it 'render with dooDad', ->
    bogus=render ->
      dooDad label: 'Label text.', ()->
        span 'A single text child'
    expect(bogus).to.equal '<div class="doodad">Label text.<span>A single text child</span><span>some last text</span></div>'

describe 'use of render in classes', ->
  it 'supports a single child', ->
    expect(render ->
      widget
    ).to.equal '<div class="foo"><div class="doodad">Doo<span>I&#x27;m passed to DooDad.props.children</span><span>some last text</span></div></div>'

describe 'nesting components', ->
  it 'supports a multipl children', ->
    expect(render ->
      dooDad label: 'A', ->
        dooDad label: 'B'
        dooDad label: 'C'
    ).to.equal '<div class="doodad">A<div class="doodad">C<span>some last text</span></div><span>some last text</span></div>'
    # React rendering does some funny things with labels and spans
    # who does react think it is? The Oracle?  Um. yes. For now.
