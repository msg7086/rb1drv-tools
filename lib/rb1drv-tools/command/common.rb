module Rb1drvTools
  module Command
    def self.get_obj(target)
      if target == '.'
        CLI.cwd
      elsif target == '/'
        CLI.od.root
      elsif target[0] == '/'
        target = File.expand_path('/./' + target)
        CLI.root.get(target)
      else
        target = File.expand_path('/./' + target)
        CLI.cwd.get(target)
      end
    end
  end
end
