module DataMigrationTools
  class DisbursementPositionUpdater
    def initialize(submission)
      @submission = submission
    end

    def call
      disbursements ||= @submission.data['disbursements']
      return unless disbursements

      disbursements.each_with_index do |disbursement, idx|
        position = disbursement_position(disbursement)
        @submission.data['disbursements'][idx]['position'] = position
      end

      @submission.save!(touch: false)
    end

    private

    def disbursements
      @submission.data['disbursements']
    end

    def disbursement_position(disbursement)
      sorted_disbursement_ids.index(disbursement['id']) + 1
    end

    def sorted_disbursement_ids
      @sorted_disbursement_ids = disbursements.sort_by do |disb|
        [
          disb['disbursement_date'].to_date || 100.years.ago,
          translated_disbursement_type(disb)&.downcase || '',
        ]
      end.pluck('id')
    end

    def translated_disbursement_type(disbursement)
      if disbursement['disbursement_type']['value'] == 'other'
        disbursement['other_type']['en']
      else
        disbursement['disbursement_type']['en']
      end
    end
  end
end
