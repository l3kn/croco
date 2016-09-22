require "../src/croco"

class Turtle < AbstractTurtle
  def init
    @color = white
    @x = 50.0
    @y = 50.0

    # Until I find a better solution,
    # turtles and patches can only have float values
    # so we need to encode booleans in some way
    # (false = 0.0, true = 1.0)
    self[:carrying_food?] = 0.0
    recolor
  end

  def step
    if self[:carrying_food?] == 0.0
      look_for_food
    else
      move_towards_nest
    end
    wiggle(40)
    forward
    recolor
  end

  def recolor
    @color = self[:carrying_food?] == 1.0 ? blue : white
  end

  def look_for_food
    if patch_here[:food] >= 1.0
      # Pick up food and head back to the nest
      self[:carrying_food?] = 1.0
      patch_here.apply(:food) { |x| x - 1.0}
      right(180)
    else
      sniff(:pheromone) if patch_here[:pheromone] < 2.0
    end
  end

  def move_towards_nest
    if patch_here[:nest?] == 1.0
      # Drop food at the nest and head back to the food source
      self[:carrying_food?] = 0.0
      right(180)
    else
      # Follow the nest scent and drop pheromone along the way
      patch_here.apply(:pheromone) { |x| x + 60 }
      sniff(:nest_scent)
    end
  end

  def sniff(key, distance = 1.0)
    # x = x.floor
    # y = y.floor

    # The order is important here,
    # if the pheromone level in all directions are equal
    # max_by will return the first element of the list
    noses = [0, -45, 45, -90, 90]

    best_nose = noses.max_by do |nose|
      left(nose)
      forward(distance)
      value = patch_here[key]
      back(distance)
      right(nose)

      value
    end

    left(best_nose)
  end
end

class Patch < AbstractPatch
  def init
    self[:pheromone] = 0.0
    self[:nest?] = 0.0
    self[:food] = 0.0
    self[:nest_scent] = 0.0

    self[:evaporation_rate] = 0.05

    setup_nest
    setup_food
    recolor
  end

  def setup_nest
    distance = distance(50, 50)
    if distance < 5.0
      self[:nest?] = 1.0
      self[:nest_scent] = 1000.0
    end
  end

  def setup_food
    if distance(70, 50) < 5.0
      self[:food] = 2.0
    end
  end

  def step
    apply(:pheromone) { |x| x * (1.0 - self[:evaporation_rate]) }

    # Remove low pheromone levels,
    # so that ants don't follow the gradient
    # of a long dead trail
    apply(:pheromone) { |x| x < 0.05 ? 0.0 : x }
    recolor
  end

  def recolor
    r = self[:nest?] * 255.0

    n = [self[:food], 4.0].min
    b = (255.0 / 4.0 * n).to_i

    max_pheromone = 100.0
    n = [self[:pheromone], max_pheromone].min
    g = (255.0 / max_pheromone * n).to_i

    @color = StumpyCore::RGBA.from_rgb_n({r, g, b}, 8)
  end
end

class ArtificialAnts < World
  def initialize(width, height, size)
    super
    @diffusion_rate = 0.15
  end
  
  def after_init
    100.times { diffuse(:nest_scent) }
  end

  def after_step
    # Use this instead of diffuse,
    # because diffusion happens to all patches at once,
    # not one after another
    diffuse(:pheromone, @diffusion_rate)
  end
end

world = ArtificialAnts.new(100, 100, 5)
world.create_turtles(100)

100.times do |i|
  world.run_to(10 * (i + 1))
  world.render("artificial_ants#{i.to_s.rjust(2, '0')}")
end
