Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'tweets/index'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'tweets/show'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'tweets/create'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'tweets/destroy'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'tweets/update'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/create'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/destroy'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/update'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/current'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/show'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/following'
    end
  end

  namespace :api do
    namespace :v1 do
      get 'users/followers'
    end
  end

  namespace :api do
    namespace :v1  do
      post 'user_token' => 'user_token#create'
    end
  end
end
