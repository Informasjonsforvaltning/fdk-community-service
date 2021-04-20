$(document).ready(function () {

	$('main').on("DOMNodeInserted", function (e) {
		if (window.location.pathname !== '/') {
			let bc = $('main > div > ol.breadcrumb')[0];
			if (bc) {
				$('div.fdk-breadcrumbs-container').empty();
				$('div.fdk-breadcrumbs-container')[0].appendChild(bc);
				$('div.fdk-breadcrumbs').show();
			}
		} else {
			$('div.fdk-breadcrumbs').hide();
		}
	});

	function toggleSplash(path) {
		if (path === "/") {
			document.getElementById("fdk-splash").style.display = "inherit";
		} else {
			document.getElementById("fdk-splash").style.display = "none";
		}
	}

	window.addEventListener('popstate', function () {toggleSplash(location.pathname)});

	(function (history) {
		var pushState = history.pushState;
		history.pushState = function (data, title, url) {
			toggleSplash(url)
			return pushState.apply(history, [data, title, url]);
		};

		toggleSplash(location.pathname)
	})(window.history);

	function getEnvironment() {
		const host = window.location.hostname.split(".")

		if (host.includes("staging") || host.includes("localhost")) {
			return "staging";
		} else if (host.includes("demo")) {
			return "demo";
		}
		return "prod";
	}

	function setHomeLink() {
		const environment = getEnvironment();
		var href = "";
		switch (environment) {
			case "demo":
				href = "https://demo.fellesdatakatalog.digdir.no/";
				break;
			case "prod":
				href = "https://data.norge.no/";
				break;
			case "staging":
			default:
				href = "https://www.staging.fellesdatakatalog.digdir.no/";
				break;
		}
		document.getElementById("fdk-logo-link").href = href;
	}


	setHomeLink();
});

