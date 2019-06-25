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
sleep 3
$browser.goto("https://www.linkedin.com/in/fritzops/detail/recent-activity/shares/")

sleep 3
# keep looping until you collect the specified number of links
$links = []
while $links.size < 5
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
Dir.mkdir "./2nd_degree_commentors" unless Dir.exists? "./2nd_degree_commentors"

$links.each do |link|
  results = []
  puts "visiting #{link}"
  $browser.goto(link)
  sleep(3)
  $post_id = $browser.element(:xpath => "//div[contains(@data-id, 'urn:li:activity')]").attribute_value("data-id")
  $post_id.gsub!("urn:li:activity:","")
  puts $post_id
  STDOUT.flush
  $browser.elements(:xpath => "//button[@data-control-name = 'comment_like_toggle']/../button[@aria-pressed = 'true']/../../../../div/a").each do |person|
      results.push(person.attribute_value("href"))
      results.sort!.uniq!
  end

  if results.size > 0
    File.open("2nd_degree_commentors/post#{$post_id}.txt", "w+") { |file|
      results.each do |f|
        file.write("#{f} \n")
      end
    }
  end
end
