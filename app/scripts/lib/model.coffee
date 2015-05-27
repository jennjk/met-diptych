
class Collection

  constructor: (items = []) ->
    @items = items.map((obj) -> new Item(obj) if obj.image_thumb? and not /NoImage/.test obj.image_thumb)
      .filter (obj) -> obj?

    @pilot = @items.splice(
        @rand_index = Math.floor(Math.random()*@items.length)
      ,1)[0] or null

    @coPilot = @items[(
      @coIndex = 0
      )] or null


    @nextCoPilot = ->
      @coIndex++
      @coPilot = @items[@coIndex % @items.length] or null
    
    
class Item
  constructor: (item) ->
    @image_thumb = item?.image_thumb or null
    @image_large = if @image_thumb then @image_thumb.replace /web-thumb/, "web-large" else null
    @image = @image_large

module.exports = { Item: Item, Collection: Collection }
