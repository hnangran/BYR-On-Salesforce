({
  doInit : function(component) {
    const pr = component.get("v.pageReference") || {};
    const s  = pr.state || {};
    const recordId = s.recordId || s.id || null; // some entry points use 'id'


    component.find("nav").navigate({
      type: "standard__navItemPage",
      attributes: { apiName: "Create_Resume" }, // <-- your existing tab's API name
      state: {
        c__mode: recordId ? 'edit' : 'new',
        c__recordId: recordId || null,
        c__recordTypeId: s.recordTypeId || s.c__recordTypeId || null,
        c__retURL: s.retURL || s.c__retURL || null,
        c__inContextOfRef: s.inContextOfRef || s.c__inContextOfRef || null
      }
    }, true);
  }
})