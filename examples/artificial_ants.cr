require "../src/croco"

class ArtificialAnts < World
  def initialize(width, height)
    super
    @diffusion_rate = 0.15
    @evaporation_rate = 0.05
  end

  def setup(n)
    clear_all
    create_turtles(n)
  end

  def turtle_init(turtle)
    turtle.color = white
    turtle.x = 50.0
    turtle.y = 50.0

    # Until I find a better solution,
    # turtles and patches can only have float values
    # so we need to encode booleans in some way
    # (false = 0.0, true = 1.0)
    turtle[:carrying_food?] = 0.0
    recolor_turtle(turtle)
  end

  def turtle_step(turtle)
    if turtle[:carrying_food?] == 0.0
      look_for_food_demon(turtle)
    else
      move_towards_nest_demon(turtle)
    end
    turtle.wiggle(40)
    turtle.forward
    recolor_turtle(turtle)
  end

  def recolor_turtle(turtle)
    turtle.color = turtle[:carrying_food?] == 1.0 ? blue : white
  end

  def look_for_food_demon(turtle)
    if turtle.patch_here[:food] >= 1.0
      # Pick up food and head back to the nest
      turtle[:carrying_food?] = 1.0
      turtle.patch_here.apply(:food) { |x| x - 1.0}
      turtle.right(180)
    else
      sniff(turtle, :pheromone) if turtle.patch_here[:pheromone] < 2.0
    end
  end

  def move_towards_nest_demon(turtle)
    if turtle.patch_here[:nest?] == 1.0
      # Drop food at the nest and head back to the food source
      turtle[:carrying_food?] = 0.0
      turtle.right(180)
    else
      # Follow the nest scent and drop pheromone along the way
      turtle.patch_here.apply(:pheromone) { |x| x + 60 }
      turtle.face(50, 50)
    end
  end

  def sniff(turtle, key, distance = 1.0)
    # turtle.x = turtle.x.floor
    # turtle.y = turtle.y.floor

    # The order is important here,
    # if the pheromone level in all directions are equal
    # max_by will return the first element of the list
    noses = [0, -45, 45, -90, 90]

    best_nose = noses.max_by do |nose|
      turtle.left(nose)
      turtle.forward(distance)
      value = turtle.patch_here[key]
      turtle.back(distance)
      turtle.right(nose)

      value
    end

    turtle.left(best_nose)
  end

  def patch_init(patch)
    patch[:pheromone] = 0.0
    patch[:nest?] = 0.0
    patch[:food] = 0.0
    patch[:nest_scent] = 0.0

    setup_nest(patch)
    setup_food(patch)
    recolor_patch(patch)
  end

  def setup_nest(patch)
    distance = patch.distance(50, 50)
    if distance < 5.0
      patch[:nest?] = 1.0
      patch[:nest_scent] = 1000.0
    end
  end

  def setup_food(patch)
    if patch.distance(70, 50) < 5.0
      patch[:food] = 2.0
    end
  end

  def patch_step(patch)
    patch.apply(:pheromone) { |x| x * (1.0 - @evaporation_rate) }

    # Remove low pheromone levels,
    # so that ants don't follow the gradient
    # of a long dead trail
    patch.apply(:pheromone) { |x| x < 0.05 ? 0.0 : x }
    recolor_patch(patch)
  end

  def recolor_patch(patch)
    r = patch[:nest?] * 255.0

    n = [patch[:food], 4.0].min
    b = (255.0 / 4.0 * n).to_i

    max_pheromone = 100.0
    n = [patch[:pheromone], max_pheromone].min
    g = (255.0 / max_pheromone * n).to_i

    patch.color = StumpyPNG::RGBA.from_rgb_n({r, g, b}, 8)
  end

  def after_init
    100.times { diffuse(:nest_scent) }
  end

  def after_step
    # Use this instead of patch.diffuse,
    # because diffusion happens to all patches at once,
    # not one after another
    diffuse(:pheromone, @diffusion_rate)
  end
end

world = ArtificialAnts.new(100, 100)
world.setup(100)

100.times do |i|
  world.run_to(10 * (i + 1))
  world.render("artificial_ants#{i.to_s.rjust(2, '0')}", 5)
end
