# frozen_string_literal: true

# Styling for generator output
module BashStyling
  RED = 31
  GREEN = 32
  BLUE = 34

  def in_green(text)
    in_colour text, GREEN
  end

  def in_red(text)
    in_colour text, RED
  end

  def in_blue(text)
    in_colour text, BLUE
  end

  def in_colour(text, colour)
    "\e[1;#{colour}m#{text}\e[0m"
  end

  def in_shell_format(*paths)
    paths.map { |p| p.gsub(/\s/, '\ ') }.join ' '
  end
end
