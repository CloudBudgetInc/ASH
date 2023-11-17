({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const introField = component.get("v.introField");
    const tile1ImageField = component.get("v.tile1ImageField");
    const tile2ImageField = component.get("v.tile2ImageField");
    const tile3ImageField = component.get("v.tile3ImageField");
    const tile1Field = component.get("v.tile1Field");
    const tile2Field = component.get("v.tile2Field");
    const tile3Field = component.get("v.tile3Field");

    contentAction.setStorable();
    contentAction.setParam("language", "en_US");
    contentAction.setParam("contentType", "full");
    contentAction.setCallback(this, function(action) {
      const state = action.getState();
      if (state === "SUCCESS") {
        const [record] = action.getReturnValue().filter(function(content) {
          return content.contentUrlName === contentSlug;
        });
        if (record) {
          component.set("v.record", record);
          component.set(
            "v.intro",
            helper.getRichText(introField, record)
          );
          component.set("v.tile1Image", helper.getImage(tile1ImageField, record, helper));
          component.set("v.tile2Image", helper.getImage(tile2ImageField, record, helper));
          component.set("v.tile3Image", helper.getImage(tile3ImageField, record, helper));
          component.set(
            "v.tile1",
            helper.getRichText(tile1Field, record, false)
          );
          const tile2Dup = tile2Field === tile1Field;
          component.set(
            "v.tile2",
            helper.getRichText(tile2Field, record, tile2Dup)
          );
          const tile3Dup =
            tile3Field === tile1Field ||
            tile3Field === tile2Field;
          component.set(
            "v.tile3",
            helper.getRichText(tile3Field, record, tile3Dup)
          );
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
});