require 'nokogiri'
require 'open-uri'

class LibraryParser
    COMMA = ','
    OPEN_BRACKET = '('
    CLOSE_BRACKET = ')'
    NEED_FOR_REFERENCE = 'Need ref'
    PART_OF_FIRST_LIBRARY = 'Librar'
    PART_OF_SECOND_LIBRARY = 'Bibliot'
    PART_OF_NATIONAL = 'National'
    PART_OF_CENTRE = 'Cent'


    def initialize(url)
        @page = Nokogiri::HTML(URI.open(url))
    end


    def parse_library_names
        library_names = []
            (1..26).each do |number|
            xpath_query = "//h2[span[@class='mw-headline' and text()='Alphabetical']]/following-sibling::ul[#{number}]"
            alphabetical_h2 = @page.at_xpath(xpath_query)

            if alphabetical_h2
                first_library_items = alphabetical_h2.xpath('.//li[.//text()[normalize-space()][position() = 1]]')
                first_library_items.each_with_index do |item, index|
                library_name = item.at_xpath('./text()[normalize-space()][position() = 1]')&.text
                
                if(library_name.nil?)
                    result = false
                else
                    result, str = modify_lib_data(library_name);     
                end
                
                result = finalize_result(result, item, str)
                result = result.chomp(COMMA)
                library_names.push(result)
            end
            else
                puts "A list with the title \"Alphabetical\" was not found on the page"
            end
        end
        library_names
    end


    private

    def modify_lib_data(text)
        if text[0] == COMMA
            return false
        end

        if text && text.include?(COMMA)
            first_part = text.split(COMMA).first.strip
            if first_part.include?(PART_OF_FIRST_LIBRARY) || first_part.include?(PART_OF_SECOND_LIBRARY) || first_part.include?(PART_OF_CENTRE)
                
                other_words = first_part.split.select { |word| !(word.include?(PART_OF_FIRST_LIBRARY) || word.include?(PART_OF_SECOND_LIBRARY) || word.include?(PART_OF_CENTRE)) }
                if other_words.any?
                    other_words2 = other_words.select { |word| !(word.include?(PART_OF_CENTRE) || word.include?(PART_OF_NATIONAL)) }
                        return process_other_words_result(other_words2, first_part)
                else
                    return [NEED_FOR_REFERENCE, first_part]
                end

            else
                return check_for_reference(first_part)
            end
        else
            return modify_lib_data(text << COMMA)
        end
    end


    def process_other_words_result(other_words2, first_part)
        if !other_words2.any? && !(first_part.include?(OPEN_BRACKET) && !first_part.include?(CLOSE_BRACKET))
            [NEED_FOR_REFERENCE, first_part]
        elsif first_part.include?(OPEN_BRACKET) && !first_part.include?(CLOSE_BRACKET)
            false
        else
            [first_part, first_part]
        end
    end


    def check_for_reference(first_part)
        if first_part.include?(OPEN_BRACKET) && first_part.include?(CLOSE_BRACKET)
            [NEED_FOR_REFERENCE, first_part]
        else
            false
        end
    end



    def finalize_result(result, item, str)
        if result == false
            result = item.at_xpath('.//a[1]')&.text
        elsif result == NEED_FOR_REFERENCE
            result = item.at_xpath('.//a[1]')&.text
            new_string = result << ' ' << str
            result = new_string
        end
        result
    end

end