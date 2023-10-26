function init() {
  const countField = document.getElementById('letters-calls-form-count-field');
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const lettersAndCallsAdjustmentContainer = document.getElementById('letters-and-calls-adjustment-container');
  const claimCostTable = document.getElementById('claim-cost-table');
  const caseworkerAdjustedValue = document.getElementById('letters_calls_caseworker_allowed_amount');

  if (lettersAndCallsAdjustmentContainer && countField) {
    calculateAdjustedAmount();
    calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    claimCostTable.hidden = false;
    calculateAdjustedAmount();
  }

  function calculateAdjustedAmount() {
    const count = countField?.value;
    const unitPrice = calculateChangeButton?.getAttribute('data-unit-price');
    const upliftAmount = calculateChangeButton?.getAttribute('data-uplift-amount');
    const upliftFactor = (parseFloat(upliftAmount) / 100) + 1;
    const totalPrice = "£" + (count * unitPrice * upliftFactor).toFixed(2);
    caseworkerAdjustedValue.innerHTML = totalPrice;
  }
}

document.addEventListener('DOMContentLoaded', init);
