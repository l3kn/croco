require "../src/croco"

class Turtle < AbstractTurtle
  def init
    @x = 25.0
    @y = 50.0
    face(25.0, 1.0)
    pen_down
    @color = black

    self[:length] = 25.0
    self[:alive] = 1.0
  end

  def step
    if self[:alive] == 1.0
      forward(:length)
      old_length = self[:length]

      self[:length] = old_length * rand(0.4..0.7)
      left(45)
      duplicate

      self[:length] = old_length * rand(0.4..0.7)
      right(90)
      duplicate

      die
    end
  end
end

class Patch < AbstractPatch
end

class RecursiveTrees < World
end

world = RecursiveTrees.new(50, 50, 10)
world.create_turtles(1)

10.times do |i|
  world.run_to(i)
  world.render("recursive_tree#{i.to_s.rjust(3, '0')}", true)
end
