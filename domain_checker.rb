#!/usr/bin/env ruby

TLDS = %w(com de at)
WORDS = %w(Schnitzel Auto Haus)
BUY  = 'http://www.easyname.com/de/domain/suchen/%{domain}'

NUM_SYNONYMS = 20

require 'wlapi'
require 'robowhois'
require 'dotenv'
require 'term/ansicolor'
Dotenv.load

class String
  include Term::ANSIColor
end

def domain_available?(domain)
  status = begin
    if @whois.availability(domain)["available"]
      `echo "#{ domain }" >> available.txt`
      (BUY % { domain: domain }).green
    else
      `echo "#{ domain }" >> taken.txt`
      ":("
    end
  rescue
    $!.inspect.to_s.red.bold
  end
  puts [domain, status].join(": ")
end


def checked_domains(filename)
  if File.exists?(filename)
    File.open(filename).readlines.map(&:strip)
  else
    []
  end
end

@whois     = RoboWhois.new(:api_key => ENV['API_KEY'])
@thesaurus = WLAPI::API.new

available_domains = checked_domains('available.txt')
taken_domains     = checked_domains('taken.txt')
credits_remaining = @whois.account["credits_remaining"]

puts "-" * 80
puts "Building word list."
words_and_synonyms = WORDS.uniq.inject([]){ |h,w|
  h << w.downcase
  h + [*@thesaurus.synonyms(w, NUM_SYNONYMS)].map(&:downcase).reject{ |w| w[/[^[a-z_-]]+/] }
}.uniq.shuffle

total_domains = words_and_synonyms.product(TLDS).inject([]){ |h, (word, tld)|
  h << word + '.' + tld
}
puts "Words: #{ WORDS.count }"
puts "Words and their synonyms: #{ words_and_synonyms.count }"
puts "TLDS: #{ TLDS.count }"
puts "-" * 80

puts "Total domains: #{ total_domains.count }"
if available_domains.any?
  print "Domains previously marked as "
  print "available".green.bold
  print ": #{ available_domains.count }\n"
end

if taken_domains.any?
  print "Domains previously marked as "
  print  "taken".red.bold
  print ": #{ taken_domains.count }\n"
end

domains = total_domains - available_domains - taken_domains

puts "Domains to check: #{ domains.length }"
puts "Your remaining credit at RoboWhois: #{ credits_remaining }"

if domains.length > credits_remaining
  puts "Warning: Your RoboWhois credit is too low to check all domains.".bold
end

puts "-" * 80

domains.each_index{ |index|
  if index == 0 || index % 10 == 0
    puts "#{ domains.count - index } domains left".bold
  end
  domain_available?(domains[index])
}
