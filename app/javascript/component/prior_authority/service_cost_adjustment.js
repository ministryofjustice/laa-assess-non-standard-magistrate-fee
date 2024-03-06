function init() {
  const hoursField = document.getElementById('prior_authority_service_cost_form_period_1i');
  const minutesField = document.getElementById('prior_authority_service_cost_form_period_2i')
  const costPerHourField = document.getElementById('prior-authority-service-cost-form-cost-per-hour-field')
  const itemsField = document.getElementById('prior-authority-service-cost-form-items-field')
  const costPerItemField = document.getElementById('prior-authority-service-cost-form-cost-per-item-field')
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const AdjustedCost = document.getElementById('adjusted-cost');

  if (calculationType() != 'unknown_type') {
    updateDomElements();
    calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function calculationType() {
    if (hoursField && minutesField && costPerHourField) {
      return 'per_hour';
    } else if (itemsField && costPerItemField) {
      return 'per_item';
    } else {
      return 'unknown_type';
    }
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    updateDomElements();
  }

  function updateDomElements() {
    const totalPrice = calculateAdjustedCost();
    AdjustedCost.innerHTML = totalPrice;
  }

  function calculateAdjustedCost() {
    switch(calculationType()) {
      case 'per_hour':
        return calculateTimeCost()
      case 'per_item':
        return calculateItemCost()
      default:
        throw new Error('Unrecognized calculation type!');
    }
  }

  function calculateTimeCost() {
    const unitPrice = parseFloat(costPerHourField.value)

    checkMinutesThreshold();

    if(isNaN(hoursField?.value) || isNaN(minutesField?.value)){
      return '--';
    }

    if(hoursField?.value && minutesField?.value){
      var minutes = (parseInt(hoursField.value) * 60) + parseInt(minutesField.value);
    }

    // rounding to two decimal places
    return (`${((minutes / 60) * unitPrice).toFixed(2)}`);
  }

  function calculateItemCost() {
    const items = parseInt(itemsField.value)
    const unitPrice = parseFloat(costPerItemField.value)

    // rounding to two decimal places
    return (`${(items * unitPrice).toFixed(2)}`);
  }

  function checkMinutesThreshold(){
    if(minutesField){
      if(parseInt(minutesField.value) >= 60){
        minutesField.value = 59;
      }
    }
  }
}

document.addEventListener('DOMContentLoaded', (_event) => {
  const serviceCostAdjustmentContainer = document.getElementById('service-cost-adjustment-container');

  if (serviceCostAdjustmentContainer) init()
})
