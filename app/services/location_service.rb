class LocationService
  class << self
    def inside_m25?(postcode)
      easting, northing = os_coordinates_from_postcode(postcode)
      query = prepare_query(easting, northing)

      result = ActiveRecord::Base.connection.execute(query)
      result.to_a.dig(0, 'st_contains')
    end

    def os_coordinates_from_postcode(postcode)
      canonical = postcode.delete(' ').upcase
      results = HTTParty.get("https://api.os.uk/search/names/v1/find?query=#{canonical}&key=#{ENV.fetch('OS_API_KEY',
                                                                                                        nil)}")
      process_api_response(results, canonical)
    end

    def process_api_response(payload, postcode)
      raise "OS API returned unexpected format when queried for postcode #{postcode}" unless payload['results']

      matching = payload['results'].find { _1.dig('GAZETTEER_ENTRY', 'ID') == postcode }

      raise "OS API returned no matching entry for postcode #{postcode}" unless matching

      easting = matching.dig('GAZETTEER_ENTRY', 'GEOMETRY_X')
      northing = matching.dig('GAZETTEER_ENTRY', 'GEOMETRY_Y')

      raise "OS API did not provide coordinates in expected format for postcode #{postcode}" unless easting && northing

      [easting, northing]
    end

    def prepare_query(easting, northing)
      <<-SQL.squish.freeze
        SELECT ST_Contains(
          ST_MakePolygon(
            ST_GeomFromKML('#{m25_kml}')
          ),
          ST_Transform(
            ST_GeomFromText(
              'POINT(#{easting} #{northing})',
              #{OS_SRID}
            ),
            #{STANDARD_SRID}
          )
        );
      SQL
    end

    def m25_kml
      Rails.root.join('app/services/location_service/M25.kml').read
    end

    OS_SRID = 27_700
    STANDARD_SRID = 4326
  end
end
