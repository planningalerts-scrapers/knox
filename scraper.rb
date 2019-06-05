require "epathway_scraper"

scraper = EpathwayScraper.scrape_and_save(
  "https://eservices.knox.vic.gov.au/ePathway/Production",
  list_type: :advertising, state: "VIC"
)
