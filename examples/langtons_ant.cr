require "../src/croco"

class LangtonsAnt < World
  def setup(n)
    clear_all
    create_turtles(n)
  end

  def turtle_init(turtle)
    turtle.color = red
    turtle.direction = 0
  end

  def turtle_step(turtle)
    turtle.ask_patch_here do |p|
      if p[:value] == 0.0 # 0.0 = white, 1.0 = black
        turtle.left
        p[:value] = 1.0
      else
        turtle.right
        p[:value] = 0.0
      end
      turtle.forward
    end
  end

  def patch_init(patch)
    patch[:value] = 0.0
  end

  def patch_step(patch)
    # display
    v = 1.0 - patch[:value]
    patch.color = StumpyPNG::RGBA.from_gray_n(v.to_i, 1)
  end
end

world = LangtonsAnt.new(50, 50)
world.setup(10)

world.run_to(100)
world.render("langtons_ant1")
world.run_to(1000)
world.render("langtons_ant2")
world.run_to(10000)
world.render("langtons_ant3")
world.run_to(100000)
world.render("langtons_ant4")
