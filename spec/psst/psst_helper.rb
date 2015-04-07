require 'pry'
require 'psst/psst'
require 'psst/psst_stubbing'

ENV["DELIVER_USER"] = "sigh@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"

require 'sigh/options'

FastlaneCore::CommanderGenerator.new.generate(Sigh::Options.available_options)
Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, {})