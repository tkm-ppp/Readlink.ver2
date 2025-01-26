require 'csv'

class DataProcessor
  def self.save_to_csv(data, filename)
    CSV.open(filename, 'w') do |csv|
      csv << data.first.keys
      data.each do |row|
        csv << row.values
      end
    end
  end

  def self.read_from_csv(filename)
    CSV.read(filename, headers: true).map(&:to_h)
  end
end
