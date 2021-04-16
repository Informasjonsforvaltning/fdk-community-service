$(document).ready(function() {

	$('main').on( "DOMNodeInserted", function( e ) {
		if(window.location.pathname !== '/') {
			let bc = $('main > div > ol.breadcrumb')[0];
			if(bc) {
				$('div.fdk-breadcrumbs-container').empty();
				$('div.fdk-breadcrumbs-container')[0].appendChild(bc);
				$('div.fdk-breadcrumbs').show();
			}
		} else {
			$('div.fdk-breadcrumbs').hide();
		}
	});

	(function(history){
    var pushState = history.pushState;
    history.pushState = function(state) {
			if (arguments[0].url === "") {
				document.getElementById("fdk-splash").style.display = "";
			} else {
				document.getElementById("fdk-splash").style.display = "none";
			}
      return pushState.apply(history, arguments);
    };
})(window.history);
});

