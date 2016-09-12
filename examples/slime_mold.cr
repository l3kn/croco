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
      p.set(:pheromone, p.get(:pheromone) + 1)
    end

    sniff(turtle)
  end

  def sniff(turtle)
    turtle.left(45)
    turtle.forward(1)
    v1 = turtle.patch_here.get(:pheromone)
    turtle.back(1)

    turtle.right(45)
    turtle.forward(1)
    v2 = turtle.patch_here.get(:pheromone)
    turtle.back(1)

    turtle.right(45)
    turtle.forward(1)
    v3 = turtle.patch_here.get(:pheromone)
    turtle.back(1)

    if v1 > v2 && v1 > v3
      turtle.left(90)
    elsif v2 > v1 && v2 > v3
      turtle.left(45)
    end
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

world.run_to(1)
world.render("slime_mold1")
world.run_to(20)
world.render("slime_mold2")
world.run_to(40)
world.render("slime_mold3")
world.run_to(60)
world.render("slime_mold4")
world.run_to(80)
world.render("slime_mold5")
world.run_to(100)
world.render("slime_mold6")
world.run_to(200)
world.render("slime_mold7")
world.run_to(500)
world.render("slime_mold8")
world.run_to(1000)
world.render("slime_mold9")
world.run_to(2000)
world.render("slime_mold10")
