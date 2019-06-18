require "rubygems"
require "watir"
require "json"

login_info = JSON.parse(File.read("2nd_degree_finder/support/login.json"))

# client = Selenium::WebDriver::Remote::Http::Default.new
# client.read_timeout = 600
chromedriver_path = File.join(File.absolute_path("webdriver/", File.dirname(__FILE__)), "chromedriver.exe")
Selenium::WebDriver::Chrome.driver_path = chromedriver_path
$browser = Watir::Browser.new :chrome

# $browser = Watir::Browser.new :chrome, :http_client => client
$browser.driver.manage.window.maximize
$browser.goto("www.linkedin.com")
sleep 5
$browser.element(:xpath => "//a[contains (text(), 'Sign in')]").click
$browser.text_field(:xpath => "//input[@id='username']").wait_until_present
$browser.text_field(:xpath => "//input[@id='username']").set(login_info["username"])
$browser.text_field(:xpath => "//input[@id='password']").set(login_info["password"])
$browser.element(:xpath => "//button[contains (text(), 'Sign in')]").click
$browser.element(:xpath => "//input[@aria-label = 'Find people and jobs']").send_keys("Michael Fritzius")
$browser.send_keys([:enter])
$browser.element(:xpath => "(//span[contains(text(), 'Michael')])[1]").click
$browser.element(:xpath => "//a[contains(., 'See all activity')]").click
$browser.element(:xpath => "//span[contains(., 'Posts')]").click

sleep 10
# keep looping until you collect the specified number of links
$links = []
while $links.size < 2
  puts "#{$links.size} links found"
  STDOUT.flush
  $browser.driver.execute_script("window.scrollBy(0,500)")
  # collect all the links to posts by 2nd degree connections, sort and uniq.
  # collect the data-id for the post and put https://www.linkedin.com/feed/update/ before it
  $browser.elements(:xpath => "//div[contains(@data-id, 'urn:li:activity')]").each do |post|
    $links.push("https://www.linkedin.com/feed/update/" + post.attribute_value("data-id"))
    $links.sort!.uniq!
  end
end

puts
puts $links
Dir.mkdir "./posts" unless Dir.exists? "./posts"
$number = 0

$links.each do |link|
  results = []
  $number = $number + 1
  puts "visiting #{link}"
  $browser.goto(link)
  $browser.elements(:xpath => "//button[@data-control-name = 'comment_like_toggle']/../button[@aria-pressed = 'true']").each do |name|
    if name.exists?
      results.push($browser.element(:xpath => "//button[@data-control-name = 'comment_like_toggle']/../button[@aria-pressed = 'true']/../../../../div/a").attribute_value("href"))
      results.sort!.uniq!
    end
  end

  File.open("post#{$number}.txt", "w+") { |file|
    results.each do |f|
      file.write("#{f} \n")
    end
  }
end
