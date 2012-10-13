require 'spec_helper'

describe GameController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'ranking'" do
    it "returns http success" do
      get 'ranking'
      response.should be_success
    end
  end

end
