module Rb1drvTools
  module Command
    def self.get_obj(target)
      if target == '.'
        CLI.cwd
      elsif target == '/'
        CLI.od.root
      elsif target[0] == '/'
        target = smart_expand_path(target)
        CLI.root.get(target)
      else
        target = smart_expand_path(target)
        CLI.cwd.get(target)
      end
    end

    def self.smart_expand_path(path)
      path = File.expand_path('/./' + path)
      path.gsub(%r(^.*/), '/')
    end
  end
end
