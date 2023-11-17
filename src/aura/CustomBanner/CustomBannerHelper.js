({
  closeBanner: function(cmp, cls) {
    if (!$A.util.hasClass(cmp, `${cls}--hidden`)) {
      $A.util.addClass(cmp, `${cls}--hidden`);
    }
  },
  getImageBaseUrl: function(image) {
    var baseImagePath = "/sfsites/c";
    const urlStart = image.url.split('/');
    if (urlStart[1] === 'cms') {
      baseImagePath = '/ashrc';
    }
    return baseImagePath;
  },
  getImage: function(record, helper) {
    var baseImagePath = "/sfsites/c";
    var imageSrc = '';
    var alt = '';
    if (record.contentNodes.CompactImage) {
      // baseImagePath = helper.getImageBaseUrl(record.contentNodes.CompactImage);
      imageSrc = record.contentNodes.CompactImage.url;
      alt = record.contentNodes.CompactImage.altText;
    }

    return {
      alt,
      src: `${baseImagePath}${imageSrc}`
    };
  },
  getRichText: function(field, record) {
    var textResult = record;
    var dom = document.createElement("div");
    const domain = window.location.hostname.replace(/\./g, '\\.');
    const regex = new RegExp(`(;a href=&quot;)(http|https)(:\/\/${domain}\\/[^]+?)(&quot; target=&quot;)(_blank)(&quot;)`, 'gm');

    if (field === "Rich Text Field 1") {
      if (textResult.contentNodes.CompactBody1) {
        dom.innerHTML = textResult.contentNodes.CompactBody1.value.replace(
          regex,
          '$1$2$3$4_self$6'
        );
        textResult.contentNodes.CompactBody1.value = dom.innerText;
        return textResult.contentNodes.CompactBody1.value;
      }
    } else if (field === "Rich Text Field 2") {
      if (textResult.contentNodes.CompactBody2) {
        dom.innerHTML = textResult.contentNodes.CompactBody2.value.replace(
          regex,
          '$1$2$3$4_self$6'
        );
        textResult.contentNodes.CompactBody2.value = dom.innerText;
        return textResult.contentNodes.CompactBody2.value;
      }
    }
    return "";
  },
  createCookie: function(slug) {
    var currentDate = new Date();
    var twentyMinutesLater = new Date(currentDate.getTime() + (20 * 60 * 1000));
    document.cookie = `${slug}=hide;expires=${twentyMinutesLater.toUTCString()};path=/`;
  },
  getCookie: function(slug) {
    var name = slug + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }
});