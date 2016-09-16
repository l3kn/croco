require "../src/croco"

class Turtle < AbstractTurtle
  def init
    self[:test_distance] = 0.0
    self[:minimum_percentage] = 0.7

    # Move turtle to the center of its patch
    @x = @x.floor + 0.5
    @y = @y.floor + 0.5

    # Guarantee that there is only one turtle on each patch
    if patch_here.turtles.size > 1
      new_patch = @world.patches.select { |p| p.turtles.size == 0 }.sample
      x = new_patch.x + 0.5
      y = new_patch.y + 0.5
    end

    # 0.0 => turtle
    # 1.0 => frog
    self[:type] = random(2).to_f
    @color = self[:type] == 0.0 ? red : blue
  end

  def step
    patch = patch_here

    if self[:type] == 0.0
      if patch.turtle_neighbours < (self[:minimum_percentage] * patch.total_neighbours)
        find_free_patch
      end
    else
      if patch.frog_neighbours < (self[:minimum_percentage] * patch.total_neighbours)
        find_free_patch
      end
    end

    @x = @x.floor + 0.5
    @y = @y.floor + 0.5
  end

  def find_free_patch
    direction = 45 * random(8)
    self[:test_distance] = 1.0 + random(5)

    # Currently,
    # there is no function
    # to check out the patch in a given direction + distance.
    # As a workaround,
    # we simply go forward,
    # and turn back if we are not the only animal on the patch
    forward(:test_distance)
    unless patch_here.turtles.size == 1
      back(:test_distance)
    end
  end

end

class Patch < AbstractPatch
  def turtle_neighbours
    neighbours.map(&.turtles).flatten.count { |t| t[:type] == 0.0 }
  end

  def frog_neighbours
    neighbours.map(&.turtles).flatten.count { |t| t[:type] == 1.0 }
  end

  def total_neighbours
    neighbours.map(&.turtles).flatten.size
  end
end

class TurtlesAndFrogs < World
end

world = TurtlesAndFrogs.new(50, 50, 10)
world.silent = true
world.create_turtles((50 * 50 * 0.9).to_i)

world.run_to(1)
200.times do |i|
  world.run_to(i)

  turtles = world.turtles.select { |t| t[:type] == 0.0 }
  frogs =   world.turtles.select { |t| t[:type] == 1.0 }

  all = 0
  unhappy = 0

  turtles.each do |t|
    total = t.patch_here.total_neighbours
    if (t.patch_here.turtle_neighbours.to_f / total) < t[:minimum_percentage]
      unhappy += 1
    elsif t.patch_here.turtles.size > 1
      unhappy += 1
    end
    all += 1
  end

  frogs.each do |t|
    total = t.patch_here.total_neighbours
    if (t.patch_here.frog_neighbours.to_f / total) < t[:minimum_percentage]
      unhappy += 1
    elsif t.patch_here.turtles.size > 1
      unhappy += 1
    end
    all += 1
  end

  puts "#{i}\t#{unhappy.to_f / all}"
  world.render("turtles_and_frogs#{i.to_s.rjust(3, '0')}", true)
end
