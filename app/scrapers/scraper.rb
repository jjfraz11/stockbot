require 'mechanize'
require 'active_support/core_ext/object/to_query'
require 'active_support/inflector'

class Scraper
  USER_AGENT = 'Mozilla/5.0 (Windows NT 5.1; rv:19.0) Gecko/20100101 Firefox/19.0'
  TABLE_CLASS  = nil
  HEADER_CLASS = nil
  DATA_CLASS   = nil
  ROW_SIZE     = 0

  attr_reader :agent, :page

  def initialize
    @agent = Mechanize.new
    @agent.user_agent = USER_AGENT
  end

  def base_url
    ""
  end
  
  def parameters
    {}
  end

  def get_header
    {}
  end

  def get_rows
    get_page.search("//tr")
  end

  def clean_row(row)
    row
  end
  
  ###########

  def data_url
    query_string = if self.parameters.empty? 
                     '' 
                   else
                     "?#{self.parameters.to_query}"
                   end
    "#{self.base_url}#{query_string}"
  end

  def get_page
    @page ||= self.agent.get(data_url)
  end

  def scrape(options = { rows: get_rows })
    rows = options[:rows]
    header = []
    data   = []

    row_size     = self.class::ROW_SIZE
    header_class = self.class::HEADER_CLASS
    data_class   = self.class::DATA_CLASS

    rows.each do |row|
      cols = row.search('./th|td')
      next unless cols.size == row_size
      
      temp_row = []
      cols.each do |col|
        if col.name == 'th' or col['class'] == header_class
          next if col.text == nil
          header << col.text[/^[\w ]+\w/].downcase.parameterize('_').to_sym
        elsif col.name == 'td' or col['class'] == data_class
          temp_row << col.text
        end
      end
      
      data << temp_row unless temp_row.empty?
    end

    data.collect! do |row|
      clean_row(Hash[header.zip(row)])
    end
  end
  
end
