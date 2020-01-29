require 'rails_helper'


describe "reviews routes", :type => :request do

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
    post "/destinations/#{@destination.id}/reviews", params: { :review => {:body_text => 'test_body_text', :rating => 5, :destination_id => @destination.id.to_i} }, headers: @hd
    @review = Review.find(JSON.parse(response.body)['id'])
  end

  it 'returns the body_text body_text' do
    get "/destinations/#{@destination.id}/reviews", headers: @hd
    expect(JSON.parse(response.body).first['body_text']).to eq('test_body_text')
  end

  it 'returns the destination rating' do
    get "/destinations/#{@destination.id}/reviews", headers: @hd
    expect(JSON.parse(response.body).first['rating']).to eq(5)
  end

  it 'returns a created status' do
    post "/destinations/#{@destination.id}/reviews", params: { :review => {:body_text => 'test_body_text', :raiting => 5, :destination_id => @destination.id.to_i} }, headers: @hd
    expect(response).to have_http_status(:created)
  end

  it 'returns unprocessable entity status when given invalid input' do
    post "/destinations/#{@destination.id}/reviews", params: { :review => {:body_text => 'test_body_text', :rating => 3, :destination_id => 0 } }, headers: @hd
    expect(response).to have_http_status(422)
  end

  it 'deletes a review for a destination' do
    delete "/destinations/#{@destination.id}/reviews/#{@review.id}", headers: @hd
    get "/destinations/#{@destination.id}/reviews", headers: @hd
    expect(JSON.parse(response.body).length).to eq(0)
  end

  it 'Patches a review' do
    patch "/destinations/#{@destination.id}/reviews/#{@review.id}", params: { :review => {:body_text => 'updated_body_text', :raiting => 5, :destination_id => @destination.id.to_i} }, headers: @hd
    get "/destinations/#{@destination.id}/reviews", headers: @hd
    expect(JSON.parse(response.body).last["body_text"]).to eq("updated_body_text")
  end

  it 'returns unprocessable entity status when given invalid input' do
    get "/destinations", headers: @hd
    patch "/destinations/#{@destination.id}/reviews/#{@review.id}", params: { :review => {:body_text => 'updated_body_text', :raiting => nil, :destination_id => 0} }, headers: @hd
    expect(response).to have_http_status(422)
  end

  it 'returns a single review for a destination' do
    get "/destinations/#{@destination.id}/reviews/#{@review.id}", headers: @hd
    expect(JSON.parse(response.body)['body_text']).to eq('test_body_text')
  end

  it 'returns all reviews for a destination' do
    get "/destinations/#{@destination.id}/reviews", headers: @hd
    expect(JSON.parse(response.body).last['body_text']).to eq('test_body_text')
  end

end
