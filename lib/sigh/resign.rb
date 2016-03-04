require 'shellwords'

module Sigh
  # Resigns an existing ipa file
  class Resign
    def run(options, args)
      # get the command line inputs and parse those into the vars we need...

      ipa, signing_identity, provisioning_profiles, entitlements, version = get_inputs(options, args)
      # ... then invoke our programmatic interface with these vars
      resign(ipa, signing_identity, provisioning_profiles, entitlements, version)
    end

    def self.resign(ipa, signing_identity, provisioning_profiles, entitlements, version)
      self.new.resign(ipa, signing_identity, provisioning_profiles, entitlements, version)
    end

    def resign(ipa, signing_identity, provisioning_profiles, entitlements, version)
      resign_path = find_resign_path
      signing_identity = find_signing_identity(signing_identity)

      UI.important "Signing identity '#{signing_identity}' may have expired." unless signing_identity.valid?

      unless provisioning_profiles.kind_of?(Enumerable)
        provisioning_profiles = [provisioning_profiles]
      end

      # validate that we have valid values for all these params
      validate_params(resign_path, ipa, provisioning_profiles)
      entitlements = "-e #{entitlements}" if entitlements
      provisioning_options = provisioning_profiles.map { |fst, snd| "-p #{[fst, snd].compact.map(&:shellescape).join('=')}" }.join(' ')
      version = "-n #{version}" if version

      command = [
        resign_path.shellescape,
        ipa.shellescape,
        signing_identity.sha1.shellescape,
        provisioning_options, # we are aleady shellescaping this above, when we create the provisioning_options from the provisioning_profiles
        entitlements,
        version,
        ipa.shellescape
      ].join(' ')

      puts command.magenta
      puts `#{command}`

      if $?.to_i == 0
        UI.success "Successfully signed #{ipa}!"
        true
      else
        UI.error "Something went wrong while code signing #{ipa}"
        false
      end
    end

    def get_inputs(options, args)
      ipa = args.first || find_ipa || ask('Path to ipa file: ')
      signing_identity = options.signing_identity || ask_for_signing_identity
      provisioning_profiles = options.provisioning_profile || find_provisioning_profile || ask('Path to provisioning file: ')
      entitlements = options.entitlements || find_entitlements
      version = options.version_number || nil

      return ipa, signing_identity, provisioning_profiles, entitlements, version
    end

    def find_resign_path
      File.join(Helper.gem_path('sigh'), 'lib', 'assets', 'resign.sh')
    end

    def find_ipa
      Dir[File.join(Dir.pwd, '*.ipa')].sort { |a, b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def find_provisioning_profile
      Dir[File.join(Dir.pwd, '*.mobileprovision')].sort { |a, b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def find_entitlements
      Dir[File.join(Dir.pwd, '*.entitlements')].sort { |a, b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def find_signing_identity(query)
      signing_identity = signing_identity_for_query(query)
      until signing_identity
        UI.error "Couldn't find signing identity '#{signing_identity}'."
        query = ask_for_signing_identity
        signing_identity = signing_identity_for_query(query)
      end

      signing_identity
    end

    def signing_identity_for_query(query)
      installed_identities.find { |identity| identity.sha1 == query || identity.name == query }
    end

    def validate_params(resign_path, ipa, provisioning_profiles)
      validate_resign_path(resign_path)
      validate_ipa_file(ipa)
      provisioning_profiles.each { |fst, snd| validate_provisioning_file(snd || fst) }
    end

    def validate_resign_path(resign_path)
      UI.user_error!('Could not find resign.sh file. Please try re-installing the gem') unless File.exist?(resign_path)
    end

    def validate_ipa_file(ipa)
      UI.user_error!("ipa file could not be found or is not an ipa file (#{ipa})") unless File.exist?(ipa) && ipa.end_with?('.ipa')
    end

    def validate_provisioning_file(provisioning_profile)
      unless File.exist?(provisioning_profile) && provisioning_profile.end_with?('.mobileprovision')
        UI.user_error!("Provisioning profile file could not be found or is not a .mobileprovision file (#{provisioning_profile})")
      end
    end

    def print_available_identities
      UI.message "Available identities: \n\t#{installed_identity_descriptions.join("\n\t")}\n"
    end

    def ask_for_signing_identity
      print_available_identities
      ask('Signing Identity: ')
    end

    # Hash of available signing identities
    def installed_identities
      available = `security find-identity -p codesigning`
      ids = {}
      available.split("\n").each do |current|
        begin
          match = current.match(/.*([0-9A-Z]{40}) \"(.*)\"(\s+\((.*)\))?/)
          sha1 = match[1]
          name = match[2]
          issue = match[4]
          ids[sha1] = SigningIdentity.new(sha1, name, issue)
        rescue
          nil
        end # the last line does not match
      end

      ids.values.select(&:may_be_valid?).sort_by do |identity|
        [identity.name, identity.valid? ? 0 : 1]
      end
    end

    def installed_identity_descriptions
      descriptions = []
      installed_identities.group_by(&:name).each do |name, identities|
        descriptions << (identities.any?(&:valid?) ? name.black : name.white)
        # Show SHA-1 for homonymous identities
        descriptions += identities.map do |identity|
          text = "\t#{identity.sha1}"
          identity.valid? ? text.black : text.white
        end if identities.count > 1
      end
      descriptions
    end

    class SigningIdentity
      attr_reader :sha1, :name, :issue

      def initialize(sha1, name, issue)
        @sha1 = sha1
        @name = name
        @issue = issue
      end

      def valid?
        @issue.nil?
      end

      def may_be_valid?
        # Because of WWDR Intermediate Certificate expiration, valid certificates may be reported as expired.
        # So we need to accept expired certificates for the moment.
        # https://developer.apple.com/support/certificates/expiration
        [nil, 'CSSMERR_TP_CERT_EXPIRED'].include? @issue
      end

      def to_s
        "#{sha1} \"#{name}\""
      end
    end
  end
end
