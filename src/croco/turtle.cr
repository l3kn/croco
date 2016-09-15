require "./utils"
require "./world"
require "./patch"
require "stumpy_png"
include Utils

# This might sound strange,
# but the only difference
# between a turtle and a patch is,
# that the turtle can move around
# while the patch remains at its place
class Turtle < Patch
  property pen_down : Bool
  property direction : Float64

  def initialize(@x, @y, @direction, @world)
    super(@x, @y, @world)
    @pen_down = false
  end

  def die
    @world.remove_turtle(self)
  end

  def duplicate
    @world.duplicate_turtle(self)
  end

  def forward(n = 1)
    n = @data[n] if n.is_a? Symbol

    new_x = @x + n * Math.sin(@direction / RADIANTS)
    new_y = @y + n * Math.cos(@direction / RADIANTS)

    @world.line(@x, @y, new_x, new_y, @color) if pen_down?

    @x = new_x % @world.size_x
    @y = new_y % @world.size_y
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

  def face(x, y)
    delta_x = x - @x
    delta_y = y - @y

    @direction = (Math.atan2(delta_x, delta_y) * RADIANTS) % 360
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

  def ask_patch_here(&block)
    yield patch_here
  end

  def patch_here
    @world.get_patch(@x, @y)
  end

  def clone
    new = self.dup
    new.data = @data.clone

    new
  end
end
