module Rb1drvTools
  module Command
    def self.cmd_info(args)
      Profile.profile
      format = '%10s: %s'
      CLI.od.request('drives').dig('value').each do |drive|
        total = drive.dig('quota', 'total').to_i
        used = drive.dig('quota', 'used').to_i
        deleted = drive.dig('quota', 'deleted').to_i
        remaining = drive.dig('quota', 'remaining').to_i
        lost = total - used - deleted - remaining

        {
          'ID' => drive.dig('id'),
          'Site' => drive.dig('webUrl'),
          'Type' => drive.dig('driveType'),
          'Owner' => '%s <%s>' % [drive.dig('owner', 'user', 'displayName'), drive.dig('owner', 'user', 'email')],
          'Size' => Utils.humanize_size(total),
          'Used' => Utils.humanize_size(used),
          'Deleted' => Utils.humanize_size(deleted),
          'Free' => Utils.humanize_size(remaining),
          'Lost' => Utils.humanize_size(lost) # Lost in universe (Version History)
        }.each do |row|
          puts format % row
        end
        puts
      end

    end
  end
end
