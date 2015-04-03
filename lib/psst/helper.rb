require 'zlib'

module FastlaneCore
  module Psst
    class Client
      # Is used to unzip compress server responses
      def unzip(resp)
        Zlib::GzipReader.new(StringIO.new(resp.body)).read
      rescue
        Helper.log.error "Something went wrong with the following request: #{resp.data}"
        return nil
      end
    end
  end
end