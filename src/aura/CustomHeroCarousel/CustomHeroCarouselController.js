({
  init: function(component, event, helper) {
    helper
      .getRecords(component)
      .then(function(res) {})
      .catch(function(err) {});
  },
  handleNext: function(component, event, helper) {
    const panels = document.getElementById("carousel-panels");
    const panelSlides = document.getElementsByClassName("hero-carousel-panel");
    const length = panelSlides.length;
    if (panels) {
      const transform = panels.style.transform;
      if (transform) {
        const translateX = transform.split(/[()%]+/)[1];
        const index = (Math.abs(translateX / 100) + 1) % length;
        helper.updateIndicators(index + 1);
        const max = (length - 1) * -100;
        if (translateX === max.toString()) {
          panels.style.transform = "translateX(0%)";
        } else {
          panels.style.transform = `translateX(${Number(translateX) - 100}%)`;
        }
      }
    }
  },
  handlePrev: function(component, event, helper) {
    const panels = document.getElementById("carousel-panels");
    const panelSlides = document.getElementsByClassName("hero-carousel-panel");
    const length = panelSlides.length;
    if (panels) {
      const transform = panels.style.transform;
      if (transform) {
        const translateX = transform.split(/[()%]+/)[1];
        var index = Math.abs(translateX / 100) - 1;
        if (index === -1) {
          index = length - 1;
        }
        helper.updateIndicators(index + 1);
        const max = (length - 1) * -100;
        if (translateX === "0") {
          panels.style.transform = `translateX(${max}%)`;
        } else {
          panels.style.transform = `translateX(${Number(translateX) + 100}%)`;
        }
      }
    }
  },
  handleIndicatorPress: function(component, event, helper) {
    const id = event.target.id.replace(/[^0-9]/g, "");
    const panels = document.getElementById("carousel-panels");
    helper.updateIndicators(id);
    const translateX = (Number(id) - 1) * -100;
    panels.style.transform = `translateX(${translateX}%)`;
  }
});