# frozen_string_literal: true

class HealthcheckController < ApplicationController
  def ping
    render json: build_args, status: :ok
  end

  private

  def build_args
    {
      hello: 'world'
    }
  end
end
