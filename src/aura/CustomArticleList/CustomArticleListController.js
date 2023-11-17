({
	init: function (component, event, helper) {
		helper.fetchArticles(component, helper);
	},
	handleViewMore: function(component, event, helper) {
		const articles = component.get('v.articles');
		const currentPage = component.get('v.currentPage');
		const pageSize = component.get('v.limit');
		const nextPage = currentPage + 1;
		component.set('v.currentPage', nextPage);
		const limit = pageSize * nextPage;
		const filtered = articles
			.sort(function(u1, u2) {
				return helper.sortByField(u1, u2, 'Date', 'DESC', helper);
				// return helper.sortByField(u1, u2, sortBy, sortDir, helper);
			})
			.slice(0, limit);
		component.set('v.filteredArticles', filtered);
		if (limit >= articles.length) {
			helper.hideButton(component);
		}
	}
})