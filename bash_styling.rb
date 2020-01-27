module BashStyling
  RED = 31
  GREEN = 32

  def in_green(text)
    in_colour text, GREEN
  end

  def in_red(text)
    in_colour text, RED
  end

  def in_colour(text, colour)
    "\e[1;#{colour}m#{text}\e[0m"
  end

  def in_shell_format(*paths)
    paths.map { |p| p.gsub(/\s/, '\ ') }.join ' '
  end
end
