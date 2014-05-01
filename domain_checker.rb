#!/usr/bin/env ruby

TLD = 'de'
BUY = 'http://www.easyname.com/de/domain/suchen/%{domain}'

WORDS = %w(Schnitzel Computer Hund)
NUM_SYNONYMS = 20

require 'wlapi'
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


@whois     = RoboWhois.new(:api_key => ENV['API_KEY'])
@thesaurus = WLAPI::API.new

names = WORDS.inject([]){ |h,w|
  h + [*@thesaurus.synonyms(w, NUM_SYNONYMS)].map(&:downcase).reject{ |w| w[/[^[a-z_-]]+/] }
}

(names + WORDS.map(&:downcase)).uniq.shuffle.each{ |name|
  name_available?(name)
}
