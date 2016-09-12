require "../src/croco"

class SlimeMold < World
  def setup(n)
    clear_all
    create_turtles(n)
  end

  def turtle_init(turtle)
    turtle.color = white
  end

  def turtle_step(turtle)
    # walk
    turtle.forward(1)

    # wiggle
    turtle.left(random 40)
    turtle.right(random 40)

    # drop pheromone
    turtle.ask_patch_here do |p|
      # p.set(:pheromone, p.get(:pheromone) + 1)
      p.apply(:pheromone) { |x| x + 1 }
    end

    sniff(turtle)
  end

  def sniff(turtle)
    noses = [-45, 0, 45]

    # # Turtles with more noses
    # # tend to form more, smaller clusters,
    # # as they are less likely to wander of
    # # and join an other cluster
    # noses = [-90, -45, 0, 45, 90]

    values = noses.map do |nose|
      turtle.left(nose)
      turtle.forward
      value = turtle.patch_here.get(:pheromone)
      turtle.back
      turtle.right(nose)
      {value, nose}
    end

    best_nose = values.max_by(&.first)[1]
    turtle.left(best_nose)
  end

  def patch_init(patch)
    patch.set(:pheromone, 0.0)
  end

  def patch_step(patch)
    # display
    n = [patch.get(:pheromone), 3.0].min
    g = (255.0 / 3.0 * n).to_i
    patch.color = StumpyPNG::RGBA.from_rgb_n({0, g, 0}, 8)

    # diffusion
    patch.diffuse(:pheromone)

    # evaporation
    patch.set(:pheromone, patch.get(:pheromone) * 0.90)
  end
end

world = SlimeMold.new(50, 50)
world.setup(100)

6.times do |i|
  world.run_to(10 ** i)
  world.render("slime_mold#{i}")
end
