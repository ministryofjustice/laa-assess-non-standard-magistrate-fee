function init() {
  const workItemAdjustmentContainer = document.getElementById('work-items-adjustment-container');
  const hoursField = document.getElementById('work_item_form_time_spent_1i');
  const minutesField = document.getElementById('work_item_form_time_spent_2i');
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const caseworkerAdjustedValue = document.getElementById('work_item_caseworker_allowed_amount');

  if (workItemAdjustmentContainer && hoursField && minutesField) {
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
    const unitPrice = calculateChangeButton?.getAttribute('data-unit-price');
    const upliftAmount = calculateChangeButton?.getAttribute('data-uplift-amount');

    checkMinutesThreshold();

    var minutes = calculateChangeButton?.getAttribute('data-provider-time-spent');

    if(hoursField.value && minutesField.value){
      minutes = (parseInt(hoursField.value) * 60) + parseInt(minutesField.value);
    }

    if (upliftAmount) {
      const upliftFactor = (parseFloat(upliftAmount) / 100) + 1;
      return (`£${((minutes/60) * unitPrice * upliftFactor).toFixed(2)}`);
    } else {
      return (`£${( minutes/60 * unitPrice).toFixed(2)}`);
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

document.addEventListener('DOMContentLoaded', init);
