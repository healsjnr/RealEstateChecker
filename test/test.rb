require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib/RealEstateChecker')

begin
  checker = RealEstateChecker::Worker.new 1
  checker.get_page_data
  checker.output
rescue Exception => e
  puts e
  puts e.backtrace
end
