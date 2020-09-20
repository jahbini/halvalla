[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/jahbini/halvalla)

# Halvalla

## The land where HTML deamons are conjured, instantiated and summoned into Three Domains

Valhalla began as an attempt to use Teact to create a React based application without using pointy brackets or back-ticks.  Rude things that bite the syntax and uglify the landscape.

However, React's interfaces have not been stable over the last few years, and
Teact's interfaces needed updating.  And the advantages of Mithril over React (patent issues included) pointed to a better direction for evolution.

Halvalla is intended to allow a teacup syntax html scripting notation to run unchanged in any of three back-end rendering engines:  React and Mithril virtual DOMs and HTML text.

It started out as Teact, but Halvalla put back in the missing sweetness of the Teacup meta-programming scheme.

The following syntax is supported.Your mileage may vary.

# It used to be Teact, er, Teacup, er..

Build React or Mithril element trees by composing functions.  
You get full javascript control flow, and minimal boilerplate.
It's also quite simple (not really), just a thin (as possible) wrapper around [React.createElement](https://facebook.github.io/react/docs/top-level-api.html#react.createelement) or Mithril's `m`
## Theory of operation

Halvalla uses an Oracle object to indicate what works in a given environment.  For example, this is from the source for 'halvalla-mithril':

```coffee
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
#
```

Currently, only the external aspects of Valhalla are in place:  Valhalla will get you to Mithril or React with your exact same source code, but the lifecycle methods
and class structures of React and Mithril do not get the same universal treatment...  **Yet**

## Usage
There are three ways to import Halvalla
1. set up the environment for React
```
{tag,...} = require 'halvalla-react'
```

2. set up the environment render to HTML directly with internal rendering
```
{tag,...} = require 'halvalla'
```
3. set up the environment for Mithril
```
{tag,div,...} = require 'halvalla-mithril'

```

### Sugar Syntax
Halvalla exports bound functions for elements, giving you options for
terser syntax if you're into that:

```coffee
H = require 'halvalla-mithril'

H.div className: 'foo', ->
  H.text 'Blah!'
```

or the Teacup / CoffeeCup signatures:

```coffee
{div, text} = require 'halvalla-teacup'

div '.foo', ->
  text 'Blah!'
```

```coffee
{tag} = require 'halvalla-react'

tag 'div', '#root.container', ->
  unless props.signedIn
    tag 'button', onClick: handleOnClick, 'Sign In'
  tag.text 'Welcome!'
```

Transforms into:

```coffee
React.createElement('div',
  {id: root, className: 'container'}, [
    (props.signedIn ? React.createElement('button',
      {onClick: handleOnClick}, 'Sign In'
    ) : null)
    'Welcome!'
  ]
)
```

Use it from your component's render method:
```coffee
{div,Component} = H = require 'halvalla-mithril'

class Widget extends Component
  render: ->
    div className: 'foo', =>
      div, 'bar'
```
And as a surprise, the tests included odd usage like this, and it works.
```coffee
{tag} = H = require 'halvalla-react'
module.exports = (props) ->
  tag 'div', className: 'foo', ->
    tag 'div', props.bar
```

### Nesting Components

Teacup signatures are updated when the component is instantiated,
or optionally, before instantiation by using Halvalla's `bless`.

After that, the new component is bound to Halvalla's knowledge of components, and may be called from other places in your code as properties of Halvalla's exports.

For example in a React based system you might write:
```coffee
H = require 'halvalla-react'
H.bless class DooDad extends H.Component
  render: ->
    H.div className: 'doodad', =>
      H.span @props.children
# blessing the class makes it visible everywhere as a property of halvalla
```
And in another module:

```coffee
H = require 'halvalla-react'
class Widget extends Component
  handleFiddle: =>
    # ...

  render: ->
    H.div className: 'foo', =>
      H.DooDad, onFiddled: @handleFiddle, =>
        H.div "I'm passed to DooDad.props.children"

#Widget will not appear as a property of H _until_ it's first instantiation.
```

If you need to build up a tree of elements inside a component's render method, you can
escape the element stack via the `pureComponent` helper:

```coffee
H = require 'halvalla-react'

Teas = H.pureComponent (teas) ->
  teas.map (tea) ->
    # Without pureComponent, this would add teas to the element tree
    # in iteration order.  With pureComponent, we just return the reversed list
    # of divs without adding the element tree.  The caller may choose to add
    # the returned list.
    H.div tea
  .reverse()

H.bless class Widget extends H.Component
  render: ->
    H.div Teas(@props.teas)
```

## Legacy

[Markaby](http://github.com/markaby/markaby) begat [CoffeeKup](http://github.com/mauricemach/coffeekup) begat
[CoffeeCup](http://github.com/gradus/coffeecup) and [DryKup](http://github.com/mark-hahn/drykup) which begat
[Teacup](http://github.com/goodeggs/teacup) which begat
[Teact](http://github.com/hurrymaplelad/teact) which evolved into _Halvalla_

## Installation

```sh
$ git clone https://github.com/jahbini/halvala && cd halvalla
$ npm install
$ npm test
```

# ToDo and Assistance Requests

1. finish mithril tests
2. enhance readability
3. add adaptors for lifecycle methods
4. extend the ability of Halvalla to reduce porting efforts of useful third party
components for Mithril and React.
