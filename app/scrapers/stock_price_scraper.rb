require_relative 'scraper'

class StockPriceScraper < Scraper

  class ReportTypeError < RuntimeError; end

  attr_accessor :symbol, :start_date, :end_date, :report_type

  @@header_class = 'yfnc_tablehead1'
  @@data_class   = 'yfnc_tabledata1'
  @@min_row_size = 7

  def initialize(symbol, start_date, end_date, type)
    @symbol      = symbol.upcase
    @start_date  = get_date(start_date)
    @end_date    = get_date(end_date)
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
      :a => "%02d" % ( @start_date.month - 1),
      :b => "%02d" % @start_date.day,
      :c => "%04d" % @start_date.year,
      :d => "%02d" % ( @end_date.month - 1 ),
      :e => "%02d" % @end_date.day,
      :f => "%04d" % @end_date.year,
      :g => @report_type
    }
  end
  
  def clean_row(row)
    out_row = {}
    out_row[:symbol]    =  @symbol
    out_row[:date]      =  Date.parse(row[:date]).strftime('%Y-%m-%d')
    out_row[:open]      =  Float(row[:open])
    out_row[:high]      =  Float(row[:high])
    out_row[:low]       =  Float(row[:low])
    out_row[:close]     =  Float(row[:close])
    out_row[:volume]    =  row[:volume].gsub(/[^0-9]/,'').to_i
    out_row[:adj_close] =  Float(row[:adj_close])
    out_row
  end

  def get_header
    { symbol: @symbol }
  end

  def get_rows
    get_page.search("table[@class='yfnc_datamodoutline1']/tr//tr")
  end

  def scrape(options = { model: nil })
    rows = []
    init_start_date = @start_date
    init_end_date   = @end_date
    @data_model = options[:model]

    (init_start_date..init_end_date).each_slice(90) do |date_range|
      @start_date = date_range.first
      @end_date = date_range.last
      rows += super()
    end

    @start_date = init_start_date
    @end_date   = init_end_date
    @data_model = nil
    rows.flatten
  end

  protected

  def get_report_type(report_type)
    type = case report_type.to_s.downcase
           when 'daily', 'day' then 'd'
           when 'weekly', 'week' then 'w'
           when 'monthly', 'month'  then 'm'
           when 'dividends only', 'dividends' then 'v'
           else raise ReportTypeError, "Unknown report type: #{report_type}"
           end
    
  end

end
