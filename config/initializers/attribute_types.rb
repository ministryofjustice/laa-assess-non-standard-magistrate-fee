Dir["#{File.join(__dir__, '../../app/attributes/type')}/*.rb"].each { |f| require f }

ActiveModel::Type.register(:translated, Type::TranslatedObject)
ActiveModel::Type.register(:time_period, Type::TimePeriod)
ActiveModel::Type.register(:gbp, Type::Gbp)
ActiveModel::Type.register(:fully_validatable_integer, Type::FullyValidatableInteger)
