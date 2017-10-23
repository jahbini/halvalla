expect = require 'expect.js'
{renderable, p, div, script} = require '../lib/halvalla'

describe 'tag', ->
  it 'renders Dates', ->
    date = new Date(2013,1,1)
    debugger
    expect(renderable(p) date).to.equal "<p>#{date.toString()}</p>"

  it 'renders text verbatim', ->
    expect(renderable(p) 'foobar').to.equal '<p>foobar</p>'

  it 'renders numbers', ->
    expect(renderable(p) 1).to.equal '<p>1</p>'
    debugger
    expect(renderable(p) 0).to.equal '<p>0</p>'

  it "renders undefined as ''", ->
    expect(renderable(p) undefined).to.equal "<p></p>"

  it 'renders empty tags', ->
    template = renderable ->
      script src: 'js/app.js'
    expect(template()).to.equal('<script src="js/app.js"></script>')
