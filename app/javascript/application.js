import "@hotwired/turbo-rails"
import "./controllers"
import "./component/sortable_table"
import "./component/letters_calls_adjustment"
import "./component/work_item_adjustment"
// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'

initAll()

Turbo.setFormMode("off")
