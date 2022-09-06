import { recurse } from 'cypress-recurse'

Cypress.Commands.add('typeAndRetry', (textField, text) => {
  recurse(
    () => cy.get(textField).clear().type(text),
    ($ssnField) => $ssnField.val() == text,
  ).should('have.value', text)
})


Cypress.Commands.add('elementExists', (selector, callbackSuccess, callbackFail) => {
  cy.get('body').then(($body) => {
    const el = $body.find(selector);
    if (el.length) {
      callbackSuccess(el)
    } else {
      callbackFail()
    }
  })
})
