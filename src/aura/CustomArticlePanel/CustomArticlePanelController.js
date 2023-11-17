({
  init: function (component, event, helper) {
		component.set('v.loading', true);
		helper.fetchArticles(component, helper);
	}
})