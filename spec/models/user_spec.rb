require 'rails_helper'

RSpec.describe User, type: :model do
  it '#name' do
    described_class.new(first_name: 'david')
  end
end
