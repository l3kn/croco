require "../src/croco"

class RecursiveTrees < World
  def setup
    clear_all
    create_turtles(1)
  end

  def turtle_init(turtle)
    turtle.x = 25.0
    turtle.y = 50.0
    turtle.face(25.0, 1.0)
    turtle.pen_down
    turtle.color = black

    turtle[:length] = 25.0
    turtle[:alive] = 1.0
  end

  def turtle_step(turtle)
    if turtle[:alive] == 1.0
      turtle.forward(:length)
      turtle.apply(:length) { |l| l / 2 }

      turtle.left(45)
      turtle.duplicate
      turtle.right(90)
      turtle.duplicate

      turtle.die
    end
  end
end

world = RecursiveTrees.new(50, 50, 10)
world.setup

10.times do |i|
  world.run_to(i)
  world.render("recursive_tree#{i.to_s.rjust(3, '0')}", true)
end
