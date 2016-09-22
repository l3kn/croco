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

class Turtle < AbstractTurtle
  def init
    self[:carrying_chip?] = 0.0
    recolor
  end

  def step
    if self[:carrying_chip?] == 0.0
      look_for_chip
    else
      look_for_pile
    end
    wiggle(40)
    forward
    recolor
  end

  def recolor
    @color = self[:carrying_chip?] == 1.0 ? blue : white
  end

  def look_for_chip
    if patch_here[:wood_chips] >= 1.0
      # Pick up food and head back to the nest
      self[:carrying_chip?] = 1.0
      patch_here.apply(:wood_chips) { |x| x - 1.0 }
      right(180)
    end
  end

  def look_for_pile
    if patch_here[:wood_chips] >= 1.0
      # Pick up food and head back to the nest
      self[:carrying_chip?] = 0.0
      patch_here.apply(:wood_chips) { |x| x + 1.0 }
      right(180)
    end
  end
end

class Patch < AbstractPatch
  def init
    if random(8) == 0
      self[:wood_chips] = 1.0
    else
      self[:wood_chips] = 0.0
    end
    recolor
  end

  def step
    recolor
  end

  def recolor
    n = [self[:wood_chips], 5.0].min
    b = (255.0 / 5.0 * n).to_i

    @color = StumpyCore::RGBA.from_rgb_n({0, 0, b}, 8)
  end
end

class Termites < World
  property log : Log

  def initialize(width, height, size)
    super
    @log = Log.new(["step", "piles"])
  end

  def after_step
    if @steps % 100 == 0
      piles = @patches.count { |p| p[:wood_chips] > 0.0 }
      @log.add([@steps.to_f, piles.to_f])
    end
  end
end

world = Termites.new(100, 100, 5)
world.create_turtles(100)

world.render_animated("termites", (0..50).map(&.*(200)))
world.log.write("termites.csv")
