require_relative 'scraper'

class StockPricesScraper < Scraper

  class ReportTypeError < RuntimeError; end

  attr_accessor :symbol, :start_date, :end_date, :report_type

  TABLE_CLASS  = 'yfnc_datamodoutline1'
  HEADER_CLASS = 'yfnc_tablehead1'
  DATA_CLASS   = 'yfnc_tabledata1'
  ROW_SIZE     = 7

  def initialize(symbol, start_date, end_date, type)
    @symbol = symbol.upcase
    @start_time = Time.parse(start_date)
    @end_time = Time.parse(end_date)
    @report_type = get_report_type(type)
    super()
  end

  def base_url
    "http://finance.yahoo.com/q/hp"
  end

  def parameters
    # ?s=YHOO&a=03&b=12&c=1996&d=02&e=11&f=2013&g=d
    {
      :s => @symbol,
      :a => "%02d" % ( @start_time.month - 1),
      :b => "%02d" % @start_time.day,
      :c => "%04d" % @start_time.year,
      :d => "%02d" % ( @end_time.month - 1 ),
      :e => "%02d" % @end_time.day,
      :f => "%04d" % @end_time.year,
      :g => @report_type
    }
  end
  
  def get_report_type(report_type)
    type = case report_type.to_s.downcase
           when 'daily', 'day' then 'd'
           when 'weekly', 'week' then 'w'
           when 'monthly', 'month'  then 'm'
           when 'dividends only', 'dividends' then 'v'
           else raise ReportTypeError, "Unknown report type: #{report_type}"
           end
    
  end

  def scrape
    header = [:symbol]
    data = []
    rows = get_page.search("table[@class='#{TABLE_CLASS}']/tr//tr")

    rows.each do |row|
      next unless row.children.size == ROW_SIZE

      temp_row = [@symbol]
      row.children.each do |col|
        if col.name == 'th' and col['class'] == HEADER_CLASS
          header << col.text[/^[\w ]+\w/].parameterize('_').to_sym
        elsif col.name == 'td' and col['class'] == DATA_CLASS
          temp_row << col.text
        end
      end

      data << temp_row unless temp_row.size == 1
    end

    data.collect! do |row|
      clean_row(Hash[header.zip(row)])
    end
  end

  def clean_row(row)
    out_row = {}
    out_row[:date]      =  Time.parse(row[:date]).strftime('%Y-%m-%d')
    out_row[:open]      =  Float(row[:open])
    out_row[:high]      =  Float(row[:high])
    out_row[:low]       =  Float(row[:low])
    out_row[:close]     =  Float(row[:close])
    out_row[:volume]    =  row[:volume].gsub(/[^0-9]/,'').to_i
    out_row[:adj_close] =  Float(row[:adj_close])
    out_row
  end
end


s = StockPricesScraper.new('LNKD', '2013-2-1', '2013-2-28', 'day')
p s.data_url
p s.scrape
# s.symbol = 'GOOG'
# p s.data_url
# p s.scrape
