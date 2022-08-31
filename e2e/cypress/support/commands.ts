import { recurse } from 'cypress-recurse'

Cypress.Commands.add('typeAndRetry', (textField, text) => {
  recurse(
    () => cy.get(textField).clear().type(text),
    ($ssnField) => $ssnField.val() == text,
  ).should('have.value', text)
})
