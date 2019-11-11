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
Dir.mkdir(dump_path) unless Dir.exist? dump_path
option[:table].each do |table|
  klass = Class.new(ActiveRecord::Base)
  klass.table_name = table
  klass.primary_key = klass.connection.primary_keys(table).first
  content = CSV.generate(force_quotes: true) do |csv|
    csv << klass.column_names
    pos = 0
    range = 1000
    loop do
      records = klass.all.order(klass.primary_key).limit(range)
                     .offset(pos).pluck(*klass.column_names)
      break if records.empty?

      pos += range
      records.each do |record|
        csv << (record.is_a?(Array) ? record : [record])
      end
    end
  end
  File.write("#{dump_path}/#{table}.csv", content)
  puts "#{table} done!"
end
