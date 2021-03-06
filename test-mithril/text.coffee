###
text rendering mithril mocha 
renderable test
###
expect = require 'expect.js'
{render, renderable, text, h1} = require '../lib/halvalla-mithril'

describe 'text', ->
  it 'renders text verbatim', ->
    expect(render renderable(text) 'foobar').to.equal 'foobar'

  it 'renders numbers', ->
    expect(render renderable(text) 1).to.equal '1'
    expect(render renderable(text) 0).to.equal '0'

  it 'is assumed when it is returned from contents', ->
    template = -> h1 -> 'hello world'
    expect(render template).to.equal '<h1>hello world</h1>'
    template = -> h1 '.title', -> 'hello world'
    expect(render template).to.equal '<h1 class="title">hello world</h1>'
    template = -> h1 class: 'title', -> 'hello world'
    expect(render template).to.equal '<h1 class="title">hello world</h1>'
    template = -> h1 '.title', -> text 'hello world'
    expect(render template).to.equal '<h1 class="title">hello world</h1>'
