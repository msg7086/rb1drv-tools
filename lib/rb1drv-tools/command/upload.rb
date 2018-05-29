module Rb1drvTools
  module Command
    def self.cmd_upload(args)
      Profile.profile
      return if args.empty?
      file_mode = true
      overwrite = false
      overwrite_smarter = false
      time_sync = false

      items = []
      args.each do |arg|
        next items << arg if arg[0] != '-'
        arg[1..-1].each_char do |flag|
          case flag
          when 's'
            overwrite_smarter = true
          when 'f'
            overwrite = true
          when 't'
            time_sync = true
          else
            puts "Warning: unknown flag '#{flag}'."
          end
        end
      end

      if overwrite && overwrite_smarter
        puts "Error: -s and -f are mutually exclusive, make your decision first."
        return
      end

      target = '.'
      target = items.pop[1..-1] if items.last[0] == '@'
      target_obj = get_obj(target)
      return if items.empty?

      # p items
      # p target_obj

      # Directory mode if:
      #   target directory exists
      file_mode = false if target_obj.dir?
      #   target ends with a slash
      file_mode = false if target.end_with?('/')
      #   multiple source files are given
      file_mode = false if items.size > 1
      file_mode = false if File.directory?(items.first)
      #   wildcard matching files on server
      file_mode = false if Dir[items.first].size > 1

      overwrite_policy = if overwrite
                           :overwrite
                         elsif overwrite_smarter
                           :overwrite_smarter
                         else
                           :skip
                         end

      if file_mode
        target_dir = get_obj(File.dirname(target))
        CLI.cwd.mkdir(File.dirname(target))
        target_name = File.basename(target)
        upload(items.first, target_dir, File.basename(target), overwrite_policy: overwrite_policy, time_sync: time_sync)
      else
        items.each do |item|
          unless target_obj.dir?
            base = if target[0] == '/'
                     CLI.root
                   else
                     CLI.cwd
                   end
            target = File.expand_path('/./' + target)
            target_obj = base.mkdir(target)
          end
          Dir[item].each do |match|
            if File.directory?(match)
              traverse_dir(match, target_obj.mkdir(File.basename(match)), overwrite_policy: overwrite_policy, time_sync: time_sync)
            else
              upload(match, target_obj, File.basename(match), overwrite_policy: overwrite_policy, time_sync: time_sync)
            end
          end
        end
      end
    end

    def self.traverse_dir(source_directory, target_directory, overwrite_policy: :skip, time_sync: false)
      Dir.entries(source_directory).sort.each do |child|
        next if child == '.' || child == '..'
        new_path = File.join(source_directory, child)
        if File.directory?(new_path)
          new_dir = target_directory.get_child(child)
          new_dir = target_directory.mkdir(child) unless new_dir.dir?
          traverse_dir(new_path, new_dir, overwrite_policy: overwrite_policy, time_sync: time_sync)
        else
          upload(new_path, target_directory, child, overwrite_policy: overwrite_policy, time_sync: time_sync)
        end
      end
    end

    def self.upload(source_file, target_directory, target_name, overwrite_policy: :skip, time_sync: false)
      return if source_file.include?('.1drv_upload')
      printf "%s => %s :: %s\n", source_file, target_directory.absolute_path, target_name
      target_obj = target_directory.get_child(target_name)
      return puts 'Target is a directory, skipped' if target_obj.dir?
      mtime = File.mtime(source_file)
      file_size = File.size(source_file)
      if overwrite_policy != :overwrite && target_obj.file?
        if time_sync && target_obj.size == file_size && target_obj.mtime - mtime > 2
          target_obj.set_mtime(mtime)
          print '<sync mtime> '
        end
        return puts 'Skipped' if overwrite_policy == :skip
        return puts 'Remote file is up to date, skipped' if target_obj.mtime >= File.mtime(source_file) - 2
      end
      screen_width = TTY::Screen.width
      if STDOUT.tty? && screen_width >= 50
        multibar = TTY::ProgressBar::Multi.new
        bar = multibar.register("%s :current_byte / :total_byte :byte_rate/s [:bar] :eta :percent" % source_file[0..29], total: file_size, frequency: 2, head: '>')
        bar.start
      end
      subbar = nil

      if file_size >= 524_288_000 # 500MiB
        fragment_size = 209_715_200 # 200MiB
      elsif file_size >= 209_715_200 # 200MiB
        fragment_size = 83_886_080 # 80MiB
      else
        fragment_size = 20_971_520 # 20MiB
      end

      target_directory.upload(source_file, target_name: target_name, overwrite: true, fragment_size: fragment_size) do |ev, st|
        case ev
        when :new_segment
          subbar = multibar.register("%4d-%-4d :current_byte / :total_byte [:bar]" % [st[:from] / 1048576, st[:to] / 1048576], total: st[:to] - st[:from] + 1, frequency: 2, head: '>')
        when :finish_segment
          subbar.finish
          multibar.instance_variable_get('@bars').delete_at(1)
          multibar.instance_variable_set('@rows', multibar.rows - 1)
          print TTY::Cursor.up(1)
          print TTY::Cursor.clear_line_after
        when :progress
          bar.current = st[:from] + st[:progress]
          subbar.current = st[:progress]
        when :retry
          bar.current = st[:from]
          subbar.reset
        end
      end

      bar.finish
    end
    singleton_class.send(:alias_method, :cmd_up, :cmd_upload)
  end
end
