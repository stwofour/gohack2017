#! /usr/bin/env ruby
# ruby 2.2.4p230 (2015-12-16 revision 53155) [x86_64-darwin14]

require 'SecureRandom'
require 'date'

beginning_of_2015 = Time.mktime(2015, 1, 7)
mid_2017 = Time.mktime(2017, 7, 1)

def add_minutes(time, m)
  time + m * 60
end

current = beginning_of_2015
File.open(File.dirname(__FILE__) + "/../data/number_of_requests_domlur_region_3_#{Time.now.to_i}.csv", "w+") do |file|
  file.puts ["window", "requested_rides"].join(",")

  while current <= mid_2017 do
    # let's assume that we generate
    # between 1 and 4 ride requests during normal hours...
    # between 3 and 6 ride requests during peak hours...
    # between 1 and 6 ride requests during normal hours between Sept and Feb as B'lore will have lots of incoming tourists (source: web)
    # between 1 and 8 ride requests during peak hours between Sept and Feb as B'lore will have lots of incoming tourists (source: web)
    max_number_of_configured_rides = if [1,2,9,10,11,12].include?(current.month)
                                       6
                                     else
                                       4
                                     end

    number_of_requested_rides = SecureRandom.random_number(max_number_of_configured_rides) + 1 # at least one ride

    if (current.hour >= 7 and current.hour <= 10) || (current.hour >= 16 and current.hour <= 19) # peak hour?
      number_of_requested_rides += 2 # at least two rides during peak hours
    end

    file.puts [current.strftime("%F %T"), number_of_requested_rides].join(",")
    current = add_minutes(current, 10)
  end
end



