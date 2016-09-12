module Helper
  def self.line(x0, y0, x1, y1, canvas, color)

    steep = (y1 - y0).abs > (x1 - x0).abs

    if steep
      x0, y0 = {y0, x0}
      x1, y1 = {y1, x1}
    end

    if x0 > x1
      x0, x1 = {x1, x0}
      y0, y1 = {y1, y0}
    end

    delta_x = x1 - x0
    delta_y = (y1 - y0).abs

    error = (delta_x / 2).to_i

    ystep = y0 < y1 ? 1 : -1
    y = y0

    ((x0.to_i)...(x1.to_i)).each do |x|
      if steep
        set_pixel(y, x, canvas, color)
      else
        set_pixel(x, y, canvas, color)
      end

      error -= delta_y
      if error < 0.0
        y += ystep
        error += delta_x
      end
    end
  end

  def self.circle(x0, y0, radius, canvas, color)
    x = radius
    y = 0
    err = 0

    while x >= y
      set_pixel(x0 + x, y0 + y, canvas, color)
      set_pixel(x0 + y, y0 + x, canvas, color)
      set_pixel(x0 - x, y0 + y, canvas, color)
      set_pixel(x0 - y, y0 + x, canvas, color)
      set_pixel(x0 + x, y0 - y, canvas, color)
      set_pixel(x0 + y, y0 - x, canvas, color)
      set_pixel(x0 - x, y0 - y, canvas, color)
      set_pixel(x0 - y, y0 - x, canvas, color)

      y += 1
      err += 1 + 2*y

      if 2*(err - x) + 1 > 0
        x -= 1
        err += 1 - 2*x
      end
    end
  end

  def self.set_pixel(x, y, canvas, color)
    canvas[x.to_i % canvas.width, y.to_i % canvas.height] = color
  end
end
