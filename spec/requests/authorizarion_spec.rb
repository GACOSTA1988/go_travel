require 'rails_helper'


describe "authorization routes", :type => :request do

  before(:each) do
    User.all.each { |u| u.destroy }
    User.create!({email: "admin@admin.com", password: "admin555"})
  end

  it 'returns 401 if user is not logged in' do
    get "/destinations"
    expect(response).to have_http_status(401)
  end

  it 'returns all destinations' do
    post '/authenticate', params: { :email => "admin@admin.com", :password => "awdfadsfasdf" }
    expect(response).to have_http_status(401)
  end
end
