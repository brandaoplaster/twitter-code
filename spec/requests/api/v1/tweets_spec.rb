require 'rails_helper'

RSpec.describe "Api::V1::Tweets", type: :request do
  describe "GET /api/v1/tweets?user_id=:id&page=:page" do
    context 'user exists' do
      let(:user) { create(:user) }
      let(:tweets_number) { Random.rand(15..25) }

      before { tweets_number.times { create(:tweet, user: user) } }

      it do
        get "/api/v1/tweets?user_id=#{user.id}&page=1", headers: header_with_authentication(user)
        expect(response).to have_http_status(:success)
      end

      it 'returns right tweets' do
        get "/api/v1/tweets?user_id=#{user.id}&page=1", headers:header_with_authentication(user)
        expect(json).to eql(each_serialized(Api::V1::TweetSerializer, user.tweets[0..14]))
      end

      it 'returns 15 elemets on first page' do
        get "/api/v1/tweets?user_id=#{user.id}&page=1", headers:header_with_authentication(user)
        expect(json.count).to eql(15)
      end

      it 'returns remaining elements on second page' do
        get "/api/v1/tweets?user_id=#{user.id}&page=2", headers:header_with_authentication(user)
        remaining = user.tweets.count - 15
        expect(json.count).to eql(remaining)
      end
    end

    context 'user dont exist' do
      let(:user) { create(:user) }
      let(:user_id) { -1 }

      before { get "/api/v1/tweets?user_id=#{user_id}&page=1", headers:header_with_authentication(user) }

      it { expect(response).to have_http_status(:not_found) }
    end
  end
end
