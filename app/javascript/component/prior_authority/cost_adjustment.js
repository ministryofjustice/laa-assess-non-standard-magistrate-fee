import Decimal from 'decimal.js';
import {invalidCurrencyString, convertCurrencyToNumber} from '../../lib/currencyChecker.js';

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
    if(isNaN(this.hoursField?.value) || isNaN(this.minutesField?.value) || invalidCurrencyString(this.costPerHourField?.value)) {
      return '--';
    }else{
      let costPerHourNum = convertCurrencyToNumber(this.costPerHourField?.value)
      let unitPrice = new Decimal(costPerHourNum)
      let minutes

      this.checkMinutesThreshold();

      if(this.hoursField?.value && this.minutesField?.value){
        minutes = (parseInt(this.hoursField.value) * 60) + parseInt(this.minutesField.value);
      }

      let unrounded = unitPrice.times(minutes).dividedBy(60)
      return unrounded.toFixed(2);
    }
  }

  calculateItemCost() {
    if(isNaN(this.itemsField?.value) || invalidCurrencyString(this.costPerItemField?.value)){
      return '--';
    }else{
      let costPerItemNum = convertCurrencyToNumber(this.costPerItemField?.value)
      let items = parseInt(this.itemsField?.value)
      let unitPrice = new Decimal(costPerItemNum)

      let unrounded = unitPrice.times(items);
      return unrounded.toFixed(2);
    }
  }

  checkMinutesThreshold() {
    if(this.minutesField){
      if(parseInt(this.minutesField.value) >= 60){
        this.minutesField.value = 59;
      }
    }
  }
}
