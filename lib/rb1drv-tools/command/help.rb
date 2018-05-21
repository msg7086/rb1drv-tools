module Rb1drvTools
  module Command
    def self.cmd_help(args)
      cmd_version(args)
      me = File.basename($0, File.extname($0))
      puts <<~EOF
        Usage:
          #{me} [:<profile>] <Command> [-,- <Command>]...

        Command:
          help                              Display this help

          profile new                       Create a new profile to access your files
          profile ls                        List profiles
          profile default                   Set chosen profile as default
          profile del                       Delete profile to revoke access

          ls [-ustrl] [<target>]            List information about files
          ll [-ustrl] [<target>]            Long listing format of ls
              -u                                Do not sort by name
              -s                                Sort by size, smallest first
              -t                                Sort by modified time, oldest first
              -r                                Reverse order while sorting
              -l                                Use a long listing format
              directory                         List contents of this directory
              file                              List information of this file

          cd <directory>                    Change current directory, only effective in single execution

          mkdir <directory>                 Create the directory recursively

          upload [-fs] <files> [@target]    Upload files into directory recursively, skipping existing files
          download [-f] <r-files> [@target] Download files into directory recursively, skipping existing files
              -f                                Overwrite existing files regardless
              -s                                Overwrite existing files with different size or older date
              @directory/                       Upload or download into directory as children, if:
                                                  - target directory exists
                                                  - target ends with a slash
                                                  - multiple source files are given
                                                  - wildcard matching multiple source files
              @file                             Upload or download as a single file, if:
                                                  - target file exists
                                                  - target does not end with a slash, and only one source file is given
              files                             Local source files to upload, wildcard accepted in Ruby glob syntax
              r-files                           Remote source files to download, wildcard accepted with limitations:
                                                  - no ** matching
                                                  - can only match names under current directory

          info                               Show information about this drive

        Examples:
          #{me} profile new student_account
          #{me} profile new personal
          #{me} :personal profile default -,- profile ls
          #{me} :student_account cd class101/slides -,- download slides-2\\*.pdf @slides/
          #{me} upload slides -,- ls -l slides -,- info

      EOF
    end

    def self.cmd_version(args)
      puts <<~EOF
        Ruby-OneDrive-Tools #{Rb1drvTools::VERSION}, SDK #{Rb1drv::VERSION}
        Copyright (c) 2018 Xinyue Lu, The MIT License.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
        You may not hold the author liable. Check LICENSE.txt for Full Text.

      EOF
    end
  end
end
