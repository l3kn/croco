require "./utils"
require "./world"
require "stumpy_png"
include Utils

class Patch
  property color : StumpyPNG::RGBA
  property world : World
  getter data : Hash(Symbol, Float64)

  property x : Float64 
  property y : Float64

  def initialize(@x, @y, @world)
    @color = white
    @data = {} of Symbol => Float64
  end

  def []=(key, value)
    @data[key] = value
  end

  def [](key)
    @data[key] || 0.0
  end

  def apply(key)
    @data[key] = yield @data[key]
  end

  def distance(x, y)
    delta_x = @x - x
    delta_y = @y - y
    Math.sqrt(delta_x * delta_x + delta_y * delta_y)
  end

  def neighbours
    @world.neighbours(@x, @y)
  end

  def neighbours4
    @world.neighbours4(@x, @y)
  end

  def turtles
    @world.get_turtles_for_patch(@x, @y)
  end
end
