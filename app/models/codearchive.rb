require 'uuidtools'
require 'net/http'
class Codearchive
  class CodearchiveUploadFailed < StandardError
    def initialize(resp)
      @code = resp.code
    end
    def message
      "Upload failed. Remote server said: #{@code.to_s}"
    end
  end
  class CodearchiveInvalidError < StandardError; end
  class PermissionDeniedError < StandardError; end

  attr_accessor :code_token
  def initialize(app, file)
    @app = app
    @file = file
    @code_token = nil
  end

  def validate
    raise CodearchiveInvalidError.new unless true
  end

  def save!
    validate

    @code_token = UUIDTools::UUID.random_create.hexdigest
    target = @app.code_archive_url_prefix + "code/code-#{@code_token}.zip"
    url = URI.parse(target)
    Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Put.new(target)
      response = http.request(req, @file.read)
      raise CodearchiveUploadFailed.new(response) unless response.code.to_s == 201.to_s
    end
  end

end

