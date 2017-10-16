expect = require 'expect.js'
{script,render} = require '../src/halvalla-react'
#{render} = require './helpers'

describe 'HereDocs', ->
  it 'preserves line breaks', ->
    template = -> script """
      $(document).ready(function(){
        alert('test');
      });
    """
    expect(render template).to.equal '<script>$(document).ready(function(){\n  alert(&#x27;test&#x27;);\n});</script>'
