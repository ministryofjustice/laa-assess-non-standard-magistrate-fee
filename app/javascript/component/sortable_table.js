import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'

window.$ = $
$(document).on('page:load', MOJFrontend.initAll())
