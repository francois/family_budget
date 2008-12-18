$(document).ready(function() {
  var insecureProcess = function(data) { eval(data); };
  var handleTransfer = function(e, ui) {
    // this == droppable, ui.draggable == draggable
    var sourceBankTransactionId = $(ui.draggable).attr("id").replace("bank_transaction_", "");
    var targetBankTransactionId = $(this).attr("id").replace("bank_transaction_", "");
    jQuery.post("/transfers.js", {"transfer[bank_transaction_id][]": [sourceBankTransactionId, targetBankTransactionId]}, insecureProcess);
  };

  $("#bank_transactions tr.bank_transaction").draggable({revert: true, helper: 'clone', opacity: 0.7, scroll: true, handle: ".handle"});
  $("#bank_transactions tr.bank_transaction").droppable({accept: "#bank_transactions .handle", drop: handleTransfer});

  $("#bank_transactions td.actions input[type=submit]").bind("click", function() {
    if (this.getAttribute("class").match(/process/)) {
      if ($("input.regroup[checked]").length > 0) {
        var ids = [];
        $("input.regroup[checked]").each(function(index, elem) {
          ids.push(elem.getAttribute("id").replace("regroup_bank_transaction_", ""));
        });
        jQuery.post("/transfers.js", {"transfer[bank_transaction_id][]": ids}, insecureProcess);
      } else {
        var bankTransactionId = this.id.replace("bank_transaction_", "").replace("_process", "");
        var accountId = $("#accounts input[checked]").val();
        jQuery.post("/transfers.js", {"transfer[bank_transaction_id]": bankTransactionId, "transfer[debit_account_id]": accountId}, insecureProcess);
      }
    } else if (this.getAttribute("class").match(/cancel/)) {
      var bankTransactionId = this.id.replace("bank_transaction_", "").replace("_cancel", "");
      var transferId = $("#bank_transactions #bank_transaction_" + bankTransactionId + " input.transfer_id").val();
      jQuery.post("/transfers/" + transferId + ".js", {"_method": "delete"}, insecureProcess);
    } else {
      alert("Programming error:  don't know how to process '" + this.getAttribute("class") + "'");
    }
  });

  $("#clear_groupings").click(function() {
    $("input.regroup").attr("checked", false);
    return false;
  });

  // Split amounts page (splits/:id/edit)
  (function() {
    
    function getOriginalAmount() {
      return parseFloat($("#splits #original-amount").html());
    }

    function getTotal() {
      var total = 0.0;
      $("#splits input.amount").each(function() {
        if ($(this).val() != "") {
          total += parseFloat($(this).val());
        }
      });

      return total;
    }

    function getBalanceAmount() {
      return Math.abs(getOriginalAmount()) - Math.abs(getTotal());
    }

    function updateBalanceFields() {
      $("#splits #split-amount").html(getTotal().toString());
      $("#splits #balance-amount").html(getBalanceAmount().toString());
    }

    $("#splits .destroy").bind("click", function() {
      $(this).parents("tr").remove();
      updateBalanceFields();
      return false;
    });

    $("#splits #add-another").bind("click", function() {
      var clones = $("#splits #template").clone(true);
      clones.insertBefore("#splits tbody tr#add-line");
      clones.removeAttr("id");

      clones.find("input.amount").val(getBalanceAmount().toString());
      updateBalanceFields();
      return false;
    });

    $("#splits input.amount").bind("change", function() {
      updateBalanceFields();
    });
  })();
});
