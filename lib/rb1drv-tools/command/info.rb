module Rb1drvTools
  module Command
    def self.cmd_info(args)
      Profile.profile
      format = '%10s: %s'
      CLI.od.request('drives').dig('value').each do |drive|
        {
          'ID' => drive.dig('id'),
          'Site' => drive.dig('webUrl'),
          'Type' => drive.dig('driveType'),
          'Owner' => '%s <%s>' % [drive.dig('owner', 'user', 'displayName'), drive.dig('owner', 'user', 'email')],
          'Size' => Utils.humanize_size(drive.dig('quota', 'total')),
          'Used' => Utils.humanize_size(drive.dig('quota', 'used')),
          'Deleted' => Utils.humanize_size(drive.dig('quota', 'deleted')),
          'Free' => Utils.humanize_size(drive.dig('quota', 'remaining'))
        }.each do |row|
          puts format % row
        end
        puts
      end

    end
  end
end
