describe('Datalandsbyen', function() {

    it('test if all categories are listed', function() {
      cy.visit('http://localhost:4567/calendar');
      
      cy.get('.fc-day-header').children().should('have.length', 7);
      cy.get('.fc-day-header.fc-mon').should('to.contain', 'Mon');
      cy.get('.fc-day-header.fc-tue:nth-child(2)').should('to.contain', 'Tue');
      cy.get('.fc-day-header.fc-wed:nth-child(3)').should('to.contain', 'Wed');
      cy.get('.fc-day-header.fc-thu:nth-child(4)').should('to.contain', 'Thu');
      cy.get('.fc-day-header.fc-fri:nth-child(5)').should('to.contain', 'Fri');
      cy.get('.fc-day-header.fc-sat:nth-child(6)').should('to.contain', 'Sat');
      cy.get('.fc-day-header.fc-sun:nth-child(7)').should('to.contain', 'Sun');
    });  

    it('test if week view display correct dates', function() {
      cy.visit('http://localhost:4567/calendar');
      
      cy.get('.fc-agendaWeek-button').click();

      const d = new Date()  // current date
      
      
      var dateString = () => d.getDate()  + "/" + (d.getMonth()+1) ;
      var dayString = () => {
        switch(d.getDay()) {
          case 0: return "Sun";
          case 1: return "Mon";
          case 2: return "Tue";
          case 3: return "Wed";
          case 4: return "Thu";
          case 5: return "Fri";
          case 6: return "Sat";
          default: return null
        }
      }

      cy.get('.fc-day-header.fc-today').should('to.contain', dayString() + ' ' + dateString());
    });
    
});
