module PriorAuthorityTagHelper
  include ActionView::Helpers::TagHelper

  def show_tag_on_details_page?(submission)
    tag_colour(submission) != 'grey'
  end

  def prior_authority_state_tag(submission)
    tag.span(class: "govuk-tag govuk-tag--#{tag_colour(submission)}") do
      I18n.t("prior_authority.applications.statuses.#{augmented_state(submission)}")
    end
  end

  private

  def tag_colour(submission)
    {
      'submitted' => 'grey',
      'in_progress' => 'purple',
      'provider_updated' => 'grey',
      'sent_back' => 'yellow',
      'part_grant' => 'blue',
      'granted' => 'green',
      'rejected' => 'red'
    }.fetch(augmented_state(submission))
  end

  def augmented_state(submission)
    return 'in_progress' if submission.state == 'submitted' && submission.assignments.any?

    submission.state
  end
end
