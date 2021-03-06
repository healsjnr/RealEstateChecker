require "net/http"
require "Nokogiri"

module RealEstateChecker
  module Logger
    def log(msg, type={:type => 'info'})
      puts "[#{type}] #{msg}" if type.is_a? Symbol
      puts "[#{type[:type]}] #{msg}" if type.is_a? Hash
    end

    module_function :log
  end

  class RentalEntry
    attr_accessor :price
    attr_accessor :num_bedrooms
    attr_accessor :num_bathrooms
    attr_accessor :num_car_spaces
    def to_s
      "Rent: #{@price}.\n" +
      "Bedrooms: #{@num_bedrooms}.\n" +
      "Bathrooms: #{@num_bathrooms}.\n" +
      "Car Spaces: #{@num_car_spaces}.\n\n"
    end

  end

  class Worker
    @@page_num_token = "##PAGE_NUM"
    @@url = "http://www.realestate.com.au/rent/property-apartment-unit+apartment-with-1-bedroom-in-new+farm%2c+qld+4005/list-#{@@page_num_token}?numParkingSpaces=1&numBaths=1&source=refinements"

    attr_reader :page_count, :results
    
    def initialize page_count
      @page_count = page_count
      @results = []
    end

    def get_page_data
      (1..@page_count).each do |i|
        uri = URI(@@url.gsub(@@page_num_token, i.to_s))
        res = Net::HTTP.get_response(uri)
        http_result = res.body if res.is_a?(Net::HTTPSuccess)
        doc = Nokogiri::HTML(http_result)
        @results = parse_result doc
      end
    end

    def print_output res=results
      puts "Results:"
      res.each do |r| puts r.to_s end
    end

    private

    def parse_result doc
      results_local = []

      doc.css('div[class="resultBodyWrapper"]').each do |body|
        rental = RentalEntry.new()
        rental.price= body.css('p[class="price"] span[class="hidden"]').first.content
        details = body.css('div[class="listingInfo"] ul li').css('span')
        rental.num_bedrooms= details[0].content
        rental.num_bathrooms= details[1].content
        rental.num_car_spaces= details[2].content
       
        results_local << rental
      end
      results_local
    end

  end
end