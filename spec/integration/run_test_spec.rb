require "selenium-webdriver"

describe "hackathon" do
  let(:driver) { Selenium::WebDriver.for(:chrome) }

  it 'should demo' do
    driver.get('https://www.google.com')
  end
end