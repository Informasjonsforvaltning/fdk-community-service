describe('Datalandsbyen', function() {

    it('test if all categories are listed', function() {
      cy.visit('http://localhost:4567');
      
      cy.get('ul.categories').children().should('have.length', 4);
      cy.get('ul.categories li:first').should('to.contain', 'Announcements')
      cy.get('ul.categories li:nth-child(2)').should('to.contain', 'General Discussion')
      cy.get('ul.categories li:nth-child(3)').should('to.contain', 'Comments & Feedback')
      cy.get('ul.categories li:nth-child(4)').should('to.contain', 'Blogs')
    });  

    
});
