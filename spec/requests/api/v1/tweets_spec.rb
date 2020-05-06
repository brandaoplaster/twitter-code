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

  describe 'GET /api/v1/tweets/:id' do
    context 'when tweet exists' do
      let(:user) { create(:user) }

      context 'regular tweet' do
        let(:tweet) { create(:tweet) }

        before { get "/api/v1/tweets/#{tweet.id}" }

        it { expect(response).to have_http_status(:success) }

        it 'returns valid tweet in json' do
          expect(json).to eql(serialized(Api::V1::TweetSerializer, tweet))
        end

        it 'tweet owner is present' do
          expect(json['user']).to eql(serialized(Api::V1::UserSerializer, tweet.user))
        end
      end

      context 'retweet' do
        let(:tweet_original) { create(:tweet) }
        let(:tweet) { create(:tweet, tweet_original: tweet_original) }

        before { get "/api/v1/tweets/#{tweet.id}" }

        it { expect(response).to have_http_status(:success) }

        it 'returns valid tweet in json' do
          expect(json).to eql(serialized(Api::V1::TweetSerializer, tweet))
        end

        it 'tweet owner is present' do
          expect(jon['user']).to eql(serialized(Api::V1::UserSerializer, tweet.user))
        end

        it 'tweet original is present' do
          expect(json['tweet_original']).to eql(serialized(Api::V1::TweetSerializer, tweet_original))
        end
      end
    end

    context 'when tweet dont exist' do
      let(:tweet_id) { -1 }

      before { get "/api/v1/tweets/#{tweet_id}" }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  context 'DELETE /api/v1/tweets/:tweet_id' do
    context 'unauthenticated' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/tweets/-1'
    end

    context 'authenticated' do
      context 'resource owner' do
        let(:user) { create(:user) }

        before { @tweet = create(:tweet, user: user) }

        it do
          delete "/api/v1/tweets/#{@tweet.id}", headers: header_with_authentication(user)
          expect(response).to have_http_status(:no_content)
        end

        it 'delete tweet' do
          expect do
            delete "/api/v1/tweets/#{@tweet.id}", headers: header_with_authentication(user)
          end.to change { Tweet.count }.by(-1)
        end
      end

      context 'not resource owner' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:tweet) { create(:tweet, user: other_user) }

        before do
          delete "/api/v1/tweets/#{tweet.id}", headers: header_with_authentication(user)
        end

        it { expect(response).to have_http_status(:forbidden) }
      end
    end
  end

  context 'PUT /api/v1/tweets/:tweet_id' do
    context 'unauthenticated' do
      it_behaves_like :deny_witout_authorization, :put '/api/tweets/-1'
    end

    context 'authenticated' do
      context 'resoure owner' do
        let(:user) { create(:user) }
        let(:tweet) { create(:tweet, user: user) }
        let(:tweet_params) { attributes_for(:tweet) }

        before { put "/api/v1/tweets/#{tweet.id}", params: { tweet: tweet_params }, headers: header_with_authentication(user) }

        it { expect(response).to have_http_status(:success) }

        it 'returns tweet updated in json' do
          post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
          expect(json).to include_json(tweet_params)
        end
      end

      context 'not resource owner' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:tweet) { create(:tweet, user: other_user) }
        let(:tweet_params) { attributes_for(:tweet) }

        before do
          put "/api/v1/tweets/#{tweet.id}", params: { tweet: tweet_params }, headers: header_with_authentication(user)
        end

        it { expect(response).to have_http_status(:forbidden) }
      end
    end
  end

  describe 'POST /api/v1/tweets' do
    context 'unauthenticated' do
      it_behaves_like :deny_without_autorization, :post, '/api/v1/users/-1'
    end

    context 'authenticated' do
      let(:user) { create(:user) }

      context 'valid params' do
        context 'regular tweet' do
          let(:tweet_params) { attributes_for(:tweet) }

          it 'return created' do
            post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            expect(response).to have_http_status(:created)
          end

          it 'returns right tweet in json' do
            post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            expect(json).to include_json(tweet_params)
          end

          it 'create tweet' do
            expect do
              post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            end.to change { Tweet.count }.by(1)
          end
        end

        context 'retweet' do
          before { @tweet_original = create(:tweet) }

          let(:tweet_params) { attributes_for(:tweet, tweet_original_id: @tweet_original_id) }

          it 'return created' do
            post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            expect(response).to have_http_status(:created)
          end

          it 'returns tweet in json' do
            post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            expect(json).to include_json(tweet_params)
          end

          it 'returns original tweet in json' do
            post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            expect(json['tweet_original']).to eql(serialized(Api::V1::TweetSerializer, @tweet_original))
          end

          it 'create tweet' do
            expect do
              post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user)
            end.to change { Tweet.count }.by(1)
          end
        end
      end
    end

    context 'invalid params' do
      let(:tweet_params) { { foo: :bar } }

      before { post '/api/v1/tweets/', params: { tweet: tweet_params }, headers: header_with_authentication(user) }

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end
  end
end
