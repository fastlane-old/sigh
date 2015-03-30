require 'plist'
require 'fastlane_core'

module Sigh
  class Manager
    # Types of certificates
    LIST = "list"
    CLEANUP = "cleanup"

    def run(options, args)
      command, clean_team_provisioning, clean_custom_pattern = get_inputs(options, args)
      if command == LIST
        list_profiles
      elsif command == CLEANUP
        pattern = clean_team_provisioning
        pattern = clean_custom_pattern if clean_custom_pattern
        cleanup_profiles(pattern)
      end
    end

    def self.start
      path = Sigh::DeveloperCenter.new.run

      return nil unless path

      if Sigh.config[:filename]
        file_name = Sigh.config[:filename]
      else
        file_name = File.basename(path)
      end

      output = File.join(Sigh.config[:output_path].gsub("~", ENV["HOME"]), file_name)
      (FileUtils.mv(path, output) rescue nil) # in case it already exists

      install_profile(output) unless Sigh.config[:skip_install]

      puts output.green

      return File.expand_path(output)
    end

    def self.install_profile(profile)
      Helper.log.info "Installing provisioning profile..."
      profile_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/"
      profile_filename = ENV["SIGH_UDID"] + ".mobileprovision"
      destination = profile_path + profile_filename

      # copy to Xcode provisioning profile directory
      FileUtils.copy profile, destination

      if File.exists? destination
        Helper.log.info "Profile installed at \"#{destination}\""
      else
        raise "Failed installation of provisioning profile at location: #{destination}".red
      end
    end

    def get_inputs(options, args)
      command = args.first || LIST
      clean_team_provisioning = /iOS\ {0,1}Team Provisioning Profile: \w/ if options.clean_team_provisioning
      clean_custom_pattern = /#{options.clean_custom_pattern}/ if options.clean_custom_pattern
      return command, clean_team_provisioning, clean_custom_pattern
    end

    def list_profiles
      profiles = load_profiles

      Helper.log.info "Provisioning profiles installed"
      Helper.log.info "Valid profiles:"
      profiles_valid = profiles.select { |profile| profile["ExpirationDate"] > DateTime.now }
      profiles_valid.each do |profile|
        Helper.log.info profile["Name"].green
      end
      
      Helper.log.info "-----------------"
      Helper.log.info "Expired profiles:"
      profiles_expired = profiles.select { |profile| profile["ExpirationDate"] < DateTime.now }
      profiles_expired.each do |profile|
        Helper.log.info profile["Name"].red
      end
      
      Helper.log.info "-------"
      Helper.log.info "Summary"
      Helper.log.info "#{profiles.length} installed profiles"
      Helper.log.info "#{profiles_expired.length} are expired"
      Helper.log.info "#{profiles_valid.length} are valid"
    end

    def cleanup_profiles(pattern = nil)
      profiles = load_profiles.select { |profile| profile["ExpirationDate"] < DateTime.now || (pattern != nil && profile["Name"] =~ pattern) }

      Helper.log.info "The following provisioning profiles are either expired or matches your pattern:"
      profiles.each do |profile|
        Helper.log.info profile["Name"].red
      end

      if agree("Delete these provisioning profiles? (y/n)  ", true)
        Helper.log.info "Deleting #{profiles.length} profiles"
        profiles.each do |profile|
          File.delete profile["Path"]
        end
      end
    end

    def load_profiles
      Helper.log.info "Loading Provisioning profiles from ~/Library/MobileDevice/Provisioning Profiles/"
      profiles_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/*.mobileprovision"
      profile_paths = Dir[profiles_path]

      profiles = []
      profile_paths.each do |profile_path|
        profile = Plist::parse_xml(`security cms -D -i '#{profile_path}'`)
        profile['Path'] = profile_path
        profiles << profile
      end

      profiles = profiles.sort_by {|profile| profile["Name"].downcase}

      return profiles
    end
  end
end