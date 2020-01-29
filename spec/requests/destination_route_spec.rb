require 'rails_helper'


describe "destination routes", :type => :request do

  before(:each) do
    User.all.each { |u| u.destroy }
    Destination.all.each { |d| d.destroy }
    Review.all.each { |d| d.destroy }
    User.create!({email: "admin@admin.com", password: "admin555"})
    post '/authenticate', params: { :email => "admin@admin.com", :password => "admin555" }
    @token = JSON.parse(response.body)["auth_token"]
    @hd = { :Authorization => @token }
    post '/destinations', params: { :destination => {:name => 'test_name', :country => 'test_country'} }, headers: @hd
    @destination = Destination.find(JSON.parse(response.body)['id'])
    post '/destinations', params: { :destination => {:name => 'test_name2', :country => 'test_country2'} }, headers: @hd
    @destination2 = Destination.find(JSON.parse(response.body)['id'])
    post "/destinations/#{@destination.id}/reviews", params: { :review => {:body_text => 'test_body_text', :rating => 5, :destination_id => @destination.id.to_i} }, headers: @hd
    @review = Review.find(JSON.parse(response.body)['id'])
  end

  it 'returns the body_text body_text' do
    get "/destinations/#{@destination.id}", headers: @hd
    expect(JSON.parse(response.body)['name']).to eq('test_name')
  end

  it 'returns the destination country' do
    get "/destinations/#{@destination.id}", headers: @hd
    expect(JSON.parse(response.body)['country']).to eq('test_country')
  end

  it 'returns a created status' do
    post "/destinations/", params: { :destination => {:name => 'test_name3', :country => 'test_country3'} }, headers: @hd
    expect(response).to have_http_status(:created)
  end

  it 'returns unprocessable entity status when given invalid input' do
    post "/destinations/", params: { :destination => {:name => nil, :country => nil} }, headers: @hd
    expect(response).to have_http_status(422)
  end

  it 'deletes a destination' do
    delete "/destinations/#{@destination2.id}", headers: @hd
    delete "/destinations/#{@destination.id}", headers: @hd
    get "/destinations", headers: @hd
    expect(JSON.parse(response.body).length).to eq(0)
  end
  #
  it 'Patches a destination' do
    patch "/destinations/#{@destination.id}", params: { :destination => {:name => 'updated_test_name', :country => 'test_country'} }, headers: @hd
    get "/destinations/#{@destination.id}", headers: @hd
    expect(JSON.parse(response.body)["name"]).to eq("updated_test_name")
  end

  it 'returns unprocessable entity status when given invalid input' do
    patch "/destinations/#{@destination.id}", params: { :destination => {:name => nil, :country => nil} }, headers: @hd
    expect(response).to have_http_status(422)
  end

  it 'returns all destinations' do
    get "/destinations", headers: @hd
    expect(JSON.parse(response.body).first['name']).to eq('test_name')
  end

  it 'returns all destinations sorted by reviews' do
    get "/destinations?by_reviews=true", headers: @hd
    expect(JSON.parse(response.body).first['name']).to eq('test_name')
  end

  it 'returns all destinations sorted by average rating' do
    get "/destinations?by_average=true", headers: @hd
    expect(JSON.parse(response.body).first['name']).to eq('test_name')
  end

  it 'returns all reviews for a single country' do
    get "/destinations?country=test_country", headers: @hd
    expect(JSON.parse(response.body).first.first['body_text']).to eq('test_body_text')
  end

end
