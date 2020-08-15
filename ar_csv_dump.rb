# frozen_string_literal: true

# ar_csv_dump.rb
# RailsRunnerで使用する
# ダンプファイルを出力する、または取り込む
require 'optparse'
require 'csv'

ActiveRecord::Base.logger = nil
timestamp = Time.now.in_time_zone.strftime('%Y%m%d%H%M%S')

option = {
  dir: "#{Rails.root}/db/dump",
  tables: ActiveRecord::Base.connection.tables
}
opt = OptionParser.new
opt.on('-t=VAL', '--table=VAL', Array,
       '対象のテーブル カンマ区切りで複数指定可能') do |a|
  option[:tables] = option[:tables] & a
end
opt.parse!(ARGV)

dump_path = "#{option[:dir]}/#{timestamp}"
Dir.mkdir(dump_path) unless Dir.exist?(dump_path)
limit = 1000
option[:tables].each do |table|
  primary_key = ActiveRecord::Base.connection.primary_keys(table).first
  klass = Class.new(ActiveRecord::Base) do
    self.table_name = table
    self.primary_key = primary_key
  end
  column_names = klass.column_names
  total = klass.all.count
  File.write(
    "#{dump_path}/#{table}.csv",
    CSV.generate(force_quotes: true) do |csv|
      csv << column_names
      0.step(total, limit) do |offset|
        klass.all
             .order(primary_key)
             .limit(limit)
             .offset(offset)
             .pluck(*column_names)
             .each do |row|
          csv << (row.is_a?(Array) ? row : [row])
        end
      end
    end
  )
  puts "#{table}: done!"
end
