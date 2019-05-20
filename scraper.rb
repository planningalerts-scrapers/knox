require "epathway_scraper"

base_url = "https://eservices.knox.vic.gov.au/ePathway/Production/Web/generalenquiry/"
url = "#{base_url}enquirylists.aspx"

scraper = EpathwayScraper::Scraper.new(
  "https://eservices.knox.vic.gov.au/ePathway/Production"
)


agent = scraper.agent

summary_page = scraper.pick_type_of_search(:advertising)

page_number = 2 # The next page number to move onto (we've already got page 1)

while summary_page
  table = summary_page.root.at_css('.ContentPanel')

  scraper.extract_table_data_and_urls(table).each do |row|
    data = scraper.extract_index_data(row)
    record = {
      'council_reference' => data[:council_reference],
      # There is a direct link but you need a session to access it :(
      'info_url' => url,
      'description' => data[:description],
      'date_received' => data[:date_received],
      'address' => data[:address],
      'date_scraped' => Date.today.to_s
    }
    EpathwayScraper.save(record)
  end

  if summary_page.at('#ctl00_MainBodyContent_mPagingControl_nextPageHyperLink')
    p "Found another page - #{page_number}"
    summary_page.forms.first.action = "EnquirySummaryView.aspx?PageNumber=#{page_number}"
    summary_page = summary_page.forms.first.submit
    page_number += 1
  else
    summary_page = nil
  end
end
