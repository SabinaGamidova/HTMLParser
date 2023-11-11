require_relative 'xml_parser'
require_relative 'file_operations'


url = 'https://en.wikipedia.org/wiki/List_of_libraries'
library_parser = LibraryParser.new(url)
library_names = library_parser.parse_library_names


file_handler = FileHandler.new(library_names)
csv_file_path = "libraries.csv"
file_handler.create_csv_file(csv_file_path)