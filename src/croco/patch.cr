require "./utils"
require "./world"
require "stumpy_png"
include Utils

class Patch
  property color : StumpyPNG::RGBA
  property world : World
  getter data : Hash(Symbol, Float64)
  getter diffusions : Array({Symbol, Float64})

  property x : Int32
  property y : Int32

  def initialize(@x, @y, @world)
    @color = white
    @data = {} of Symbol => Float64
    @diffusions = [] of {Symbol, Float64}
  end

  def diffuse(key, rate = 0.80)
    return if @data[key] <= 0.001

    value = @data[key] * rate / 8
    @world.get_patch(@x + 1,     @y).diffusion_add(key, value)
    @world.get_patch(@x - 1,     @y).diffusion_add(key, value)
    @world.get_patch(@x,     @y + 1).diffusion_add(key, value)
    @world.get_patch(@x,     @y - 1).diffusion_add(key, value)
    @world.get_patch(@x + 1, @y + 1).diffusion_add(key, value)
    @world.get_patch(@x + 1, @y - 1).diffusion_add(key, value)
    @world.get_patch(@x - 1, @y + 1).diffusion_add(key, value)
    @world.get_patch(@x - 1, @y - 1).diffusion_add(key, value)
    @world.get_patch(@x, @y).diffusion_add(key, -value * 8)
  end

  def diffusion_add(key, value)
    @diffusions << {key, value}
  end

  def diffusions_apply
    @diffusions.each do |key, value|
      @data[key] += value
    end

    @diffusions = [] of {Symbol, Float64}
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
end
