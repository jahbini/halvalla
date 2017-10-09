#
Mithril=require 'mithril'
#
# Halvalla.render defaults to HTML via internal teacup rendering engine
# which is smart enough to recognize mithril's quirks
# use Halvalla.render to get server-side, Mithril.render to get client side.
Oracle =
    summoner: Mithril  #the Greater Power
    name: 'Mithril'    # his name
    createElement: Mithril    #he creates without hassle, but requires us to
    preInstantiate: true      # instantiate the whole virtual DOM before rendering
                              # React allows lazy instatiation when rendering
    getProp: (element)->element.attrs  # where does mithril stash this info?
    getName: (element)->element.tag
    trust: (text)-> Mithril.trust text # how to specify unescaped text

#require the Halvalla engine, but throw away it's default Oracle's tags
{Halvalla} = require '../src/halvalla.coffee'
# create a new Halvalla with new overrides
#export identically to the original Halvalla 
module.exports= (new Halvalla Oracle).tags()
module.exports.Halvalla =Halvalla
