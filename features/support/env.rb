require 'browsermob/proxy'
require 'capybara/chromedriver/logger'
require 'capybara/cucumber'
require 'nokogiri'
require 'ptools'
require 'plek'
require 'selenium-webdriver'
require 'uri'
require 'webdrivers'

# Set up environment
case ENV["ENVIRONMENT"]
when "test"
  ENV["GOVUK_APP_DOMAIN"] ||= "test.publishing.service.gov.uk"
  ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.test.publishing.service.gov.uk"
when "integration"
  ENV["GOVUK_APP_DOMAIN"] ||= "integration.publishing.service.gov.uk"
  ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.integration.publishing.service.gov.uk"
when "staging", "staging_aws"
  ENV["GOVUK_APP_DOMAIN"] ||= "staging.publishing.service.gov.uk"
  ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.staging.publishing.service.gov.uk"
when "production", "production_aws"
  ENV["GOVUK_APP_DOMAIN"] ||= "publishing.service.gov.uk"
  ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.gov.uk"
else
  raise "ENVIRONMENT should be one of test, integration, staging, staging_aws, production or production_aws"
end

# Set up basic URLs
ENV["GOVUK_DRAFT_WEBSITE_ROOT"] ||= Plek.new.external_url_for("draft-origin")
Capybara.app_host = ENV["GOVUK_WEBSITE_ROOT"]

# Set up proxy server (used to manipulate HTTP headers etc since Selenium doesn't
# support this) on a random port between 3222 and 3229
proxy_port = (3222..3229).to_a.sample
server = BrowserMob::Proxy::Server.new(
  "./bin/browserup-proxy",
  port: proxy_port,
  log: ENV.fetch("ENABLE_BROWSERMOB_LOGS", false),
  timeout: 20
)
server.start
proxy = server.create_proxy

# Make the proxy available to the tests
$proxy = proxy

# Add request headers
if ENV["RATE_LIMIT_TOKEN"]
  proxy.header({ "Rate-Limit-Token" => ENV["RATE_LIMIT_TOKEN"] })
end

if ENV["AUTH_USERNAME"] && ENV["AUTH_PASSWORD"]
  proxy.basic_authentication(
    URI.parse(ENV["GOVUK_WEBSITE_ROOT"]).host,
    ENV["AUTH_USERNAME"],
    ENV["AUTH_PASSWORD"],
  )
  proxy.basic_authentication(
    "www.account.staging.publishing.service.gov.uk",
    ENV["ACCOUNT_AUTH_USERNAME"],
    ENV["ACCOUNT_AUTH_PASSWORD"],
  )
end

# Blacklist YouTube to prevent cross-site errors
proxy.blacklist(/^https:\/\/www\.youtube\.com/i, 200)
proxy.blacklist(/^https:\/\/s\.ytimg\.com/i, 200)

# To avoid sending events to Google Analytics
proxy.blacklist(/^https:\/\/www\.google\-analytics\.com/i, 200)

# Licensify admin doesn't have favicon.ico so block requests to prevent errors
proxy.blacklist(/^https:\/\/licensify-admin(.*)\.publishing\.service\.gov\.uk\/favicon\.ico$/i, 200)

# Use Chrome in headless mode
Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    acceptInsecureCerts: true,
    loggingPrefs: { browser: "ALL" },
    proxy: { type: :manual, ssl: "#{proxy.host}:#{proxy.port}" }
  )

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--disable-gpu")
  options.add_argument("--disable-xss-auditor")
  options.add_argument("--user-agent=Smokey\ Test\ \/\ Ruby")
  options.add_argument("--no-sandbox") if ENV.key?("NO_SANDBOX")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options,
    desired_capabilities: capabilities
  )
end

Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

# Only raise for severe JavaScript errors and filter our 404s and CORS messages
Capybara::Chromedriver::Logger.raise_js_errors = true
Capybara::Chromedriver::Logger.filter_levels = %i(debug info warning)
Capybara::Chromedriver::Logger.filters = [
  /Failed to load resource/i,
  /The target origin provided/i,
]
