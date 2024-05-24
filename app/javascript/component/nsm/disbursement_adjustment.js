import Decimal from 'decimal.js';

function init() {
  const disbursementAdjustmentForm = document.getElementById('disbursement-adjustment-form');
  const milesField = document.getElementById('nsm-disbursements-form-miles-field');
  const costField = document.getElementById('nsm-disbursements-form-total-cost-without-vat-field');
  const applyVatYesField = document.getElementById('nsm-disbursements-form-apply-vat-true-field');
  const calculateChangeButton = document.getElementById('calculate-change-button');
  const caseworkerAllowedAmount = document.getElementById('disbursement-caseworker-allowed-amount');
  const caseworkerAllowedVatRate = document.getElementById('disbursement-allowed-vat-rate');
  const total = document.getElementById('disbursement-total-allowed');

  if (disbursementAdjustmentForm ) {
    updateDomElements();
    calculateChangeButton.addEventListener('click', handleCalculateButtonClick);
  }

  function handleCalculateButtonClick(event) {
    event.preventDefault();
    updateDomElements();
  }

  function updateDomElements() {
    const netPrice = calculateNet();

    const allowedVatRate = new Decimal(applyVatYesField.checked ? calculateChangeButton.dataset.vatRate : 0);
    caseworkerAllowedAmount.innerHTML =  `£${ netPrice.toFixed(2) }`;
    caseworkerAllowedVatRate.innerHTML = `${ allowedVatRate.times(100).toFixed() }%`;
    total.innerHTML = `£${ netPrice.times(allowedVatRate.plus(1)).toFixed(2)}`
  }

  function calculateNet() {
    if (calculateChangeButton.dataset.mileageBased === 'true') {
      return new Decimal(milesField.value).times(calculateChangeButton.dataset.pricing);
    } else {
      return new Decimal(costField.value);
    }
  }
}

document.addEventListener('DOMContentLoaded', init);
