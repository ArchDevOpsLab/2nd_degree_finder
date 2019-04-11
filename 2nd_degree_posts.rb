require "rubygems"
require "watir"
require "json"

login_info = JSON.parse(File.read("support/login.json"))

# client = Selenium::WebDriver::Remote::Http::Default.new
# client.read_timeout = 600
chromedriver_path = File.join(File.absolute_path("webdriver/", File.dirname(__FILE__)),"chromedriver.exe")
Selenium::WebDriver::Chrome.driver_path = chromedriver_path
$browser = Watir::Browser.new :chrome

# $browser = Watir::Browser.new :chrome, :http_client => client
$browser.driver.manage.window.maximize
$browser.goto("www.linkedin.com")
sleep 5

$browser.text_field(:xpath => "//input[@placeholder='Email']").wait_until_present
$browser.text_field(:xpath => "//input[@placeholder='Email']").set(login_info["username"])
$browser.text_field(:xpath => "//input[@placeholder='Password']").set(login_info["password"])
$browser.input(:xpath => "//input[@value='Sign in']").click

sleep 10
# keep looping until you collect up to 100 links for posts written by people in your 2nd degree network. 
$links = []
while $links.size < 25
	puts "#{$links.size} links found"
	STDOUT.flush
	$browser.driver.execute_script("window.scrollBy(0,500)")
	# collect all the links to posts by 2nd degree connections, sort and uniq.
	# collect the data-id for the post and put https://www.linkedin.com/feed/update/ before it
	$browser.elements(:xpath => "//div[contains(@data-id, 'urn:li:activity')]//span[contains(@class, 'supplementary-actor-info')]//span[contains(text(), '2nd')]/ancestor::div[contains(@data-id, 'urn:li:activity')]").each do |post|
		$links.push("https://www.linkedin.com/feed/update/" + post.attribute_value("data-id"))
		$links.sort!.uniq!
	end
end

puts 
puts $links

# go through each link you found and wait for the user to hit enter to advance to the next one
$links.each do |link|
	puts "visiting #{link}"
	$browser.goto(link)
	print "Press any key to continue\r"
	STDOUT.flush
  	gets
end
