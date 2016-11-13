require "stumpy_utils"

module Helper
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

  def self.filled_circle(x0, y0, radius, canvas, color)
    x = radius
    y = 0
    err = 0

    while x >= y
      StumpyUtils.line(canvas,
                       (x0 - x).to_i, (y0 + y).to_i,
                       (x0 + x).to_i, (y0 + y).to_i,
                       color)
      StumpyUtils.line(canvas,
                       (x0 - y).to_i, (y0 + x).to_i,
                       (x0 + y).to_i, (y0 + x).to_i,
                       color)
      StumpyUtils.line(canvas,
                       (x0 - x).to_i, (y0 - y).to_i,
                       (x0 + x).to_i, (y0 - y).to_i,
                       color)
      StumpyUtils.line(canvas,
                       (x0 - y).to_i, (y0 - x).to_i,
                       (x0 + y).to_i, (y0 - x).to_i,
                       color)
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
