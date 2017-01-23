Given /^I am testing in an EFG context$/ do
  # TODO: remove me
end

When /^I try to access the list of lenders$/ do
  visit_path "#{efg_base_url}/lenders"
end

When /^I try to login as a valid EFG user$/ do
  assert ENV["EFG_USERNAME"] && ENV["EFG_PASSWORD"], "Please ensure that the EFG user credentials are available in the environment"

  # Need to do it this way to comply with CSRF protection
  visit_path "#{efg_base_url}/users/sign_in"
  fill_in "Username", :with => ENV["EFG_USERNAME"]
  fill_in "Password", :with =>ENV["EFG_PASSWORD"]
  click_button "Sign In"
end

When /^I visit the EFG home page$/ do
  visit_path "#{efg_base_url}"
end

Then /^I should be on the EFG home page$/ do
  page.has_selector?("#user_username").should == true # username input field
  page.has_selector?("#user_password").should == true # password input field
end

Then /^I should be on the EFG post-login page$/ do
  page.has_selector?(".alert-success").should == true # Signed in successfully message
  page.has_selector?("#welcome_message").should == true # Welcome back, first_name
  page.has_selector?("#logout").should == true # page has a logout link
end
