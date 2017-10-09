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
{Chalice} = require '../src/chalice.coffee'
C=new Chalice Oracle
module.exports= C.tags()
module.exports.Chalice =Chalice
