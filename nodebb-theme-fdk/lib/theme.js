
"use strict";
import { registerHelper } from 'benchpressjs';

export async function defineWidgetAreas(areas) {
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
}

registerHelper('resolvePathIconSrc', (route) => {
	var routeName = route.match(/;.*/)[0].substring(1);
	if (["categories", "groups", "popular", "recent", "tags", "users"].includes(routeName)) {
		return `/plugins/nodebb-theme-fdk/images/icon-community-${routeName}-md.svg`;
	}
	return '';
});
