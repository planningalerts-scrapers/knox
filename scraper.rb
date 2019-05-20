require "epathway_scraper"

scraper = EpathwayScraper::Scraper.new(
  "https://eservices.knox.vic.gov.au/ePathway/Production"
)

scraper.scrape(list_type: :advertising) do |record|
  EpathwayScraper.save(record)
end
