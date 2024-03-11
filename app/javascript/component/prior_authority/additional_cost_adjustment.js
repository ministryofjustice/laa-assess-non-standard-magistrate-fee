import CostAdjustment from './cost_adjustment.js'

function init() {
  const fields = [
    document.getElementById('prior_authority_additional_cost_form_period_1i'),
    document.getElementById('prior_authority_additional_cost_form_period_2i'),
    document.getElementById('prior-authority-additional-cost-form-cost-per-hour-field'),
    document.getElementById('prior-authority-additional-cost-form-items-field'),
    document.getElementById('prior-authority-additional-cost-form-cost-per-item-field'),
    document.getElementById('calculate_change_button'),
    document.getElementById('adjusted-cost'),
  ]

  const costAdjustment = new CostAdjustment(...fields)

  if (costAdjustment.calculationType() != 'unknown_type') {
    costAdjustment.calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    costAdjustment.updateDomElements();
  }
}

document.addEventListener('DOMContentLoaded', (_event) => {
  const additionalCostAdjustmentContainer = document.getElementById('additional-cost-adjustment-container');

  if (additionalCostAdjustmentContainer) init()
})
