({
  init: function (component) {
    const flowName = component.get("v.flowName");
    const showFlow = component.get("v.showFlow");
    const flow = component.find("flowData");
    const flowContainer = component.find("flowContainer");

    // In that component, start your flow. Reference the flow's API Name.
    if (flow) {
      flow.startFlow(flowName);
    }

    if (!showFlow && flowContainer) {
      $A.util.addClass(flowContainer, 'custom-flow__flow--hidden');
    }
  },
  handleClick: function(component) {
    const flowContainer = component.find("flowContainer");
    
    component.set("v.showFlow", true);
    if (flowContainer) {
      $A.util.removeClass(flowContainer, 'custom-flow__flow--hidden');
    }
  }
});