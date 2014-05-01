#!/usr/bin/env ruby

TLD = 'eu'
BUY = 'http://www.easyname.com/de/domain/suchen/%{domain}'
DOMAINS = [*?a..?z].permutation(2).map(&:join).shuffle

require 'robowhois'
require 'dotenv'
require 'term/ansicolor'
Dotenv.load

class String
  include Term::ANSIColor
end

def name_available?(name)
  domain = name + "." + TLD
  status = begin
    if @whois.availability(domain)["available"]
      (BUY % { domain: domain }).green
    else
      ":("
    end
  rescue
    $!.inspect.to_s.red.bold
  end
  puts [domain, status].join(": ")
end


@whois = RoboWhois.new(:api_key => ENV['API_KEY'])

DOMAINS.each{ |name|
  name_available?(name)
}
