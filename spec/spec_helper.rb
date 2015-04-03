require 'sigh'
require 'psst/psst_helper' # Excon stubbing

# This module is only used to check the environment is currently a testing env
module SpecHelper
end


module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end