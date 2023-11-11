require 'csv'

class FileHandler

  def initialize(data)
    @data = data
  end

  def create_csv_file(csv_file_path)
    CSV.open(csv_file_path, "w") do |csv|
      csv << ["ID", "LibName"]

      @data.each_with_index do |string, index|
        csv << [index + 1, string]
      end
    end

    puts "\nCSV file created successfully: #{csv_file_path}\n\n"
  end

end