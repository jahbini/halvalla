#
require('mithril/test-utils/browserMock')(global);
#
Mithril=require 'mithril'

Oracle =
    summoner: Mithril
    name: 'Mithril'
    createElement: Mithril
    preInstantiate: true
    getProp: (element)->element.attrs
    getName: (element)->element.tag
    trust: (text)-> Mithril.trust text
debugger
{Halvalla} = require '../src/halvalla.coffee'
C=new Halvalla Oracle
module.exports= C.tags()
module.exports.Halvalla =Halvalla
