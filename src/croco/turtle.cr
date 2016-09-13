require "./utils"
require "./world"
require "stumpy_png"
include Utils

class Turtle
  property x : Float64
  property y : Float64

  property direction : Int32
  property color : StumpyPNG::RGBA

  property world : World

  getter data : Hash(Symbol, Float64)


  def initialize(@x, @y, @direction, @world)
    @pen_down = false
    @color = black
    @data = {} of Symbol => Float64
  end

  def forward(n = 1)
    n = @data[n] if n.is_a? Symbol

    new_x = @x + n * Math.sin(@direction / RADIANTS)
    new_y = @y + n * Math.cos(@direction / RADIANTS)

    @world.line(@x, @y, new_x, new_y, @color) if pen_down?

    @x = new_x
    @y = new_y
  end

  def back(n = 1)
    n = @data[n] if n.is_a? Symbol

    forward(-n)
  end

  def left(n = 90)
    n = @data[n] if n.is_a? Symbol
    @direction = (@direction - n) % 360
  end

  def right(n = 90)
    n = @data[n] if n.is_a? Symbol
    @direction = (@direction + n) % 360
  end

  def wiggle(n)
    left(random n)
    right(random n)
  end

  def pen_down?
    @pen_down
  end

  def pen_down
    @pen_down = true
  end

  def pen_up
    @pen_down = false
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

  def ask_patch_here(&block)
    yield patch_here
  end

  def patch_here
    @world.get_patch(@x.to_i, @y.to_i)
  end

end
