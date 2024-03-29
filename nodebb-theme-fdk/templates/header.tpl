<!DOCTYPE html>
<html lang="{function.localeToHTML, userLang, defaultLang}" <!-- IF languageDirection -->data-dir="{languageDirection}" style="direction: {languageDirection};" <!-- ENDIF languageDirection --> >
<head>
	<title>{browserTitle}</title>
	{{{each metaTags}}}{function.buildMetaTag}{{{end}}}
	<link rel="stylesheet" type="text/css" href="{relative_path}/assets/client<!-- IF bootswatchSkin -->-{bootswatchSkin}<!-- END -->.css?{config.cache-buster}" />
	{{{each linkTags}}}{function.buildLinkTag}{{{end}}}

	<script async src=https://siteimproveanalytics.com/js/siteanalyze_6255470.js></script>
	<script type="text/javascript"> 
		window._monsido = window._monsido || { 
			token: "0Z9PGVSqxJ97MyDeYg5hVQ", 
			statistics: { 
				enabled: true, 
				cookieLessTracking: false, 
				documentTracking: { 
					enabled: false, 
					documentCls: "monsido_download", 
					documentIgnoreCls: "monsido_ignore_download", 
					documentExt: ["pdf","doc","ppt","docx","pptx"], 
				}, 
			}, 
			heatmap: { 
				enabled: false, 
			},
		}; 
	</script> 
	<script type="text/javascript" async src="https://app-script.monsido.com/v2/monsido-script.js"></script>
	<script>
		var config = JSON.parse('{{configJSON}}');
		var app = {
			user: JSON.parse('{{userJSON}}')
		};
	</script>

	<!-- IF useCustomHTML -->
	{{customHTML}}
	<!-- END -->
	<!-- IF useCustomCSS -->
	<style>{{customCSS}}</style>
	<!-- END -->

	<!--[if IE]><link rel="shortcut icon" href="/assets/uploads/system/favicon.ico"><![endif]-->
    <link rel="icon" type="image/png" href="/assets/uploads/system/favicon.ico">
</head>

<body class="{bodyClass} skin-<!-- IF bootswatchSkin -->{bootswatchSkin}<!-- ELSE -->noskin<!-- END -->">
  <nav id="menu" class="slideout-menu hidden">
		<!-- IMPORT partials/slideout-menu.tpl -->
	</nav>
	<nav id="chats-menu" class="slideout-menu hidden">
		<!-- IMPORT partials/chats-menu.tpl -->
	</nav>

	<main id="panel" class="slideout-panel">
		<!-- IMPORT fdk-header.tpl -->
		<!-- IMPORT fdk-breadcrumbs.tpl -->
		<nav class="navbar navbar-default header container" id="header-menu" component="navbar">
			<div class="container">
				<!-- IMPORT partials/menu.tpl -->
			</div>
		</nav>
    <div class="fdk-splash container" id="fdk-splash">
      <img src="/assets/plugins/nodebb-theme-fdk/images/illustration-community.svg" alt="Community illustrasjon" />
      <div class="fdk-welcome">
        <h1>[[fdk:welcome.header]]</h1>
        <h4>[[fdk:welcome.ingress]]</h4>
        <p>[[fdk:welcome.paragraph]]</p>
      </div>
    </div>
		<div class="container" id="content">
		<!-- IMPORT partials/noscript/warning.tpl -->
		<!-- IMPORT partials/noscript/message.tpl -->
