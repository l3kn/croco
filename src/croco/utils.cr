module Utils
  RADIANTS = 180.0 / Math::PI

  def random(n)
    rand(0...n)
  end

  def white
    StumpyPNG::RGBA.from_rgb_n({255, 255, 255}, 8)
  end

  def black
    StumpyPNG::RGBA.from_rgb_n({  0,   0,   0}, 8)
  end

  def blue
    StumpyPNG::RGBA.from_rgb_n({  0,   0, 255}, 8)
  end

  def green
    StumpyPNG::RGBA.from_rgb_n({  0, 255,   0}, 8)
  end

  def red
    StumpyPNG::RGBA.from_rgb_n({255,   0,   0}, 8)
  end
end
