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
    const count = countField?.value;
    const unitPrice = calculateChangeButton?.getAttribute('data-unit-price');
    let upliftAmount = calculateChangeButton?.getAttribute('data-uplift-amount');
    const vatMultiplier = parseFloat(calculateChangeButton?.getAttribute('data-vat-multiplier'));

    if (!(upliftAmount && upliftNoField.checked)) {
      upliftAmount = 0
    }

    const upliftFactor = (parseFloat(upliftAmount) / 100) + 1;

    // rounding:
    // * when VAT exists - round down
    // * when no VAT exists - round to nearest decimal
    if (vatMultiplier === 1.0) {
      return (`£${(count * unitPrice * upliftFactor).toFixed(2)}`);
    } else {
      return (`£${Math.floor(count * unitPrice * upliftFactor * vatMultiplier * 100) / 100}`);
    }
  }
}

document.addEventListener('DOMContentLoaded', init);
