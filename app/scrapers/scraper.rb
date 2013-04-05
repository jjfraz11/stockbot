require 'mechanize'
require 'active_support/core_ext/object/to_query'
require 'active_support/inflector'

class Scraper
  class ScraperDataError < RuntimeError; end

  @@user_agent = 'Mozilla/5.0 (Windows NT 5.1; rv:19.0) Gecko/20100101 Firefox/19.0'
  @@header_class = nil
  @@data_class   = nil
  @@min_row_size = 0

  attr_reader :agent, :page

  def initialize
    @agent = Mechanize.new
    @agent.user_agent = @@user_agent
    @data_model = nil 
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
    @page = self.agent.get(data_url)
  end

  def scrape
    rows = get_rows
    header = []
    data   = []

    rows.each do |row|
      cols = row.search('./th|td')
      next unless cols.size >= @@min_row_size
      
      temp_row = []
      cols.each do |col|
        if col.name == 'th' or col['class'] == @@header_class
          next if col.text == nil
          header << col.text[/^[\w ]+\w/].downcase.parameterize('_').to_sym
        elsif col.name == 'td' or col['class'] == @@data_class
          temp_row << col.text
        end
      end
      
      data << temp_row unless temp_row.empty?
    end

    data.collect! do |row|
      hash_row = Hash[header.zip(row)]
      final_row = clean_row(hash_row)
      @data_model.create(final_row) unless @data_model.nil?
      final_row
    end

    raise ScraperDataError, "No data returned for #{self.data_url}" if data.empty?
    data
  end
  
  def get_date(date)
    if date.is_a? Date
      date
    elsif date.respond_to?(:to_date)
      date.to_date
    else
      Date.parse(date)
    end
  end

end
