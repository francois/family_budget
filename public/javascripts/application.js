function changeDate(e) {
  var theDate = this.up("td").id.split("_").last();
  new Ajax.Request("/session", {method: 'put', parameters: {"session[current_date]": theDate}});
  Event.stop(e);
}

function registerEventHandlers() {
  $$("#calendar a").each(function(anchor) {
    anchor.observe("click", changeDate.bindAsEventListener(anchor));
  });

  if ($("flash")) {
    new Effect.Highlight($("flash"));
  }
}

Event.observe(window, "load", function() {
  registerEventHandlers();
});
