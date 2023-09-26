// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'
// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'

window.$ = $

initAll()
MOJFrontend.initAll()
