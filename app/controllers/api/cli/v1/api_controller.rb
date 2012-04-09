class Api::Cli::V1::ApiController < ActionController::Base
  rescue_from StandardError do |e|
    Rails.logger.error "Error: %s\n  %s" % [e.message, e.backtrace.join("\n")]
    data = {:error => e.to_s}
    status = 500
    respond_to do |format|
      format.xml { render :xml => data.to_xml(:root => :errors), :status => status }
      format.json { render :json => data, :status => status }
    end
  end
  rescue_from ActiveResource::ResourceNotFound do |e|
    Rails.logger.error "Error: %s\n  %s" % [e.message, e.backtrace.join("\n")]
    data = {:error => e.to_s}
    status 404
    respond_to do |format|
      format.xml { render :xml => data.to_xml(:root => :errors), :status => status }
      format.json { render :json => data, :status => status }
    end
  end

  def info
    render :json => {:name => "hs", :build => 1, :version => "0.9.5",
      :description => "HostingStack Platform", :api_version => 4,
      :cloud_name => CLOUD_CONFIG['cloud.name'], :support => CLOUD_CONFIG['cloud.email.support'],
    }
  end

private
  def auth_required
    if not current_user
      data = {:error => "Authentication tokens missing or invalid"}
      status = 401
      respond_to do |format|
        format.xml { render :xml => data.to_xml(:root => :errors), :status => status }
        format.json { render :json => data, :status => status }
      end
    end
  end
end
