expect = require 'expect.js'
{tag, p, div,text, script, span,render,bless,oracle} = require '../src/chalice-react'

Component = oracle().Component

dooDad = bless class DooDad extends Component
  render: ->
    console.log "PROPerties",@props
    props = @props
    div className: 'doodad', ->
      text props.label
      span props.children

widget = bless class Widget extends Component
  render: ->
    console.log "PROPerties",@props
    div className: 'foo', ->
      dooDad label: 'Doo', ->
        text "I'm passed to DooDad.props.children"

describe 'components', ->
  it 'render with dooDad', ->
    debugger
    expect(render ->
      dooDad label: 'Boo'
    ).to.equal '<dooDad label="Boo"></dooDad>'

describe 'nesting components', ->
  it 'supports a single child', ->
    expect(render ->
      widget
    ).to.equal '<div class="foo"><div class="doodad">Doo<span>I&#x27;m passed to DooDad.props.children</span></div></div>'

  it 'supports a multipl children', ->
    expect(render ->
      dooDad label: 'A', ->
        dooDad label: 'B'
        dooDad label: 'C'
    ).to.equal '<div class="doodad">A<span><div class="doodad">B<span></span></div><div class="doodad">C<span></span></div></span></div>'
