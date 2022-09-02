import { recurse } from 'cypress-recurse'

Cypress.Commands.add('typeAndRetry', (textField, text) => {
  recurse(
    () => cy.get(textField).clear().type(text),
    ($ssnField) => $ssnField.val() == text,
  ).should('have.value', text)
})


Cypress.Commands.add('elementExists', (selector, callbackSuccess, callbackFail) => {
  cy.get('body').then(($body) => {
    if ($body.find(selector).length) {
      callbackSuccess()
    } else {
      callbackFail()
    }
  })
})
