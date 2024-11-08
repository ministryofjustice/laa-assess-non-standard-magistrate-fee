class BackfillRecentAssignments < ActiveRecord::Migration[7.2]
  def up
    client = AppStoreClient.new
    Event.where(event_type: ['Event::Assignment',
                             'Nsm::Event::SendBack',
                             'PriorAuthority::Event::SendBack',
                             'Event::Unassignment'],
                created_at: DateTime.new(2024, 11, 8, 11, 15)..) # This is when the app store backfilled itself up to
         .order(created_at: :asc)
         .find_each do |event|
      if event.is_a?(Event::Assignment)
        client.assign(event.submission, event.primary_user)
      else
        client.unassign(event.submission)
      end
    end
  end
end
