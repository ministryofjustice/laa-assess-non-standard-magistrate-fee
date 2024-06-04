function convertCurrencyToNumber(string){
  return string.replace(/[^0-9.-]+/g,"")
}

function checkLetters(string){
  return /[a-zA-Z]/g.test(string)
}

function invalidCurrencyString(string){
  var currencyString = convertCurrencyToNumber(string)
  console.log(string)
  console.log(currencyString)
  console.log(isNaN(currencyString))
  console.log(checkLetters(string))
  if(isNaN(currencyString) || checkLetters(string)){
    console.log('returning true')
    return true
  }
  else{
    console.log('returning false')
    return false
  }
}

export {invalidCurrencyString, convertCurrencyToNumber}
