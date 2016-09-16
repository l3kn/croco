require "../src/croco"

class Turtle < AbstractTurtle
  def init
    @color = red
    @direction = 0.0
  end

  def step
    if patch_here[:value] == 0.0
      left
      patch_here[:value] = 1.0
    else
      right
      patch_here[:value] = 0.0
    end
    forward
  end
end

class Patch < AbstractPatch
  def init
    self[:value] = 0.0
  end

  def step
    @color = self[:value] == 1.0 ? black : white
  end
end

class LangtonsAnt < World
end

world = LangtonsAnt.new(50, 50)
world.create_turtles(10)

world.run_to(100)
world.render("langtons_ant1")
world.run_to(1000)
world.render("langtons_ant2")
world.run_to(10000)
world.render("langtons_ant3")
world.run_to(100000)
world.render("langtons_ant4")
