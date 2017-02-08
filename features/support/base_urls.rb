def app_domain
  ENV["GOVUK_APP_DOMAIN"] || "integration.publishing.service.gov.uk"
end

def signon_base_url
  application_base_url('signon')
end

def application_base_url(app_name)
  case app_name
  when 'asset-manager' then "https://asset-manager.#{app_domain}/"
  when 'assets' then "https://assets-origin.#{app_domain}/"
  when 'bouncer' then "https://bouncer.#{app_domain}/"
  when 'calendars' then "https://calendars.#{app_domain}/bank-holidays"
  when 'contacts' then "https://www.#{app_domain}/contact/hm-revenue-customs"
  when 'businesssupportfinder' then "https://businesssupportfinder.#{app_domain}/business-finance-support-finder"
  when 'frontend' then "https://frontend.#{app_domain}/"
  when 'private-frontend' then "https://private-frontend.#{app_domain}/"
  when 'imminence' then "https://imminence.#{app_domain}/"
  when 'licencefinder' then "https://licencefinder.#{app_domain}/licence-finder"
  when 'licensing' then "https://licensify.#{app_domain}/apply-for-a-licence"
  when 'local-links-manager' then "https://local-links-manager.#{app_domain}"
  when 'panopticon' then "https://panopticon.#{app_domain}/"
  when 'public-contentapi' then "https://www.#{app_domain}/api/tags.json" # this should be changed to a Content API 'homepage' when we have one
  when 'publisher' then "https://publisher.#{app_domain}/admin"
  when 'signon' then "https://signon.#{app_domain}/"
  when 'smartanswers' then "https://smartanswers.#{app_domain}/calculate-your-maternity-pay"
  when 'static' then "https://static.#{app_domain}/"
  when 'tariff-backend' then "https://tariff-api.#{app_domain}/"
  when 'tariff-frontend' then "https://tariff.#{app_domain}/trade-tariff"
  when 'whitehall' then "https://whitehall-frontend.#{app_domain}/government/how-government-works"
  when 'whitehall-frontend' then "https://whitehall-frontend.#{app_domain}"
  when 'whitehall-admin' then "https://whitehall-admin.#{app_domain}"
  when 'imminence' then "https://imminence.#{app_domain}/admin"
  when 'travel-advice-publisher' then "https://travel-advice-publisher.#{app_domain}/admin"
  when 'transition' then "https://transition.#{app_domain}"
  else
    raise "Application '#{app_name}' not recognised, unable to boot it up"
  end
end
