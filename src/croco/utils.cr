require "stumpy_png"

module Utils
  RADIANTS = 180.0 / Math::PI

  def random(n)
    rand(0...n)
  end

  def white
    StumpyCore::RGBA.from_rgb_n({255, 255, 255}, 8)
  end

  def black
    StumpyCore::RGBA.from_rgb_n({  0,   0,   0}, 8)
  end

  def blue
    StumpyCore::RGBA.from_rgb_n({  0,   0, 255}, 8)
  end

  def green
    StumpyCore::RGBA.from_rgb_n({  0, 255,   0}, 8)
  end

  def red
    StumpyCore::RGBA.from_rgb_n({255,   0,   0}, 8)
  end
end
