
/*
	Hey there!
	This is the client file for your theme. If you need to do any client-side work in javascript,
	this is where it needs to go.
	You can listen for page changes by writing something like this:
	  $(window).on('action:ajaxify.end', function(data) {
		var	url = data.url;
		console.log('I am now at: ' + url);
	  });
*/

$(document).ready(function() {
	$('body').on( "DOMNodeInserted", function( e ) {
		let bc = $('main > div > ol.breadcrumb')[0];
		if(bc) {
			$('div.fdk-breadcrumbs-container').empty();
			$('div.fdk-breadcrumbs-container')[0].appendChild(bc);
		}
	});
});
