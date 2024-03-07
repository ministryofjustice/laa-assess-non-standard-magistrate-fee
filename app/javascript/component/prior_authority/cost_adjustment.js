export default class CostAdjustment {
  constructor(hoursField, minutesField, costPerHourField, itemsField, costPerItemField, calculateChangeButton, adjustedCost) {
    this.hoursField = hoursField;
    this.minutesField = minutesField;
    this.costPerHourField = costPerHourField;
    this.itemsField = itemsField;
    this.costPerItemField = costPerItemField;
    this.calculateChangeButton = calculateChangeButton;
    this.adjustedCost = adjustedCost;
  }

  calculationType() {
    if (this.hoursField && this.minutesField && this.costPerHourField) {
      return 'per_hour';
    } else if (this.itemsField && this.costPerItemField) {
      return 'per_item';
    } else {
      return 'unknown_type';
    }
  }

  updateDomElements() {
    const totalPrice = this.calculateAdjustedCost();
    this.adjustedCost.innerHTML = totalPrice;
  }

  calculateAdjustedCost() {
    switch(this.calculationType()) {
      case 'per_hour':
        return this.calculateTimeCost()
      case 'per_item':
        return this.calculateItemCost()
      default:
        throw new Error('Unrecognized calculation type!');
    }
  }

  calculateTimeCost() {
    const unitPrice = parseFloat(this.costPerHourField.value)

    this.checkMinutesThreshold();

    if(isNaN(this.hoursField?.value) || isNaN(this.minutesField?.value)){
      return '--';
    }

    if(this.hoursField?.value && this.minutesField?.value){
      var minutes = (parseInt(this.hoursField.value) * 60) + parseInt(this.minutesField.value);
    }

    // rounding to two decimal places
    return (`${((minutes / 60) * unitPrice).toFixed(2)}`);
  }

  calculateItemCost() {
    const items = parseInt(this.itemsField.value)
    const unitPrice = parseFloat(this.costPerItemField.value)

    // rounding to two decimal places
    return (`${(items * unitPrice).toFixed(2)}`);
  }

  checkMinutesThreshold() {
    if(this.minutesField){
      if(parseInt(this.minutesField.value) >= 60){
        this.minutesField.value = 59;
      }
    }
  }
}
