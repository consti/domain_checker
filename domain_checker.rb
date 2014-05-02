#!/usr/bin/env ruby

TLDS = %w(com de at)
WORDS = %w(computer home happy sad)
LANG = :en # :de
BUY  = 'http://www.easyname.com/de/domain/suchen/%{domain}'

NUM_SYNONYMS = 20

require 'wlapi'
require 'wordnik'
require 'robowhois'
require 'dotenv'
require 'term/ansicolor'
Dotenv.load

class String
  include Term::ANSIColor
end

def downcase_and_filter_words
  WORDS.uniq.inject([]){ |h,word|
    h << word.downcase
    h + yield(word).map(&:downcase).reject{ |w| w[/[^[a-z_-]]+/] }
  }.uniq.shuffle
end

case LANG
when :en
  Wordnik.configure do |config|
    config.api_key = ENV['WORDNIK_API_KEY']
    config.logger = Logger.new('/dev/null')
  end
  words_and_synonyms = downcase_and_filter_words { |word|
    resp = Wordnik.word.get_related(word.downcase, :type => 'synonym')
    if resp.any? && resp.first["words"]
      [*resp.first["words"]]
    else
      []
    end
  }
when :de
  thesaurus = WLAPI::API.new
  words_and_synonyms = downcase_and_filter_words { |word|
    [*thesaurus.synonyms(word, NUM_SYNONYMS)]
  }
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

@whois     = RoboWhois.new(:api_key => ENV['ROBOWHOIS_API_KEY'])

available_domains = checked_domains('available.txt')
taken_domains     = checked_domains('taken.txt')
credits_remaining = @whois.account["credits_remaining"]

puts "-" * 80
puts "Building word list."
puts "-" * 80

total_domains = words_and_synonyms.product(TLDS).inject([]){ |h, (word, tld)|
  h << word + '.' + tld
}

@robo = -1
def robo(t)
  @robo += 1
  "\t" * t +
    [   " ..............\n",
        " .  *      *  .\n",
        "[.      '     .]\n",
        " .            .\n",
        " .     \\_/    .\n",
        " ..............\n"][@robo]

end

puts "  #{ WORDS.count }\t| Words" + robo(6)
puts "+ #{ words_and_synonyms.count - WORDS.count }\t| Synonyms" + robo(5)
puts "* #{ TLDS.count }\t| TLDS" + robo(6)
puts "-" * 40  + robo(2)
puts "  #{ total_domains.count }\t  Variations" + robo(5)
puts "-" * 40 + robo(2)

if available_domains.any? || taken_domains.any?
  if available_domains.any?
    print "- #{ total_domains.count - (total_domains - available_domains).count }\t| Domains previously marked as "
    print "available".green.bold
    print "\n"
  end

  if taken_domains.any?
    print "- #{ total_domains.count - (total_domains - taken_domains).count }\t| Domains previously marked as "
    print  "taken".red.bold
    print "\n"
  end
puts  "-" * 40
end

domains = total_domains - available_domains - taken_domains

print "  "
print "#{ domains.length }".bold
print "\t  Domains to check\n"
puts  "-" * 80
puts  "Your remaining credit at RoboWhois: #{ credits_remaining }"

if domains.length > credits_remaining
  puts "Warning: Your RoboWhois credit is too low to check all domains.".bold
else
  puts "We are good to go! \\o/"
end
puts "-" * 80

domains.each_index{ |index|
  if index == 0 || index % 10 == 0
    puts "#{ domains.count - index } domains left".bold
  end
  domain_available?(domains[index])
}
