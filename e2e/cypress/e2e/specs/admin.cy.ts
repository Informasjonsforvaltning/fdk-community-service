describe('Datalandsbyen', function() {

    it('test if admin can login', {
        retries: {
          runMode: 2,
          openMode: 1,
        },
      }, function() {
        cy.visit('http://localhost:4567/login');
        cy.typeAndRetry("#username", "admin").should('have.value', 'admin');
        cy.typeAndRetry('#password', 'MyPassword').should('have.value', 'MyPassword');    
        cy.get('#login').click();
    });

});
