module Rb1drvTools
  module Utils
    module_function
    def sort_files(items, column, order)
      if column
        items = items.sort_by(&column)
        items = items.reverse if order == :desc
      end
      items
    end
    def ls(items, column = :name, order = :asc, long = false, width=0)
      return ll(items, column, order) if long
      items = sort_files(items, column, order).map(&:name)
      if width > 0
        ls_format(items, width)
      else
        ls_simple(items)
      end
    end

    def ls_simple(items)
      items.join($/)
    end

    def ls_format(items, width)
      buffer = []
      lens = items.map(&:size)
      row_length = []
      rows = 1.upto(items.size) do |rows|
        row_length = lens.each_slice(rows).map{ |col| col.max + 2 }
        usage = row_length.sum
        break rows if usage < width
      end
      items.each_slice(rows).reduce(&:zip).map(&:flatten).each do |row|
        row.each_with_index do |item, idx|
          buffer << item.ljust(row_length[idx]) if item
        end
        buffer << $/
      end
      buffer.join
    end

    def ll(items, column = :name, order = :asc)
      items = sort_files(items, column, order)
      items.map do |item|
        if item.dir?
          sprintf("d  %-4d %-20s %6s  %s  %s/", item.child_count, item.muser, humanize_size(item.size), item.mtime.localtime.strftime('%Y-%m-%d %H:%M:%S'), item.name)
        else
          sprintf("f  %-4d %-20s %6s  %s  %s", 0, item.muser, humanize_size(item.size), item.mtime.localtime.strftime('%Y-%m-%d %H:%M:%S'), item.name)
        end
      end.join($/)
    end

    def humanize_size(size)
      num = size.abs.to_f
      units = ['', 'K', 'M', 'G']
      unit_idx = 0
      while num > 8192.0 && unit_idx < units.size - 1 do
        num /= 1024.0
        unit_idx += 1
      end
      num = num.round(1)
      num = -num if size < 0
      "#{num}#{units[unit_idx]}"
    end
  end
end
