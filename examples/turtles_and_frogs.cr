require "../src/croco"

class TurtlesAndFrogs < World
  def initialize(width, height)
    super
  end

  def setup(n)
    clear_all
    create_turtles(n)
  end

  def turtle_init(turtle)
    turtle[:test_distance] = 0.0
    turtle[:minimum_percentage] = 0.7

    # Move turtle to the center of its patch
    turtle.x = turtle.x.floor + 0.5
    turtle.y = turtle.y.floor + 0.5

    # Guarantee that there is only one turtle on each patch
    if turtle.patch_here.turtles.size > 1
      new_patch = @patches.select { |p| p.turtles.size == 0 }.sample
      turtle.x = new_patch.x + 0.5
      turtle.y = new_patch.y + 0.5
    end

    # 0.0 => turtle
    # 1.0 => frog
    turtle[:type] = random(2).to_f
    turtle.color = turtle[:type] == 0.0 ? red : blue
  end

  def turtle_step(turtle)
    patch = turtle.patch_here

    if turtle[:type] == 0.0
      if turtle_neighbours(patch) < (turtle[:minimum_percentage] * total_neighbours(patch))
        find_free_patch(turtle)
      end
    else
      if frog_neighbours(patch) < (turtle[:minimum_percentage] * total_neighbours(patch))
        find_free_patch(turtle)
      end
    end

    turtle.x = turtle.x.floor + 0.5
    turtle.y = turtle.y.floor + 0.5
  end

  def find_free_patch(turtle)
    turtle.direction = 45 * random(8)
    turtle[:test_distance] = 1.0 + random(5)

    # Currently,
    # there is no function
    # to check out the patch in a given direction + distance.
    # As a workaround,
    # we simply go forward,
    # and turn back if we are not the only animal on the patch
    turtle.forward(:test_distance)
    unless turtle.patch_here.turtles.size == 1
      turtle.back(:test_distance)
    end
  end

  def turtle_neighbours(patch)
    patch.neighbours.map(&.turtles).flatten.count { |t| t[:type] == 0.0 }
  end

  def frog_neighbours(patch)
    patch.neighbours.map(&.turtles).flatten.count { |t| t[:type] == 1.0 }
  end

  def total_neighbours(patch)
    patch.neighbours.map(&.turtles).flatten.size
  end
end

world = TurtlesAndFrogs.new(50, 50)
world.silent = true
world.setup((50 * 50 * 0.7).to_i)

world.run_to(1)
50.times do |i|
  world.run_to(i)

  turtles = world.turtles.select { |t| t[:type] == 0.0 }
  frogs =   world.turtles.select { |t| t[:type] == 1.0 }

  all = 0
  unhappy = 0

  turtles.each do |t|
    total = world.total_neighbours(t.patch_here)
    if (world.turtle_neighbours(t.patch_here).to_f / total) < t[:minimum_percentage]
      unhappy += 1
    elsif t.patch_here.turtles.size > 1
      unhappy += 1
    end
    all += 1
  end

  frogs.each do |t|
    total = world.total_neighbours(t.patch_here)
    if (world.frog_neighbours(t.patch_here).to_f / total) < t[:minimum_percentage]
      unhappy += 1
    elsif t.patch_here.turtles.size > 1
      unhappy += 1
    end
    all += 1
  end

  puts "#{i}\t#{unhappy.to_f / all}"
  world.render("turtles_and_frogs#{i.to_s.rjust(3, '0')}", 10, true)
end
