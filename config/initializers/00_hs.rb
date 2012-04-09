config = Rails.application.config

HS_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/hs.yml")[Rails.env]

CLOUD_CONFIG = ConfigSetting.as_hash

f = open('public/stylesheets/sass/variables.scss', 'wb')
f.write(ConfigSetting.generate_sass)
f.close

ActionMailer::Base.default_url_options = { :host => "cp.#{CLOUD_CONFIG['cloud.domain.name']}" }
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.raise_delivery_errors = true

