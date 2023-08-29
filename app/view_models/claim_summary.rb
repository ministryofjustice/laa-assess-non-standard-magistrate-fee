class ClaimSummary
  include ActiveModel::Model
  include ActiveModel::Attributes
  attribute :laa_reference
  attribute :defendants

  def main_defendant_name
    defendant = defendants.detect { |defendant| defendant['main'] }
    defendant['name']
  end

  def self.build(attributes)
    new(attributes.slice(*attribute_names))
  end
end