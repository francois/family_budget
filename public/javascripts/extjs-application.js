Ext.onReady(function() {
    // Save ExtJS state in cookie for 30 days
    Ext.state.Manager.setProvider(
      new Ext.state.CookieProvider({
          path: '/app',
          secure: true,
          expires: new Date(new Date().getTime()+(1000*60*60*24*30))}));

    // Enable use of quick tips
    Ext.QuickTips.init();

    var dashboardPanel = {
      title: 'Graphiques',
      closable: false,
      items: [{html: '<p>Graphiques</p>'}]};

    var budgetPanel = {
      title: 'Budget',
      closable: false,
      items: {html: '<p>Budget</p>'}};

    // The main panel, where everything is
    var mainPanel = new Ext.TabPanel({
        id: 'main-panel',
        renderTo: Ext.getBody(),
        minTabWidth: 115,
        tabWidth:135,
        enableTabScroll:true,
        autoHeight: true,
        defaults: {autoScroll:true},
        plugins: new Ext.ux.TabCloseMenu(),
        activeTab: 0, // Ensure dashboard is selected on initial render
        items: [
          dashboardPanel, budgetPanel]
      });
  });
