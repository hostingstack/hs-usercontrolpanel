require File.expand_path('../../../test_helper', __FILE__)

class Api::Cli::V1::ApiControllerTest < ActionController::TestCase
  context "without user authentication" do
    context "#info" do
      setup do
        get :info
      end

      should respond_with :success
      should("return the platform name") do
        JSON.parse(response.body)["name"].should == "hs"
      end
    end
  end
end
