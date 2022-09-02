describe('Datalandsbyen', function() {

  it('test if admin login succeeds', function() {
    cy.visit('http://localhost:4567/login');

    cy.elementExists("#username", () => {
      cy.typeAndRetry("#username", "admin").should('have.value', 'admin');
      cy.typeAndRetry('#password', 'MyPassword').should('have.value', 'MyPassword');    
      cy.get('#login').click();
    }, () => {
      cy.url().should('include', '/user/admin') 
    })
  });  
  
});
