# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



#
#whenever --set environment=development --update-crontab

#@dev = "/Users/eczerega/Desktop/taleer/appname/jobs/stock.txt"
#@production = "/home/administrator/appname/jobs/stock.txt"

=begin produccion
 every 10.minutes do
   command "ruby /home/administrator/appname/jobs/up.rb"
 end

 every 30.minutes do
   command "ruby /home/administrator/appname/jobs/up2.rb"
 end

 every 2.hours do
   command "ruby /home/administrator/appname/jobs/up3.rb"
 end
=end

=begin dev
 every 10.minutes do
   command "ruby /Users/eczerega/Desktop/taleer/appname/jobs/up.rb"
 end

 every 30.minutes do
   command "ruby /Users/eczerega/Desktop/taleer/appname/jobs/up2.rb"
 end

 every 2.hours do
   command "ruby /Users/eczerega/Desktop/taleer/appname/jobs/up3.rb"
 end
=end



 every 1.minutes do
   command "ruby /Users/eczerega/Desktop/taleer/appname/jobs/up.rb"
 end

 every 2.minutes do
   command "ruby /Users/eczerega/Desktop/taleer/appname/jobs/up2.rb"
 end

 every 3.minutes do
   command "ruby /Users/eczerega/Desktop/taleer/appname/jobs/up3.rb"
 end




