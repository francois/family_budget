$(function() {
  var insecureProcess = function(data) { eval(data); };

  $("#bank_transactions td.actions input[type=submit]").bind("click", function() {
    if (this.getAttribute("class").match(/process/)) {
      var bankTransactionId = this.id.replace("bank_transaction_", "").replace("_process", "");
      var accountId = $("#accounts input[checked]").val();
      jQuery.post("/transfers.js", {"transfer[bank_transaction_id]": bankTransactionId, "transfer[debit_account_id]": accountId}, insecureProcess);
    } else if (this.getAttribute("class").match(/cancel/)) {
      var bankTransactionId = this.id.replace("bank_transaction_", "").replace("_cancel", "");
      var transferId = $("#bank_transactions #bank_transaction_" + bankTransactionId + " input.transfer_id").val();
      jQuery.post("/transfers/" + transferId + ".js", {"_method": "delete"}, insecureProcess);
    } else {
      alert("Programming error:  don't know how to process '" + this.getAttribute("class") + "'");
    }
  });
});
