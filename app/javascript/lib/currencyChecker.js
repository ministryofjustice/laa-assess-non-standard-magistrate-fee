function convertCurrencyToNumber(string){
  return string.replace(/[^0-9.-]+/g,"")
}

function checkLetters(string){
  /[a-zA-Z]/g.test(string)
}

function checkCurrencyString(string){
  var currencyString = convertCurrencyToNumber(string)
  console.log(string)
  console.log(currencyString)
  console.log(isNan(currencyString))
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

export {checkCurrencyString, convertCurrencyToNumber}
