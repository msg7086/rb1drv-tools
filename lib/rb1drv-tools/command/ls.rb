module Rb1drvTools
  module Command
    def self.cmd_ll(args)
      args.unshift('-l')
      cmd_ls(args)
    end
    def self.cmd_ls(args)
      Profile.profile
      column = :name
      order = :asc
      long = false
      dirs = []
      args.each do |arg|
        next dirs << arg if arg[0] != '-'
        arg[1..-1].each_char do |flag|
          case flag
          when 'l'
            long = true
          when 'u'
            column = nil
          when 's'
            column = :size
          when 't'
            column = :mtime
          when 'r'
            order = :desc
          else
            puts "Warning: unknown flag '#{flag}'."
          end
        end
      end
      dirs << '.' if dirs.empty?
      dirs.each do |dir|
        dir_obj = get_obj(dir)
        if dir_obj.is_a? OneDrive404
          dir = File.join(CLI.cwd.absolute_path, dir)
          puts "ls: cannot access '#{dir}': No such file or directory"
        elsif dir_obj.file?
          puts Utils.ls([dir_obj], column, order, long)
        else
          puts Utils.ls(dir_obj.children, column, order, long)
          puts "#{dir_obj.child_count} items"
        end
      end
    end
  end
end
