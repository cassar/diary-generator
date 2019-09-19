require 'erb'
require 'active_support/all'
require 'pry'

PATH = "/Users/lukecassar/Google\ Drive/Personal\ Organisation\ Stuff/Diary/2019"
TOMORROW = 'tomorrow'

time = Time.now
time = time.tomorrow if ARGV.first == TOMORROW
ordinal_day = time.day.ordinalize
month = time.month
month_name = time.strftime '%B'
year = time.year
output = ERB.new(File.read(PATH + '/typical_work_day_template.md')).result
directory_name = "#{0 if month < 10}#{month}_#{month_name.downcase}"
Dir.mkdir(directory_name) unless File.exists? directory_name
File.write "#{PATH}/#{directory_name}/#{ordinal_day}.md", output
