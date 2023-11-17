({
  updateIndicators: function(currentIndex) {
    const indicators = document.getElementsByClassName(
      "news-carousel__indicator slds-carousel__indicator-action"
    );
    Array.prototype.forEach.call(indicators, function(indicator, index) {
      if (indicator.id) {
        if (indicator.id === `news-indicator-id-${currentIndex}`) {
          indicator.classList.add("slds-is-active");
        } else {
          indicator.classList.remove("slds-is-active");
        }
      }
    });
  },
  getRecords: function(component) {
    const contentAction = component.get("c.getMContent");
    contentAction.setStorable();
    const maxItems = component.get("v.maxItems");
    return new Promise(function(resolve, reject) {
      contentAction.setParam("language", "en_US");
      contentAction.setParam("contentType", "News_Headlines");
      contentAction.setCallback(this, function(action) {
        const state = action.getState();
        if (state === "SUCCESS") {
          var records = [];
          if (maxItems && Number(maxItems) > 0) {
            records = action.getReturnValue().slice(0, Number(maxItems));
          } else {
            records = action.getReturnValue();
					}
          if (records) {
            const mapped = records.map(function(record) {
              var url1Target = '_blank';
              var url2Target = '_blank';
              if (record.contentNodes && record.contentNodes.URL1 && record.contentNodes.URL1.value) {
                if (record.contentNodes.URL1.value.startsWith('/') ||
                  record.contentNodes.URL1.value.includes('ashresearchcollaborative.org')) {
                  url1Target = '_self';
                }
              }

              if (record.contentNodes && record.contentNodes.URL2 && record.contentNodes.URL2.value) {
                if (record.contentNodes.URL2.value.startsWith('/') ||
                  record.contentNodes.URL2.value.includes('ashresearchcollaborative.org')) {
                  url2Target = '_self';
                }
              }

              return {
                contentNodes: {
                  url1Target,
                  url2Target,
                  Button1: record.contentNodes && record.contentNodes.Button1 ? record.contentNodes.Button1 : undefined,
                  Button2: record.contentNodes && record.contentNodes.Button2 ? record.contentNodes.Button2 : undefined,
                  DescTXT: record.contentNodes && record.contentNodes.DescTXT ? record.contentNodes.DescTXT : undefined,
                  Headline: record.contentNodes && record.contentNodes.Headline ? record.contentNodes.Headline : undefined,
                  Flag: record.contentNodes && record.contentNodes.Flag ? record.contentNodes.Flag : undefined,
                  IMG: record.contentNodes && record.contentNodes.IMG ? record.contentNodes.IMG : undefined,
                  Name: record.contentNodes && record.contentNodes.Name ? record.contentNodes.Name : undefined,
                  URL1: record.contentNodes && record.contentNodes.URL1 ? record.contentNodes.URL1 : undefined,
                  URL2: record.contentNodes && record.contentNodes.URL2 ? record.contentNodes.URL2 : undefined,
                },
                contentUrlName: record.contentUrlName,
                language: record.language,
                managedContentId: record.managedContentId,
                publishedDate: record.publishedDate,
                title: record.title,
                type: record.type,
                typeLabel: record.typeLabel
              }
            });
            component.set("v.records", mapped);
            resolve(records);
          }
        } else {
          console.log("Error occurred");
          reject(action.getError()[0]);
        }
      });
      $A.enqueueAction(contentAction);
    });
  }
});