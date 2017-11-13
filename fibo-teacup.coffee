expect = require 'expect.js'
T= require '../lib/halvalla'

describe 'Fibonacci Spiral example', ->

  it 'works', ->
    x = title: 'Foo'
    path = '/zig'
    user = {}
    max = 12
    shoutify = (s) -> s.toUpperCase() + '!'
    rollSquare = [0,0,1,1,0,0,1,1,0,0,1,1]
    template = ->
      squareOptions = []
      squareOptions.push color:"bg-silver",text:"zero",src:"stjohnsjim.com"
      squareOptions.push color:"bg-teal",text:"one",src:"celarien.tell140.com"
      squareOptions.push color:"bg-fushcia",text:"two",src:"bamboosnow.tell140.com"
      squareOptions.push color:"bg-olive",text:"three",src:"bamboosnow.tell140.com"
      squareOptions.push color:"bg-white",text:"four",src:"celarien.tell140.com"
      squareOptions.push color:"bg-aqua",text:"five",src:"stjohnsjim.com"
      squareOptions.push color:"bg-purple",text:"six",src:"bamboosnow.tell140.com"
      squareOptions.push color:"bg-blue",text:"seven",src:"stjohnsjim.com"
      squareOptions.push color:"bg-olive",text:"eight"
      squareOptions.push color:"bg-navy",text:"nine"
      squareOptions.push color:"bg-red",text:"ten"
      
      ratioToPixels = (xRaw,yRaw)->
        console.log "Ratio x,y=",xRaw,yRaw
        console.log "Ratio = ", (xRaw/yRaw+yRaw/xRaw) 
        return null if (xRaw/yRaw+yRaw/xRaw) > 2.4
        return 
          x: Math.floor xRaw
          y: Math.floor yRaw
      Lozenge = (n,x,y)->
        return T.div "#last.bg-red.inline-block",width:x,height:y,style: {minWidth:x+"px", minHeight:y+"px"} unless px=ratioToPixels x,y
        {x,y} = px
        if x>y
          lx = Math.floor x-y
          #horizontal lozenge with square on left or right
          T.div  ".h-lozenge",width:x+"px", height:y+"px", style: {width:x+"px", height:y+"px"}, ->
            classNames = if rollSquare[n] then '.square.left' else '.square.right'
            T.div "#{classNames}.#{squareOptions[n].color}", width:y+"px",height:y+"px", style: {width:y+"px",height:y+"px",WebkitTransform:'scale(.1618)'}, ->
              T.iframe width:"1150px" , height:"800px", src:"http://#{squareOptions[n].src}"
            Lozenge n+1, lx,y 
        else
          ly = Math.floor y-x
          T.div  ".v-lozenge",width:x+"px", height:y+"px", style: {width:x+"px", height:y+"px"}, ->
            if rollSquare[n]
              T.div ".square.#{squareOptions[n].color}", width:y+"px",height:y+"px", style: {width:y+"px",height:y+"px",WebkitTransform:'scale(.1618)'}, ->
                T.iframe width:"1150px" , height:"800px", src:"http://#{squareOptions[n].src}"
              Lozenge n+1, x,ly 
            else
              Lozenge n+1, x,ly 
              T.div ".square.#{squareOptions[n].color}", width:y+"px",height:y+"px", style: {width:y+"px",height:y+"px",WebkitTransform:'scale(.1618)'}, ->
                T.iframe width:"1150px" , height:"800px", src:"http://#{squareOptions[n].src}"
          
          T.div ".bottom-square.#{squareOptions[n].color}", width:x+"px",height:x+"px", style: {width:x+"px",height:x+"px"}, ->
          
      phi = 1.61803398
      phi = 1.619
      iPhi = phi - 1
      
      x= 1150
      y= 1150*iPhi
      return Lozenge 0,x,y   
    result = (T.render template)
    console.log "--------------------------------------------"
    console.log result.replace /></g ,">\n<"
    expect(result ).to.contain 'Just Stuff'
  