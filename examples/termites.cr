require "../src/croco"

class Log
  def initialize(@keys : Array(String))
    @values = {} of String => Array(Float64)

    @keys.each do |key|
      @values[key] = [] of Float64
    end
  end

  def add(values = Array(Float64))
    values.each_with_index do |value, index|
      @values[@keys[index]] << value
    end
  end

  def write(filename, seperator = "\t ")
    return if @keys.size == 0
    File.open(filename, "w") do |file|
      @values[@keys.first].size.times do |i|
        file.puts @values.map { |k, vs| vs[i] }.join(seperator)
      end
    end
  end
end

class Termites < World
  property log : Log

  def initialize(width, height)
    super
    @diffusion_rate = 0.15
    @evaporation_rate = 0.05
    @log = Log.new(["step", "piles"])
  end

  def setup(n)
    clear_all
    create_turtles(n)
  end

  def turtle_init(turtle)
    turtle.color = white
    turtle[:carrying_chip?] = 0.0
    recolor_turtle(turtle)
  end

  def turtle_step(turtle)
    if turtle[:carrying_chip?] == 0.0
      look_for_chip_demon(turtle)
    else
      look_for_pile_demon(turtle)
    end
    turtle.wiggle(40)
    turtle.forward
    recolor_turtle(turtle)
  end

  def recolor_turtle(turtle)
    turtle.color = turtle[:carrying_chip?] == 1.0 ? blue : white
  end

  def look_for_chip_demon(turtle)
    if turtle.patch_here[:wood_chips] >= 1.0
      # Pick up food and head back to the nest
      turtle[:carrying_chip?] = 1.0
      turtle.patch_here.apply(:wood_chips) { |x| x - 1.0}
      turtle.right(180)
    end
  end

  def look_for_pile_demon(turtle)
    if turtle.patch_here[:wood_chips] >= 1.0
      # Pick up food and head back to the nest
      turtle[:carrying_chip?] = 0.0
      turtle.patch_here.apply(:wood_chips) { |x| x + 1.0}
      turtle.right(180)
    end
  end

  def patch_init(patch)
    if random(8) == 0
      patch[:wood_chips] = 1.0
    else
      patch[:wood_chips] = 0.0
    end
    recolor_patch(patch)
  end

  def patch_step(patch)
    recolor_patch(patch)
  end

  def recolor_patch(patch)
    n = [patch[:wood_chips], 5.0].min
    b = (255.0 / 5.0 * n).to_i

    patch.color = StumpyPNG::RGBA.from_rgb_n({0, 0, b}, 8)
  end

  def after_step
    if @steps % 100 == 0
      piles = @patches.count { |p| p[:wood_chips] > 0.0 }
      @log.add([@steps.to_f, piles.to_f])
    end
  end
end

world = Termites.new(100, 100)
world.setup(100)

5.times do |i|
  world.run_to(10 ** i)
  world.render("termites#{i}", 5)
end

world.log.write("termites.csv")
