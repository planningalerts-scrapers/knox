require 'scraperwiki'
require 'mechanize'
require 'date'

base_url = "https://eservices.knox.vic.gov.au/ePathway/Production/Web/generalenquiry/"
url = "#{base_url}enquirylists.aspx"

agent = Mechanize.new

first_page = agent.get url
p first_page.title.strip
first_page_form = first_page.forms.first
first_page_form.radiobuttons.first.click
summary_page = first_page_form.click_button

page_number = 2 # The next page number to move onto (we've already got page 1)

das_data = []
while summary_page
  p summary_page.title.strip
  table = summary_page.root.at_css('.ContentPanel')
  headers = table.css('th').collect { |th| th.inner_text.strip }

  das_data = das_data + table.css('.ContentPanel, .AlternateContentPanel').collect do |tr|
    tr.css('td').collect { |td| td.inner_text.strip }
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

das_data.each do |da_item|
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
