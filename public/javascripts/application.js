function changeDate(e) {
  var theDate = this.up("td").id.split("_").last();
  new Ajax.Request("/session", {method: 'put', parameters: {"session[current_date]": theDate}});
  Event.stop(e);
}

function registerEventHandlers() {
  $$("#calendar a").each(function(anchor) {
    anchor.observe("click", changeDate.bindAsEventListener(anchor));
  });

  console.log("Registering event handlers for #flash");
  if ($("flash")) {
    console.log("flash: %o", $("flash"));
    new Effect.Highlight($("flash"));
  }
}

Event.observe(window, "load", function() {
  registerEventHandlers();
});
