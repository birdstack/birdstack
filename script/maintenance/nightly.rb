require 'rubygems'
require 'curb'

internal_url = 'http://localhost/'
external_url = 'http://birdstack.com/'

year = Time.now.year
month = Time.now.month
day = Time.now.day

today_utc = Time.local(year, month, day).utc
yesterday_utc = today_utc - 1.day

remember_me_d = RememberMeCookie.destroy_all(['expires_at < ?', Time.now])
session_d = ActiveRecord::Base.connection.delete("DELETE FROM sessions WHERE updated_at < #{ActiveRecord::Base.connection.quote(Time.now - REMEMBER_ME_COOKIE_DURATION)}")
user_d = User.destroy_all(['activated_at IS NULL and created_at < ?', Time.now - ACCOUNT_ACTIVIATION_TIMEOUT])
password_d = PasswordRecoveryCode.destroy_all(['created_at < ?', Time.now - PASSWORD_RECOVERY_CODE_DURATION])
search_d = SavedSearch.destroy_all(['temp = 1 AND updated_at < ?', Time.now - TEMP_SAVED_SEARCH_TIMEOUT])

# Find exceptions where the exception handler caused an exception.  So, we probably didn't get an email.
failsafes = `grep -A 10 "\\ FAILSAFE /" #{RAILS_ROOT + "/log/production.log"}`
disk_usage = `df -h /`

message =<<EOT
Users activated yesterday: #{User.count(:conditions => ['activated_at >= ? AND activated_at < ?', yesterday_utc, today_utc])}
Observations added yesterday: #{Sighting.count(:conditions => ['created_at >= ? AND created_at < ?', yesterday_utc, today_utc])}
Observation photos added yesterday: #{SightingPhoto.count(:conditions => ['created_at >= ? AND created_at < ?', yesterday_utc, today_utc])}
Location photos added yesterday: #{UserLocationPhoto.count(:conditions => ['created_at >= ? AND created_at < ?', yesterday_utc, today_utc])}
Trip photos added yesterday: #{TripPhoto.count(:conditions => ['created_at >= ? AND created_at < ?', yesterday_utc, today_utc])}


Total activated users: #{User.count(:conditions => ['activated_at IS NOT NULL'])}
Total observations: #{Sighting.count}
Total observation photos: #{SightingPhoto.count}
Total location photos: #{UserLocationPhoto.count}
Total trip photos: #{TripPhoto.count}

---

Unactivated accounts destroyed: #{user_d.size}
Remember Me Cookies destroyed: #{remember_me_d.size}
Password recovery codes destroyed: #{password_d.size}
Sessions destroyed: #{session_d}
Temp searches destroyed: #{search_d.size}

---

Disk usage:
#{disk_usage}
---

Failsafe exceptions:
#{failsafes}

EOT

Curl::Easy.http_post(internal_url + 'contact', Curl::PostField.content('contact[name]', 'Birdstack Bot'),
	Curl::PostField.content('contact[email]', 'birdstack@birdstack.com'),
	Curl::PostField.content('contact[subject]', 'Nightly Status'),
	Curl::PostField.content('contact[body]', message)
)

# This should generate a test exception email
Curl::Easy.perform(external_url + 'test_exception')
