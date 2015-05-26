require 'plist'

module Sigh
  class Manager
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

    def self.expired_profiles(options, args)
      developer_center = Sigh::DeveloperCenter.new
      profiles = developer_center.expired_profiles

      if profiles.empty?
        Helper.log.info "There are no expired profiles to renew.".green
        return
      end

      profiles.each do |profile|
        Helper.log.info "#{ profile[:name] } (#{ profile[:id] }) expired on #{ profile[:expired_on] }"
      end

      if options.renew
        Helper.log.info "Began process to renew #{ profiles.size } expired profiles...".green

        certificate = developer_center.code_signing_certificate_for_renewal
        num_failures = 0

        profiles.each do |profile|
          begin
            developer_center.renew_profile(profile[:id], certificate)
          rescue FastlaneCore::DeveloperCenter::DeveloperCenterGeneralError => e
            Helper.log.error "Error renewing profile #{ profile[:id] }".red
            num_failures += 1
          end
        end

        num_profiles = profiles.size

        Helper.log.info "Successfully renewed #{ num_profiles - num_failures } of #{ num_profiles } expired profiles.".green
        Helper.log.error "Encountered #{ num_failures } failures renewing, try re-running again.".red unless num_failures.zero?
      end
    end

    def self.install_profile(profile)
      Helper.log.info "Installing provisioning profile..."
      profile_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/"
      profile_filename = ENV["SIGH_UDID"] + ".mobileprovision"
      destination = profile_path + profile_filename

      # If the directory doesn't exist, make it first
      unless File.directory?(profile_path)
        FileUtils.mkdir_p(profile_path)
      end

      # copy to Xcode provisioning profile directory
      (FileUtils.copy profile, destination rescue nil) # if the directory doesn't exist yet

      if File.exists? destination
        Helper.log.info "Profile installed at \"#{destination}\""
      else
        raise "Failed installation of provisioning profile at location: #{destination}".red
      end
    end
  end
end
