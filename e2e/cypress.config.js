const { defineConfig } = require('cypress')

module.exports = defineConfig({
  projectId: 'hv9u5g',
  viewportWidth: 1200,
  viewportHeight: 800,
  chromeWebSecurity: false,
  fixturesFolder: 'cypress/e2e/fixtures',
  e2e: {
    setupNodeEvents(on, config) {},
    baseUrl: 'http://localhost:4567',
    specPattern: 'cypress/e2e/specs/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support'
  },  
})
