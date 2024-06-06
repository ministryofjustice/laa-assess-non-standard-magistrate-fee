function convertCurrencyToNumber(string){
  return string.replace(/[^0-9.-]+/g,"")
}

function checkLetters(string){
  return /[a-zA-Z]/g.test(string)
}

function invalidCurrencyString(string){
  var currencyString = convertCurrencyToNumber(string)
  if(isNaN(currencyString) || checkLetters(string)){
    return true
  }
  else{
    return false
  }
}

export {invalidCurrencyString, convertCurrencyToNumber}
