({
  init: function (component, event, helper) {
    helper.fetchFeaturedTopics(component)
    .then(function(topics) {
      if (topics) {
        const baseUrl = window.location.hostname === "www.ashresearchcollaborative.org" ?
        '/s' : '/ashrc/s';
        const mappedTopics = topics.map(function(topic) {
          return {
            Name: topic.Name,
            Url: `${baseUrl}/topic/${topic.Id}/${topic.Name.toLowerCase()}`
          }
        });
        component.set('v.topics', mappedTopics);
        component.set('v.topicsLength', mappedTopics.length);
      }
    }).catch(function(err) {
      console.log(err);
    });
	},
})