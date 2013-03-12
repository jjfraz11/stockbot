require 'mechanize'
require 'active_support/core_ext/object/to_query'
require 'active_support/inflector'

class Scraper
  def initialize
    @agent = Mechanize.new
  end

  def base_url
    ""
  end
  
  def parameters
    {}
  end

  def data_url
    "#{base_url}?#{parameters.to_query}"
  end

  def get_page
    @agent.get(base_url, parameters)
  end

  def scrape
    get_page
  end
end
