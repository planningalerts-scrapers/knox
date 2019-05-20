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


  headers = table.css('th').collect { |th| th.inner_text.strip }

  table.css('.ContentPanel, .AlternateContentPanel').each do |tr|
    da_item = tr.css('td').collect { |td| td.inner_text.strip }
    record = {
      'council_reference' => da_item[headers.index('Application Number')],
      # There is a direct link but you need a session to access it :(
      'info_url' => url,
      'description' => da_item[headers.index('Description')],
      'date_received' => Date.strptime(da_item[headers.index('Date Lodged')], '%d/%m/%Y').to_s,
      'address' => da_item[headers.index('Location')],
      'date_scraped' => Date.today.to_s
    }
    ScraperWiki.save_sqlite(['council_reference'], record)
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
