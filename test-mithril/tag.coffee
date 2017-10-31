###
Test simple div
oddly eough this is named tag.coffee
###
expect = require 'expect.js'
{renderable, render, p, div, script} = require '../lib/halvalla-mithril'

describe 'tag', ->
  it 'renders Dates', ->
    date = new Date(2013,1,1)
    expect(render renderable(p) date).to.equal "<p>#{date.toString()}</p>"

  it 'renders text verbatim', ->
    expect(render renderable(p) 'foobar').to.equal '<p>foobar</p>'

  it 'renders numbers', ->
    expect(render renderable(p) 1).to.equal '<p>1</p>'
    expect(render renderable(p) 0).to.equal '<p>0</p>'

  it "renders undefined as ''", ->
    expect(render renderable(p) undefined).to.equal "<p></p>"

  it 'renders empty tags', ->
    template = renderable ->
      script src: 'js/app.js'
    expect(render template()).to.equal('<script src="js/app.js"></script>')
