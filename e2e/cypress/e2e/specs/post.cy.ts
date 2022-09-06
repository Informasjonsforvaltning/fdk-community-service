describe('Datalandsbyen', function() {

    it('test if new post does not show add link popup', function() {
      cy.visit('http://localhost:4567/login');

      cy.elementExists("#username", () => {
        cy.intercept('/login').as('login')
        cy.typeAndRetry("#username", "admin").should('have.value', 'admin');
        cy.typeAndRetry('#password', 'MyPassword').should('have.value', 'MyPassword');    
        cy.get('#login').click();
        cy.wait('@login')
      }, () => {
        cy.url().should('include', '/user/admin') 
      })

      cy.visit('http://localhost:4567/category/2/general-discussion');

      cy.get('#new_topic').click();
      cy.wait(1000)
      cy.elementExists("#plugin-fdk-resource-link-editor", ($modal: any) => {
        const display = $modal.css("display");
        if(display === 'none') {
          assert.isOk('OK', 'Modal is hidden')          
        } else {
          assert.isNotOk('Not OK', 'Modal is not hidden')        
        }
      }, () => {
        assert.isNotOk('Not OK', 'Could not find fdk resource link modal')        
      });  

      cy.get('li[data-format="plugin-fdk-resource-link"]').click();
      cy.elementExists("#plugin-fdk-resource-link-editor", ($modal: any) => {
        const display = $modal.css("display");
        if(display === 'block') {
          assert.isOk('OK', 'Modal is visible')          
        } else {
          assert.isNotOk('Not OK', 'Modal is not visible')        
        }
      }, () => {
        assert.isNotOk('Not OK', 'Could not find fdk resource link modal')        
      });
    });
    
});
