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

    getProp: (element)->element.attrs  # where does mithril stash this info?
    getName: (element)->element.tag
    propertyName: 'attrs'
    trust: (text)-> Mithril.trust text # how to specify unescaped text

#require the Halvalla engine, but throw away it's default Oracle's tags
{Halvalla} = require '../lib/halvalla'
# create a new Halvalla with new overrides
#export identically to the original Halvalla
module.exports= (new Halvalla Oracle).tags()
module.exports.Halvalla =Halvalla
