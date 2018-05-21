module Rb1drvTools
  module Command
    def self.cmd_cd(args)
      Profile.profile
      dir = args.first
      dir_obj = get_obj(dir)
      if dir_obj.is_a? OneDriveDir
        CLI.cwd = dir_obj
      else
        dir = File.join(CLI.cwd.absolute_path, dir)
        puts "cd: cannot access '#{dir}': No such file or directory"
      end
    end
  end
end
