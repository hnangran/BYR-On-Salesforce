({
  doInit : function(component) {
    const vRid = component.get("v.recordId");
    const pr = component.get("v.pageReference") || {};
    const s  = pr.state || {};

    // Fallbacks in case an entry point passes Id differently
    const rid  = vRid || s.recordId || s.id || null;
    const mode = rid ? 'edit' : 'new';

    component.find("nav").navigate({
      type: "standard__navItemPage",
      attributes: { apiName: "Create_Resume" },  // your existing tab API name
      state: {
        // Use c__-prefix when navigating to a nav item
        c__mode: mode,
        c__recordId: rid,
        c__recordTypeId: s.recordTypeId || null,
        c__retURL: s.retURL || null,
        c__inContextOfRef: s.inContextOfRef || null
      }
    }, true);
  }
})