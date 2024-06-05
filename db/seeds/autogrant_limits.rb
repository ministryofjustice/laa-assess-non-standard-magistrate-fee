require 'csv'

def limits
  file_name = Rails.root.join('db/migrate/20240308140314_create_autogrant_limits.csv')
  limits = CSV.read(file_name, headers: true).map { _1.to_h }
  limits.each do |limit|
    limit['service'] = lookup_service(limit['service'])
  end
end

def lookup_service(service_name)
  @service_ids ||= I18n.t("prior_authority.service_types").to_h.invert
  @service_ids.fetch(service_name)
end

AutograntLimit.upsert_all(limits, unique_by: [:service, :start_date])
