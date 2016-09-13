require "../src/croco"

class ArtificialAnts < World
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
    turtle[:drop_size] = 0.0
  end

  def turtle_step(turtle)
    look_for_food_demon(turtle)
    return_to_nest_demon(turtle)
    turtle.forward
  end

  def look_for_food_demon(turtle)
    if turtle[:carrying_food?] == 0.0
      if turtle.patch_here[:food] >= 1.0
        # Pick up food and head back to the nest
        turtle[:carrying_food?] = 1.0
        turtle.patch_here.apply(:food) { |x| x - 1.0}
        turtle[:drop_size] = 100.0
        turtle.color = blue

        turtle.right(180)
      else
        # Try to follow the pheromone gradient
        # or move around randomly, if there is none
        if turtle.patch_here[:pheromone] < 0.2
          turtle.wiggle(40)
        else
          sniff(turtle, :pheromone)
        end
      end
    end
  end

  def return_to_nest_demon(turtle)
    if turtle[:carrying_food?] == 1.0
      if turtle.patch_here[:nest?] == 1.0
        # Drop food at the nest and head back to the food source
        turtle[:carrying_food?] = 0.0
        turtle.color = white

        turtle.right(180)
      else
        # Follow the nest scent and drop pheromone along the way
        turtle.patch_here.apply(:pheromone) { |x| x + turtle[:drop_size] }
        turtle.apply(:drop_size) { |x| {0.0, x - 3.0}.max }

        sniff(turtle, :nest_scent)
      end
    end
  end

  def sniff(turtle, key, distance = 3.0)
    noses = [-135, -90, -45, 0, 45, 90, 135]

    values = noses.map do |nose|
      turtle.left(nose)
      turtle.forward(distance)
      value = turtle.patch_here[key]
      turtle.back(distance)
      turtle.right(nose)
      {value, nose}
    end

    best_nose = values.max_by(&.first)[1]
    turtle.left(best_nose)
  end

  def patch_init(patch)
    patch[:pheromone] = 0.0
    patch[:nest_scent] = 0.0
    patch[:nest?] = 0.0

    setup_nest(patch)
    setup_food(patch)
  end

  def setup_nest(patch)
    distance = patch.distance(50, 50)
    if distance < 5.0
      patch[:nest?] = 1.0
      # patch[:nest_scent] = 1000.0
    else
      patch[:nest?] = 0.0
    end
    # Currently, it is not possible to use patch.diffuse
    # at this place in the program.
    # As a workaround, we need to create a scent gradient “by hand”
    patch[:nest_scent] = 1000.0 / (distance / 5.0)
  end

  def setup_food(patch)
    if patch.distance(80, 50) < 4.0
      patch[:food] = rand(1.0..4.0)
    else
      patch[:food] = 0.0
    end
  end

  def patch_step(patch)
    patch.diffuse(:pheromone, 0.15)
    patch.apply(:pheromone) { |x| x * 0.98 }

    if patch[:nest?] == 1.0
     patch.color = red
    elsif patch[:food] > 0.0
      patch.color = blue
    else
      max_pheromone = 100.0
      n = [patch[:pheromone], max_pheromone].min
      g = (255.0 / max_pheromone * n).to_i

      # n = [patch[:nest_scent], 1000.0].min
      # r = (255.0 / 1000.0 * n).to_i
      r = 0
      patch.color = StumpyPNG::RGBA.from_rgb_n({r, g, 0}, 8)
    end

  end
end

world = ArtificialAnts.new(100, 100)
world.setup(30)

100.times do |i|
  world.run_to(10 * (i + 1))
  world.render("artificial_ants#{i.to_s.rjust(2, '0')}", 5)
end
