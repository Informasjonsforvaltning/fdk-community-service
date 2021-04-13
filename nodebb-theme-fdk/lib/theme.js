
"use strict";

var Theme = module.exports;

Theme.defineWidgetAreas = async function(areas) {
	return areas.concat([
		{
			'name': 'MOTD',
			'template': 'home.tpl',
			'location': 'motd'
		},
		{
			'name': 'Homepage Footer',
			'template': 'home.tpl',
			'location': 'footer'
		},
		{
			'name': 'Category Sidebar',
			'template': 'category.tpl',
			'location': 'sidebar'
		},
		{
			'name': 'Topic Footer',
			'template': 'topic.tpl',
			'location': 'footer'
		}
	]);
};
