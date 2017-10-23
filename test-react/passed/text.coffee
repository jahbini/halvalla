expect = require 'expect.js'
{render,text, h1} = require '../lib/halvalla-react'
#{render} = require './helpers'

describe 'text', ->
  it 'renders text verbatim', ->
    expect(render -> text 'foobar').to.equal '<text>foobar</text>'
  # early test specs wanted 'foobar' unadorned with '<text>' but
  # React as of 14.x.x does not seem to support that

  it 'renders numbers', ->
    expect(render -> text 1).to.equal '<text>1</text>'
    expect(render -> text 0).to.equal '<text>0</text>'
