require "stumpy_png"
require "stumpy_utils"
require "../../../stumpy_gif/src/stumpy_gif"
require "./turtle"
require "./patch"
require "./helper"
require "./utils"

include Utils

# class Turtle < AbstractTurtle
# end

# class Patch < AbstractPatch
# end

class World
  getter canvas : StumpyCore::Canvas
  getter turtles : Array(Turtle)
  getter new_turtles : Array(Turtle)
  getter patches : Array(Patch)
  getter steps : Int32

  getter size_x : Int32
  getter size_y : Int32

  getter size : Int32

  property silent : Bool
  
  def initialize(@size_x, @size_y, @size = 10)
    @canvas = StumpyCore::Canvas.new(size_x * @size, size_y * @size, white)

    @turtles = [] of Turtle
    @new_turtles = [] of Turtle
    @deletion_turtles = [] of Turtle
    @patches = [] of Patch
    @steps = 0

    @silent = false

    init_patches
  end

  def init_patches
    (0...@size_y).each do |y|
      (0...@size_x).each do |x|
        @patches << Patch.new(x.to_f, y.to_f, self)
      end
    end
  end

  def get_patch(x, y)
    x = x.to_i % @size_x
    y = y.to_i % @size_y
    @patches[x + @size_x * y]
  end

  def create_turtles(n)
    @turtles = Array.new(n) do
      direction = rand(0.0...360.0)
      # (0, 0) is the center of the world
      x = rand(0...@size_x)
      y = rand(0...@size_y)

      Turtle.new(x.to_f, y.to_f, direction, self)
    end
  end

  def clear_all
    @turtles = [] of Turtle
  end

  def before_init
  end

  def after_init
  end

  def before_step
  end

  def after_step
  end

  def neighbours(x, y)
    [
      get_patch(x + 1,     y),
      get_patch(x - 1,     y),
      get_patch(    x, y + 1),
      get_patch(    x, y - 1),
      get_patch(x + 1, y + 1),
      get_patch(x + 1, y - 1),
      get_patch(x - 1, y + 1),
      get_patch(x - 1, y - 1),
    ]
  end

  def neighbours4(x, y)
    [
      get_patch(x + 1,     y),
      get_patch(x - 1,     y),
      get_patch(    x, y + 1),
      get_patch(    x, y - 1),
    ]
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
      neighbours_value = neighbours(patch.x, patch.y).map { |p| p[key] }.sum

      own = patch[key]
      new_value = (neighbours_value * rate / 8) + own * (1.0 - rate)

      new_values[i] = new_value
    end

    # Then, change all patches at once
    @patches.each_with_index do |patch, i|
      patch[key] = new_values[i]
    end
  end

  def get_turtles_for_patch(x, y)
    @turtles.select { |t| t.x >= x && t.x < (x+1) && t.y >= y && t.y < (y+1) }
  end

  def remove_turtle(turtle)
    @deletion_turtles << turtle
  end

  def duplicate_turtle(t)
    @new_turtles << t.clone
  end

  def run_to(n)
    run(n - @steps) if n >= @steps
  end

  def run(n)
    if @steps == 0
      before_init
      after_init
    end

    n.times do
      print "\rStep #{@steps}" unless @silent
      before_step

      @patches.each(&.step)
      @turtles.each(&.step)
      @steps += 1

      # Only add cloned turtles / remove deleted turtles
      # after the steps for all “old” turtles have been run.
      # Otherwise it would manipulate the turtle step loop
      @turtles -= @deletion_turtles
      @turtles += @new_turtles
      @new_turtles = [] of Turtle
      @deletion_turtles = [] of Turtle

      after_step
    end
  end

  def line(x0, y0, x1, y1, color)
    StumpyUtils.line(@canvas,
                     (x0 * @size).to_i, (y0 * @size).to_i,
                     (x1 * @size).to_i, (y1 * @size).to_i,
                     color)
  end

  def render_animated(filename, steps, filled = false)
    frames = [] of StumpyCore::Canvas
    steps.each do |step|
      run_to(step)
      frames << render(filled)
    end

    StumpyGIF.write(frames, "#{filename}.gif", 30, :median_split)
  end

  # TODO: modify render functions to accept a step argument
  # instead of using `world.run_to(n)`
  def render(filename, filled = false)
    StumpyPNG.write(output_canvas, "#{filename}.png")
  end

  def render(filled = false)
    output_canvas = StumpyCore::Canvas.new(@size_x * @size, @size_y * @size, white)

    (0...@size_y).each do |y|
      (0...@size_x).each do |x|
        patch = get_patch(x, y)
        size.times do |off_y|
          size.times do |off_x|
            output_canvas[(x * @size) + off_x, (y * @size) + off_y] = patch.color
          end
        end
      end
    end

    @turtles.each do |t|
      if filled
        Helper.filled_circle(t.x * @size, t.y * @size, 5, output_canvas, t.color)
      else
        Helper.circle(t.x * @size, t.y * @size, 5, output_canvas, t.color)
      end

      x0 = t.x * @size
      y0 = t.y * @size
      n = 10
      x1 = (t.x * @size) + n * Math.sin(t.direction / RADIANTS)
      y1 = (t.y * @size) + n * Math.cos(t.direction / RADIANTS)

      StumpyUtils.line(output_canvas, x0.to_i, y0.to_i, x1.to_i, y1.to_i, t.color)
    end

    (0...(@size_y * @size)).each do |y|
      (0...(@size_x * @size)).each do |x|
        other = @canvas[x, y]
        output_canvas[x, y] = other if other != white
      end
    end

    output_canvas
  end
end
