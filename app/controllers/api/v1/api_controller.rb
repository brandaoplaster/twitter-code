module Api
  module V1
    class ApiController < ApplicationController
      include Knock::Authenticable
      include CanCan::ControleAdditions
    end
  end
end
