require Rails.root.join('app/helpers/form_builder_helper')

ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  include FormBuilderHelper
end
