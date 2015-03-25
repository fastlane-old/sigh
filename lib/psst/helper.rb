require 'zlib'

module FastlaneCore
  class Psst
    # Is used to unzip compress server responses
    def unzip(resp)
      Zlib::GzipReader.new(StringIO.new(resp.body)).read
    rescue
      puts "Something went wrong with the following request: #{resp.data}"
      return nil
    end
  end
end