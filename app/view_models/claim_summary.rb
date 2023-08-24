class ClaimSummary
  include ActiveModel::Model
  attr_accessor :laa_reference, :defendants

  def main_defendant_name
    defendant = defendants.detect { |defendant| defendant['main'] }
    defendant['name']
  end
end