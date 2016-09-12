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

  def run_to(n)
    run(n - @steps) if n > @steps
  end

  def run(n)
    if @steps == 0
      @patches.each do |p|
        patch_init(p)
      end
      @turtles.each do |t|
        turtle_init(t)
      end
    end

    n.times do
      @patches.each do |p|
        patch_step(p)
      end
      @patches.each do |p|
        p.diffusions_apply
      end
      @turtles.each do |t|
        turtle_step(t)
      end
      @steps += 1
    end
  end

  def line(x0, y0, x1, y1, color)
    Helper.line(x0, y0, x1, y1, @canvas, color)
  end

  def render(filename)
    step = 10
    output_canvas = StumpyPNG::Canvas.new(@size_x * step, @size_y * step, white)

    (0...@size_x).each do |x|
      (0...@size_y).each do |y|
        patch = get_patch(x, y)
        step.times do |off_x|
          step.times do |off_y|
            output_canvas[x*step + off_x, y*step + off_y] = patch.color
          end
        end
      end
    end

    @turtles.each do |t|
      Helper.circle(t.x * step, t.y * step, 5, output_canvas, t.color)

      x0 = t.x * step
      y0 = t.y * step
      n = 10
      x1 = (t.x * step) + n * Math.sin(t.direction / RADIANTS)
      y1 = (t.y * step) + n * Math.cos(t.direction / RADIANTS)

      Helper.line(x0, y0, x1, y1, output_canvas, t.color)
    end
    StumpyPNG.write(output_canvas, "#{filename}.png")
  end
end
