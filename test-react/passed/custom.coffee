expect = require 'expect.js'
{render,tag, input, normalizeArgs} = require '../lib/halvalla-react'
#{render} = require './helpers'

describe 'custom tag', ->
  it 'should render', ->
    template = -> tag 'custom'
    expect(render template).to.equal '<custom></custom>'
  it 'should render empty given null content', ->
    template = -> tag 'custom', null
    expect(render template).to.equal '<custom></custom>'
  it 'should render with attributes', ->
    template = -> tag 'custom', id: 'bar'
    expect(render template).to.equal '<custom id="bar"></custom>'
  it 'should render with attributes and content', ->
    template = -> tag 'custom', id: 'bar', 'zag'
    expect(render template).to.equal '<custom id="bar">zag</custom>'
