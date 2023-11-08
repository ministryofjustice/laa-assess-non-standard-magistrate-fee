module DisbursementSystemHelpers
  def verify_disbursement_item
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        'Change'
      )
    end
  end
end
