require "stumpy_png"
require "./turtle"
require "./patch"
require "./helper"
require "./utils"

include Utils

class World
  getter canvas : StumpyPNG::Canvas
  getter turtles : Array(Turtle)
  getter patches : Array(Patch)
  getter steps : Int32

  getter size_x : Int32
  getter size_y : Int32
  
  def initialize(@size_x, @size_y)
    @canvas = StumpyPNG::Canvas.new(size_x, size_y, white)

    @turtles = [] of Turtle
    @patches = [] of Patch
    @steps = 0

    init_patches
  end

  def init_patches
    (0...@size_y).each do |y|
      (0...@size_x).each do |x|
        @patches << Patch.new(x, y, self)
      end
    end
  end

  def get_patch(x, y)
    x %= @size_x
    y %= @size_y
    @patches[x + @size_x * y]
  end

  def create_turtles(n)
    @turtles = Array.new(n) do
      direction = rand(0...360)
      # (0, 0) is the center of the world
      x = rand(0...@size_x)
      y = rand(0...@size_y)

      Turtle.new(x.to_f, y.to_f, direction, self)
    end
  end

  def clear_all
    @turtles = [] of Turtle
  end

  def turtle_step(turtle)
  end

  def turtle_init(turtle)
  end

  def patch_step(patch)
  end

  def patch_init(patch)
  end

  def before_init
  end

  def after_init
  end

  def before_step
  end

  def after_step
  end

  # Diffusion needs to happen on this level
  # because patch_step
  # is applied to one patch after another,
  # not once for all patches,
  # and this would distort the results
  def diffuse(key, rate = 0.80)
    new_values = Array.new(@patches.size, 0.0)

    # First, calculate new values for all patches
    @patches.each_with_index do |patch, i|
      neighbours = 0.0
      x = patch.x
      y = patch.y

      neighbours += get_patch(x + 1,     y)[key]
      neighbours += get_patch(x - 1,     y)[key]
      neighbours += get_patch(    x, y + 1)[key]
      neighbours += get_patch(    x, y - 1)[key]
      neighbours += get_patch(x + 1, y + 1)[key]
      neighbours += get_patch(x + 1, y - 1)[key]
      neighbours += get_patch(x - 1, y + 1)[key]
      neighbours += get_patch(x - 1, y - 1)[key]

      own = patch[key]
      new_value = (neighbours * rate / 8) + own * (1.0 - rate)

      new_values[i] = new_value
    end

    # Then, change all patches at once
    @patches.each_with_index do |patch, i|
      patch[key] = new_values[i]
    end
  end

  def run_to(n)
    run(n - @steps) if n > @steps
  end

  def run(n)
    if @steps == 0
      before_init
      @patches.each do |p|
        patch_init(p)
      end
      @turtles.each do |t|
        turtle_init(t)
      end
      after_init
    end

    n.times do
      print "\rStep #{@steps}"
      before_step
      @patches.each do |p|
        patch_step(p)
      end
      @turtles.each do |t|
        turtle_step(t)
      end
      @steps += 1
      after_step
    end
  end

  def line(x0, y0, x1, y1, color)
    Helper.line(x0, y0, x1, y1, @canvas, color)
  end

  def render(filename, size = 10)
    output_canvas = StumpyPNG::Canvas.new(@size_x * size, @size_y * size, white)

    (0...@size_x).each do |x|
      (0...@size_y).each do |y|
        patch = get_patch(x, y)
        size.times do |off_x|
          size.times do |off_y|
            output_canvas[(x * size) + off_x, (y * size) + off_y] = patch.color
          end
        end
      end
    end

    @turtles.each do |t|
      Helper.circle(t.x * size, t.y * size, 5, output_canvas, t.color)

      x0 = t.x * size
      y0 = t.y * size
      n = 10
      x1 = (t.x * size) + n * Math.sin(t.direction / RADIANTS)
      y1 = (t.y * size) + n * Math.cos(t.direction / RADIANTS)

      Helper.line(x0, y0, x1, y1, output_canvas, t.color)
    end
    StumpyPNG.write(output_canvas, "#{filename}.png")
  end
end
