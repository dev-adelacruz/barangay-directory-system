# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  include Authorizable

  respond_to :json
end
