require_relative '../spec_helper'

describe "hackathon" do
  let(:driver) {Selenium::WebDriver.for(:chrome)}

  it 'should demo' do
    driver.get('https://www.google.com')
  end

end