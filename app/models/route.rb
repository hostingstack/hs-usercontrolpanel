class Route < ActiveResource::Base
  extend ActiveSupport::Memoizable
  self.site = HS_CONFIG['cc_api_host']
  self.prefix = '/api/v1/apps/:app_name/'
  self.user = HS_CONFIG['cc_api_user']
  self.password = HS_CONFIG['cc_api_password']

  schema do
    string 'subdomain'
    integer 'domain_id'
  end
  
  def app_name; prefix_options[:app_name]; end
  def app; App.find(app_name); end
  memoize :app
  
  def hostname
    (subdomain.blank? ? '' : (subdomain + '.')) + domain.name
  end
  def url
    hostname
  end
  def dns_state
    if self.dns_verify_last_successful
      return [:ok, 'Your App can be reached at this location.']
    end
    if not self.domain.verified
      return [:error, 'We will not serve requests to this location your ownership of this domain is verified.']
    end
    return [:warning, 'We will serve requests to this location, but the DNS settings do not seem to be correct.']
  end
  memoize :dns_state

  def ssl_state
    if self.key_material_id
      return [:ok, 'SSL Configured.']
    end
    return [:off, 'No key configured for SSL.']
  end
  memoize :ssl_state

  def domain
    Domain.to_adapter.find_first :id => domain_id
  end
  memoize :domain

  def verify_dns!
    self.attributes = JSON.parse(post(:verify).body)
  end

  def expected_dns
    @_expected_dns ||= get(:expected_dns)
  end

  def <=>(other)
    default_route = self.app.routes[0]
    if self == default_route
      return -1
    end
    if other == default_route
      return 1
    end

    default_route_domain_name = default_route.domain.name
    this_domain = self.domain.name
    other_domain = other.domain.name
    if(this_domain != other_domain)
      if this_domain == default_route_domain_name
	return -1
      end
      if other_domain == default_route_domain_name
	return 1
      end
      this_domain <=> other_domain
    else
      (self.subdomain||'') <=> (other.subdomain||'')
    end
  end
end
