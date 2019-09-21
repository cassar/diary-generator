require 'erb'
require 'active_support/all'
require 'pry'

DIARY_PATH = File.read('.diary_config').strip
TOMORROW = 'tomorrow'

def template_path(time)
  if ['Saturday', 'Sunday'].include? time.strftime("%A")
    '/typical_day_template.md'
  else
    '/typical_work_day_template.md'
  end
end

time = Time.now
time = time.tomorrow if ARGV.first == TOMORROW
ordinal_day = time.day.ordinalize
month = time.month
month_name = time.strftime '%B'
year = time.year
output = ERB.new(File.read(DIARY_PATH + template_path(time))).result
directory_path = "#{DIARY_PATH}/#{0 if month < 10}#{month}_#{month_name.downcase}"
Dir.mkdir(directory_path) unless File.exists? directory_path
File.write "#{directory_path}/#{ordinal_day}.md", output
