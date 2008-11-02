Feature: Import transactions
  In order to keep track of my expenses
  A person
  Should be able to import several transactions from a file

  Scenario: Import a Quicken file with a single account and a single transaction
    Given I am authenticated
    And I am on the new import page
    And I select "Quicken" from "Format"
    And I attach the file at "features/imports/single_txn.qfx" to "Data"
    And I press "Import"
    Then under "Name" I should see "MISC PAYMENTS"
    And under "Memo" I should see "PAYPAL PTE LTD"
    And under "Amount" I should see "-14.24"
    And under "Status" I should see "Unassigned"

  Scenario: Import a file with an unknown account
  Scenario: Import an invalid file
  Scenario: Import an empty file
