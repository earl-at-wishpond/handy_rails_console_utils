# Easy reloading of this file
def uload(reload_routes = false)
  @rails_routes_loaded = !reload_routes
  puts "Reloading #{__FILE__}..."
  load __FILE__
end

require 'active_record'

# Easier-to-read ActiveRecord inspection
class ActiveRecord::Base
  def self.fields
    inspect[/\((.*)\)/, 1].split(', ')
  end
end

class ActiveRecord::Base
  def self.[](id)
    self.find_by_id(id)
  end
end


# Load up the routes so you can call url_for-based magic methods
require 'action_controller'
def rails_routes
  unless @rails_routes_loaded
    puts "Loading routes..."
    include ActionController::UrlWriter
    default_url_options[:host] = 'localhost:3000'
    @rails_routes_loaded = true
  end
end

rails_routes


# Access the console history
def history
  Readline::HISTORY.to_a
end

def hgrep(match)
  matched = history.select {|h| Regexp.new(match).match(h)}
  puts matched
  matched.size
end


# Easy access to the fields/methods of a collection of duck-homogeneous objects
module Enumerable
  def mcollect(*syms)
    self.collect do |elem|
      syms.inject([]) do |collector, sym|
        collector << elem.send(sym)
      end
    end
  end
end


# Handy alias for the split method
class String
  alias / split
end


# Add JavaScript-like accessing of hash values by key
# Notice that this WILL NOT override any existing methods (magic or mundane)
class Hash
  def method_missing(sym, *args, &block)
    begin
      super
    rescue NoMethodError => nme
      if self.has_key?(sym)
        self.fetch(sym)
      elsif self.has_key?(sym.to_s)
        self.fetch(sym.to_s)
      elsif pos = sym.to_s =~ /(=$)/
        self.send(:store, sym.to_s[0..pos-1].to_sym, *args)
      else
        raise nme
      end
    end
  end

  def respond_to?(sym, include_private = false)
    super || self.has_key?(sym)
  end
end

