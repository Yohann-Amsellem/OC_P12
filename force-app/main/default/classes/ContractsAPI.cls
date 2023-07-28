@RestResource(urlMapping='/contracts/*')
global class ContractsAPI {
  @HttpPost
  global static void createContract(
    Date startDate,
    Integer contractTerm,
    String accountId
  ) {
    try {
      Contract newContract = new Contract();
      newContract.StartDate = startDate;
      newContract.ContractTerm = contractTerm;
      newContract.AccountId = accountId;
      newContract.Status = 'Draft'; // Set Status manually to 'Draft' to prevent Contract creation error

      insert newContract;

      // Save the Salesforce ID in the external system or database
      // For now, we are just printing it in the response

      RestContext.response.addHeader('Content-Type', 'text/plain');
      RestContext.response.responseBody = Blob.valueOf(newContract.Id);
      RestContext.response.statusCode = 201; // Set the status code to 201 for created
    } catch (Exception e) {
      // Set the response status code to 400 (Bad Request)
      RestContext.response.statusCode = 400;
      RestContext.response.addHeader('Content-Type', 'text/plain');
      RestContext.response.responseBody = Blob.valueOf(
        'Error creating contract: ' + e.getMessage()
      );
    }
  }

  @HttpPatch
  global static void updateContract(
    Id contractId,
    String fieldName,
    String fieldValue
  ) {
    try {
      Contract existingContract = [
        SELECT Id, Status, AccountId, SpecialTerms, Description
        FROM Contract
        WHERE Id = :contractId
        LIMIT 1
      ];

      if (existingContract != null) {
        // Update the specified field on the existing contact
        if (fieldName == 'Status') {
          existingContract.Status = fieldValue;
        }
        if (fieldName == 'AccountId') {
          existingContract.AccountId = fieldValue;
        }
        if (fieldName == 'SpecialTerms') {
          existingContract.SpecialTerms = fieldValue;
        }
        if (fieldName == 'Description') {
          existingContract.Description = fieldValue;
        }
        update existingContract;

        // Return a success confirmation as the response
        RestContext.response.addHeader('Content-Type', 'text/plain');
        RestContext.response.responseBody = Blob.valueOf(
          'The field has been updated successfully.'
        );
        RestContext.response.statusCode = 200; // Set the status code to 200 for success
      } else {
        // Throw an AuraHandledException if the contact is not found
        throw new AuraHandledException('Contract not found.');
      }
    } catch (Exception e) {
      // Set the response status code to 400 (Bad Request)
      RestContext.response.statusCode = 400;
      // Return the error message as the response body
      RestContext.response.addHeader('Content-Type', 'text/plain');
      RestContext.response.responseBody = Blob.valueOf(
        'Error updating contract: ' + e.getMessage()
      );
    }
  }
  @HttpGet
  global static Contract GetContractInfo() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String contractId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    Contract contract = [
      SELECT Id, StartDate, ContractTerm, AccountId, Status
      FROM Contract
      WHERE Id = :contractId
    ];
    return contract;
  }
}
