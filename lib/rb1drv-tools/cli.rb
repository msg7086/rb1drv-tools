module Rb1drvTools
  class CLI
    CLI_DELIMITER = '-,-'
    def initialize(*args)
      CLI.set_od(*args)

      @profiles = Profile.all
      @profile_index = nil
      @profile = nil

      ARGV << 'help' if ARGV.empty?

      set_profile
      split_args.each do |args|
        dispatch_command args
      end
    end

    def set_profile
      if ARGV.first[0] == ':'
        @profile_index = ARGV.shift[1..-1]
        Profile.profile_index = @profile_index
      end
    end

    def split_args
      argv = ARGV.dup
      @profile_index = argv.shift[1..-1] if argv.first[0] == ':'
      Enumerator.new do |y|
        while delimiter_pos = argv.index(CLI_DELIMITER)
          y << argv[0...delimiter_pos]
          argv = argv[(delimiter_pos+1)..-1]
        end
        y << argv
      end
    end

    def dispatch_command(args)
      return if args.empty?
      cmd = args.shift
      method = "cmd_#{cmd}"
      unless Command.respond_to?(method)
        puts "Unknown command #{cmd}"
        return
      end
      Command.send(method, args)
    end

    def self.cwd
      @cwd ||= CLI.od.root
    end

    def self.cwd=value
      @cwd = value
    end

    def self.set_od(*args)
      @logger = args[3]
      @od = OneDrive.new(*args)
    end

    def self.od
      @od
    end

    def self.logger
      @logger
    end
  end
end
Dir.chdir(File.expand_path('..', File.dirname(__FILE__))) do
  Dir['rb1drv-tools/command/*.rb'].each{ |file| require file }
end
