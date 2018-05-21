module Rb1drvTools
  class Profile
    attr_accessor *%w(name token created_at updated_at file)
    def initialize(file=nil)
      @file = file
      if file && File.exist?(file)
        hash_data = JSON.parse(File.read(file))
        %w(name token created_at updated_at).each do |key|
          instance_variable_set("@#{key}", hash_data[key])
        end
      end
    end

    def update_token(access_token)
      @created_at ||= Time.now.to_i
      @updated_at = Time.now.to_i
      @token = access_token.to_hash
      save
    end

    def save
      @file ||= File.join(self.class.config_home, "profile-#{@name}.json")
      File.write @file, JSON.pretty_generate(
        name: @name,
        token: @token,
        created_at: @created_at,
        updated_at: @updated_at
      )
    end

    def self.all
      @all ||= Dir.glob(File.join(config_home, "profile-*.json")).map do |file|
        Profile.new(file)
      end
    end

    def self.config_home
      home = File.join(Dir.home, '.rb1drv')
    ensure
      FileUtils.mkdir(home) unless File.exist?(home)
    end

    def self.default_profile_file
      File.join(config_home, 'default-profile')
    end

    def self.default_profile_index
      @default_profile_index ||=
        if File.exist?(default_profile_file)
          File.read(default_profile_file).strip
        else
          nil
        end
    end

    def self.default_profile_index=value
      return if value.empty?
      @default_profile_index = value
      File.write(default_profile_file, value)
    end

    def self.profile_index
      @profile_index
    end
    def self.profile_index=(name)
      return unless name
      @profile_index = name
      @profile = all.select{ |p| p.name == name }.first
      token = @profile.token
      new_token = CLI.od.auth_load(token)
      @profile.update_token(new_token) if new_token.token != token
    end

    def self.profile
      raise 'No profile available' if all.empty?
      self.profile_index ||= all.first.name if all.size == 1
      self.profile_index ||= default_profile_index
      raise 'Invalid profile' unless @profile
      @profile
    end
  end
end
