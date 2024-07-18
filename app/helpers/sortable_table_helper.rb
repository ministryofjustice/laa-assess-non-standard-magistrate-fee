module SortableTableHelper
  def table_header_with_form(column, i18n_stem, index, path, sort_by, sort_direction, additional_classes: [])
    table_header(column, sort_by, sort_direction, additional_classes) do |next_direction|
      reorder_form(path, column, next_direction, i18n_stem, index)
    end
  end

  def table_header_with_link(column, i18n_stem, params, sort_by, sort_direction, prefix)
    table_header(column, sort_by, sort_direction) do |next_direction|
      link_to url_for(params.deep_merge(prefix => { 'sort_by' => column, 'sort_direction' => next_direction })) do
        tag.button do
          I18n.t(column, scope: i18n_stem)
        end
      end
    end
  end

  def table_header(column, sort_by, sort_direction, additional_classes: [])
    if sort_by == column.to_s
      aria_sort = sort_direction
      next_direction = sort_direction == 'ascending' ? 'descending' : 'ascending'
    else
      aria_sort = 'none'
      next_direction = 'ascending'
    end

    tag.th(scope: 'col', class: ['govuk-table__header'] + additional_classes, 'aria-sort': aria_sort) do
      yield next_direction
    end
  end

  def reorder_form(path, column, next_direction, i18n_stem, index)
    tag.form(action: path, method: 'get') do
      safe_join([tag.input(type: 'hidden', name: 'sort_by', value: column),
                 tag.input(type: 'hidden', name: 'sort_direction', value: next_direction),
                 tag.button(type: 'submit', 'data-index': index) do
                   I18n.t(column, scope: i18n_stem)
                 end])
    end
  end
end
