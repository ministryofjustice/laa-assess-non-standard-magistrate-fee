import "@hotwired/turbo-rails"
import "./controllers"
import "./component/nsm/letters_calls_adjustment"
import "./component/nsm/work_item_adjustment"
import "./component/nsm/disbursement_adjustment"
import "./component/prior_authority/service_cost_adjustment"
import "./component/prior_authority/travel_cost_adjustment"
import "./component/prior_authority/additional_cost_adjustment"
import './component/date-picker'

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// set turbo to opt-in
// https://turbo.hotwired.dev/handbook/drive#disabling-turbo-drive-on-specific-links-or-forms
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
