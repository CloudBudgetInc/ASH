({
  getImageBaseUrl: function(image) {
    var baseImagePath = "/sfsites/c";
    const urlStart = image.url.split('/');
    if (urlStart[1] === 'cms') {
      baseImagePath = '/ashrc';
    }
    return baseImagePath;
  },
  getImage: function(field, record, helper) {
    var baseImagePath = "/sfsites/c";
    var imageSrc = "";
    var alt = "";
    if (record.contentNodes.FullImage1) {
      // baseImagePath = helper.getImageBaseUrl(record.contentNodes.FullImage1);
      imageSrc = record.contentNodes.FullImage1.url;
      alt = record.contentNodes.FullImage1.altText;
    }
    if (field === "Image 2") {
      if (record.contentNodes.FullImage2) {
        // baseImagePath = helper.getImageBaseUrl(record.contentNodes.FullImage2);
        imageSrc = record.contentNodes.FullImage2.url;
        alt = record.contentNodes.FullImage2.altText;
      }
    } else if (field === "Image 3") {
      if (record.contentNodes.FullImage3) {
        // baseImagePath = helper.getImageBaseUrl(record.contentNodes.FullImage3);
        imageSrc = record.contentNodes.FullImage3.url;
        alt = record.contentNodes.FullImage3.altText;
      }
    } else if (field === "Image 4") {
      if (record.contentNodes.FullImage4) {
        // baseImagePath = helper.getImageBaseUrl(record.contentNodes.FullImage4);
        imageSrc = record.contentNodes.FullImage4.url;
        alt = record.contentNodes.FullImage4.altText;
      }
    } else if (field === "Image 5") {
      if (record.contentNodes.FullImage5) {
        // baseImagePath = helper.getImageBaseUrl(record.contentNodes.FullImage5);
        imageSrc = record.contentNodes.FullImage5.url;
        alt = record.contentNodes.FullImage5.altText;
      }
    }
    return {
      alt,
      src: `${baseImagePath}${imageSrc}`
    };
  },
  getRichText: function(field, record, dup) {
    var textResult = record;
    var dom = document.createElement("div");
    const domain = window.location.hostname.replace(/\./g, '\\.');
    const regex = new RegExp(`(;a href=&quot;)(http|https)(:\/\/${domain}\\/[^]+?)(&quot; target=&quot;)(_blank)(&quot;)`, 'gm');

    if (field === 'Headline') {
      if (textResult.contentNodes.Headline) {
        if (!dup) {
          dom.innerHTML = textResult.contentNodes.Headline.value;
          textResult.contentNodes.Headline.value = dom.innerText;
        }
        return textResult.contentNodes.Headline.value;
      }
    } else if (field === "Subheading") {
      if (textResult.contentNodes.Subheading) {
        if (!dup) {
          dom.innerHTML = textResult.contentNodes.Subheading.value.replace(
            regex,
            '$1$2$3$4_self$6'
          );
          textResult.contentNodes.Subheading.value = dom.innerText;
        }
        return textResult.contentNodes.Subheading.value;
      }
    } else if (field === "Rich Text Field 1") {
      if (textResult.contentNodes.FullBody1) {
        if (!dup) {
          dom.innerHTML = textResult.contentNodes.FullBody1.value.replace(
            regex,
            '$1$2$3$4_self$6'
          );
          textResult.contentNodes.FullBody1.value = dom.innerText;
        }
        return textResult.contentNodes.FullBody1.value;
      }
    } else if (field === "Rich Text Field 2") {
      if (textResult.contentNodes.FullBody2) {
        if (!dup) {
          dom.innerHTML = textResult.contentNodes.FullBody2.value.replace(
            regex,
            '$1$2$3$4_self$6'
          );
          textResult.contentNodes.FullBody2.value = dom.innerText;
        }
        return textResult.contentNodes.FullBody2.value;
      }
    } else if (field === "Rich Text Field 3") {
      if (textResult.contentNodes.FullBody3) {
        if (!dup) {
          dom.innerHTML = textResult.contentNodes.FullBody3.value.replace(
            regex,
            '$1$2$3$4_self$6'
          );
          textResult.contentNodes.FullBody3.value = dom.innerText;
        }
        return textResult.contentNodes.FullBody3.value;
      }
    } else if (field === "Rich Text Field 4") {
      if (textResult.contentNodes.FullBody4) {
        if (!dup) {
          dom.innerHTML = textResult.contentNodes.FullBody4.value.replace(
            regex,
            '$1$2$3$4_self$6'
          );
          textResult.contentNodes.FullBody4.value = dom.innerText;
        }
        return textResult.contentNodes.FullBody4.value;
      }
    }
    return "";
  }
});