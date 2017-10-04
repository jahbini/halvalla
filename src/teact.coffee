###
# Remove react dependency
# Rebass, too, boo hoo
###

module.exports = class Teact
  constructor:(@elementCreator)->
    @stack = null

  resetStack: (stack=null) ->
    previous = @stack
    @stack = stack
    return previous

  crel: (tagName, args...) =>
    unless tagName?
      throw new Error "Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: #{tagName}"
    {attrs, contents} = @normalizeArgs args
    switch typeof contents
      when 'function'
        previous = @resetStack []
        contents()
        children = @resetStack previous
      else
        children = contents
    if children?.splice
      el = elementCreator tagName, attrs, children...
    else
      el = elementCreator tagName, attrs, children

    @stack?.push el
    return el

  pureComponent: (contents) ->
    return ->
      previous = @.resetStack null
      children = contents.apply @, arguments
      @.resetStack previous
      return children

  text: (s) ->
    return s unless s?.toString
    @stack?.push(s.toString())
    return s.toString()
