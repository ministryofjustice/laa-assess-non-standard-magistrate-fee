import Decimal from 'decimal.js';

function init() {
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const page = calculateChangeButton?.getAttribute('data-page');
  const lettersAndCallsAdjustmentContainer = document.getElementById('letters-and-calls-adjustment-container');
  const countField = document.getElementById(`nsm-letters-calls-form-${page}-count-field`);
  const caseworkerAdjustedValue = document.getElementById('letters_calls_caseworker_allowed_amount');
  const upliftNoField = document.getElementById(`nsm-letters-calls-form-${page}-uplift-no-field`);

  if (lettersAndCallsAdjustmentContainer && countField) {
    updateDomElements();
    calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    updateDomElements();
  }

  function updateDomElements() {
    const totalPrice = calculateAdjustedAmount();
    caseworkerAdjustedValue.innerHTML = totalPrice;
  }

  function calculateAdjustedAmount() {
    const count = parseInt(countField?.value);
    const unitPrice = new Decimal(calculateChangeButton?.getAttribute('data-unit-price'));
    let upliftAmount = calculateChangeButton?.getAttribute('data-uplift-amount');

    if (!(upliftAmount && upliftNoField.checked)) {
      upliftAmount = 0
    }

    const upliftFactor = new Decimal(upliftAmount).dividedBy(100).plus(1);

    const unrounded = unitPrice.times(count).times(upliftFactor);
    return (`£${unrounded.toFixed(2)}`);
  }
}

document.addEventListener('DOMContentLoaded', init);
