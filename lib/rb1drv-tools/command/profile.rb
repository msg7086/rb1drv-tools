require 'securerandom'
module Rb1drvTools
  module Command
    def self.cmd_profile(args)
      request = args.shift
      case request
      when nil, 'ls'
        cmd_profile_ls(args)
      when 'new'
        cmd_profile_new(args)
      when 'default'
        cmd_profile_default(args)
      when 'del', 'delete', 'rm'
        cmd_profile_del(args)
      else
        puts "Unknown request #{request}"
      end
    end

    def self.cmd_profile_ls(args)
      Profile.all.map(&:name).each do |p|
        puts "Profile: #{p}"
      end
      puts "Default: #{Profile.default_profile_index || 'none'}"
    end

    def self.cmd_profile_new(args)
      name = args.first || SecureRandom.hex(4)
      print <<~EOF.chomp
        Creating profile #{name}.

        To create a new OneDrive profile, open the following link in your browser, sign in with your account, and approve our access to your files.

        #{CLI.od.auth_url}

        Paste your authorization code here: 
      EOF
      auth_code = ''
      loop do
        auth_code = STDIN.gets.strip
        break unless auth_code.empty?
      end
      access_token = CLI.od.auth_access(auth_code)
      p = Profile.new
      p.name = name
      p.update_token(access_token)
    end

    def self.cmd_profile_del(args)
      name = Profile.profile.name
      path = Profile.profile.file
      prompt = TTY::Prompt.new
      puts "You asked to delete your local profile #{name}."
      puts "Doing so will revoke our access to your files."
      puts "You can regain access by `profile add` later."
      File.unlink(path) if prompt.yes?("Proceed to delete?", convert: :bool, default: false)
    end

    def self.cmd_profile_default(args)
      Profile.default_profile_index = Profile.profile_index
    end
  end
end
