import Decimal from 'decimal.js';
import {checkCurrencyString, convertCurrencyToNumber} from '../../lib/currencyChecker.js';

function init() {
  const hoursField = document.getElementById('prior_authority_travel_cost_form_travel_time_1');
  const minutesField = document.getElementById('prior_authority_travel_cost_form_travel_time_2')
  const costPerHourField = document.getElementById('prior-authority-travel-cost-form-travel-cost-per-hour-field')
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const adjustedCost = document.getElementById('adjusted-cost');

  if (hoursField && minutesField && costPerHourField) {
    calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    updateDomElements();
  }

  function updateDomElements() {
    const totalPrice = calculateAdjustedCost();
    adjustedCost.innerHTML = totalPrice;
  }

  function calculateAdjustedCost() {
    if(isNaN(hoursField?.value) || isNaN(minutesField?.value) || checkCurrencyString(costPerHourField?.value)) {
      return '--';
    }else{
      let costPerHourNum = convertCurrencyToNumber(costPerHourField?.value)
      let unitPrice = new Decimal(costPerHourNum)

      checkMinutesThreshold();

      var minutes = calculateChangeButton?.getAttribute('data-provider-time-spent');

      if(hoursField?.value && minutesField?.value){
        minutes = (parseInt(hoursField.value) * 60) + parseInt(minutesField.value);
      }

      const unrounded = unitPrice.times(minutes).dividedBy(60)
      return `${unrounded.toFixed(2)}`;
    }
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
  const travelCostAdjustmentContainer = document.getElementById('travel-cost-adjustment-container');

  if (travelCostAdjustmentContainer) init()
})
