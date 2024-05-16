import Decimal from 'decimal.js';

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
    if(isNaN(this.hoursField?.value) || isNaN(this.minutesField?.value) || isNaN(this.costPerHourField?.value)) {
      return '--';
    }

    const unitPrice = new Decimal(this.costPerHourField.value)
    let minutes

    this.checkMinutesThreshold();

    if(this.hoursField?.value && this.minutesField?.value){
      minutes = (parseInt(this.hoursField.value) * 60) + parseInt(this.minutesField.value);
    }

    const unrounded = unitPrice.times(minutes).dividedBy(60)
    return unrounded.toFixed(2);
  }

  calculateItemCost() {
    if(isNaN(this.itemsField?.value) || isNaN(this.costPerItemField?.value)){
      return '--';
    }

    const items = parseInt(this.itemsField.value)
    const unitPrice = new Decimal(this.costPerItemField.value)

    const unrounded = unitPrice.times(items);
    return unrounded.toFixed(2);
  }

  checkMinutesThreshold() {
    if(this.minutesField){
      if(parseInt(this.minutesField.value) >= 60){
        this.minutesField.value = 59;
      }
    }
  }
}
