require "../src/croco"

class Turtle < AbstractTurtle
  def init
    @color = white
  end

  def step
    forward
    wiggle(40)

    patch_here.apply(:pheromone) { |x| x + 1 }
    sniff
  end

  def sniff
    # # Turtles with more noses
    # # tend to form more, smaller clusters,
    # # as they are less likely to wander of
    # # and join an other cluster
    # noses = [0, 45, -45, 90, -90]
    noses = [0, 45, -45]

    best_nose = noses.max_by do |nose|
      left(nose)
      forward
      value = patch_here[:pheromone]
      back
      right(nose)
      value
    end

    left(best_nose)
  end
end

class Patch < AbstractPatch
  def init
    self[:pheromone] = 0.0
  end

  def step
    # display
    n = [self[:pheromone], 3.0].min
    g = (255.0 / 3.0 * n).to_i
    @color = StumpyPNG::RGBA.from_rgb_n({0, g, 0}, 8)

    # evaporation
    apply(:pheromone) { |x| x * 0.9 }
  end
end

class SlimeMold < World
  def after_step
    diffuse(:pheromone)
  end
end

world = SlimeMold.new(50, 50)
world.create_turtles(100)

5.times do |i|
  world.run_to(10 ** i)
  world.render("slime_mold#{i}")
end
