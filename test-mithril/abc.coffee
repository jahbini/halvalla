###
abc.coffee mocha test file for mithril
###
expect = require 'expect.js'
{tag,h2,Component,bless, p,use, div,text, script, span,render,renderable,bless} = require '../lib/halvalla-mithril'


divDad = bless class DivDad extends Component
  view:()=>
    div '.bango',"wow"
  
describe 'a class enclosed div', ->
  it 'without decoration', ->
    template = ->
      divDad
    debugger
    expect(render template).to.equal '<div class="bango">wow</div>'   

describe 'classes', ->
  it 'with text children', ->
    template = ->
      h2 ".wowie.zowie","wowoie"
    debugger
    expect(render template).to.equal '<h2 class="wowie zowie">wowoie</h2>'
      
describe 'a simple div', ->
  it 'simple div without decoration', ->
    template = ->
        div()
    expect(render template).to.equal '<div></div>'


describe 'multiple tags', ->
  it 'with multiple text children', ->
    template = ->
      div ".wow",()->
        div "wow1"
        div "wow2"
      h2 "wowie", ()->
        div "first"
        div "second"
    expect(render template).to.equal '<div class="wow"><div>wow1</div><div>wow2</div></div><h2><div>first</div><div>second</div></h2>'
    

describe 'multiple tags', ->
    it 'with text children', ->
      template = ->
        div "wow"
        h2 ".wowie","wowoie"
      debugger
      expect(render template).to.equal '<div>wow</div><h2 class="wowie">wowoie</h2>'
  