({
  fetchFeaturedTopics: function(component) {
    const articleAction = component.get("c.getFeaturedTopics");

    articleAction.setStorable();
		return new Promise(function(resolve, reject) {
			articleAction.setCallback(this, function (action) {
				const state = action.getState();
				if (state === "SUCCESS") {
					resolve(action.getReturnValue());
				} else {
					console.log("Error occurred");
					reject(action.getError()[0]);
				}
			});
			$A.enqueueAction(articleAction);
		});
  }
})