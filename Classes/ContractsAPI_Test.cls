@isTest
public class ContractAPI_Test {
@IsTest
    static void testCreateContract() {
        // Prepare the request body with startDate,contractTerm and accountId parameters
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('startDate', '2023-09-12');
        requestBody.put('contractTerm', '5'); 
        requestBody.put('accountId', '00109000026rH7zAAE'); 
        
        // Send the request
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/contracts/';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response = new RestResponse(); // Initialize the RestResponse object
        
        // Call the API
        ContractsAPI.createContract(date.ValueOf('2023-08-08'),5,'00109000026rH7zAAE');
        
        // Verify the response
        System.assertEquals(201, RestContext.response.statusCode);
        
        // Get the response body and verify it contains a Salesforce ID
        String responseString = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseString, 'Response body should not be null');
        System.assertNotEquals('', responseString.trim(), 'Response body should not be empty');
               
        Test.stopTest();
    }

  @isTest
static void testUpdateContract() {
    // Create a test contact
    Contract testContract = new Contract(Status = 'Draft', startDate = date.ValueOf('2023-08-08'), contractTerm = 3,accountId='00109000026rH7zAAE');
    insert testContract;
    
    // Create a test HTTP request
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/contacts/' + testContract.Id;
    request.httpMethod = 'PATCH';
    
    // Set the request body
    String fieldName = 'Description';
    String fieldValue = 'this is a test description.';
    String requestBody = fieldName + '=' + fieldValue;
    request.requestBody = Blob.valueOf(requestBody);
    
    // Send the request
    RestContext.request = request;
    RestContext.response = new RestResponse();
    
    // Call the ContactModificationAPI
    Test.startTest();
    ContractsAPI.updateContract(testContract.Id, fieldName, fieldValue);
    Test.stopTest();
    
    // Verify the response
    RestResponse response = RestContext.response;
    System.assertNotEquals(null, response, 'Response should not be null');
    System.assertEquals(200, response.statusCode, 'Unexpected status code');
    System.assertEquals('The field has been updated successfully.', response.responseBody.toString(), 'Unexpected response body');
    
    // Verify the contact was updated
    Contract updatedContract = [SELECT Id,Description FROM Contract WHERE Id = :testContract.Id];
    System.assertEquals(fieldValue, updatedContract.Description, 'Contract\'s description is not updated');
}
/*    
    @isTest
static void testUpdateContractFailed() {
    // Create a test contact
    Contract testContract = new Contract(Status = 'Draft', startDate = date.ValueOf('2023-08-08'), contractTerm = 3 ,accountId='00109000026rH7zAAE');
    insert testContract;
    
    // Create a test HTTP request
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/contacts/' + testContract.Id+105;
    request.httpMethod = 'PATCH';
    
    // Set the request body
    String fieldName = 'Description';
    String fieldValue = 'this is a test description.';
    String requestBody = fieldName + '=' + fieldValue;
    request.requestBody = Blob.valueOf(requestBody);
    
    // Send the request
    RestContext.request = request;
    RestContext.response = new RestResponse();
    
    // Call the ContactModificationAPI
    Test.startTest();
    ContractsAPI.updateContract(testContract.Id, fieldName, fieldValue);
    Test.stopTest();
    
    // Verify the response
    RestResponse response = RestContext.response;
    System.assertNotEquals(null, response, 'Response should not be null');
    System.assertEquals(400, response.statusCode, 'Unexpected status code');
    System.assertNotEquals('The field has been updated successfully.', response.responseBody.toString(), 'Unexpected response body');
    
    // Verify the contact was updated
    Contract updatedContract = [SELECT Id,Description FROM Contract WHERE Id = :testContract.Id];
    System.assertNotEquals(fieldValue, updatedContract.Description, 'Contract\'s description is not updated');
}
*/ 
     @isTest
     static void testGetContractInfo(){
        Contract contractTest = new Contract(startDate =date.ValueOf('2023-08-08') ,contractTerm = 3, accountId='00109000026rH7zAAE' );
        insert contractTest;
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/Contracts/' + contractTest.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        Contract result = ContractsAPI.GetContractInfo();
        System.assert(result != null);
        System.assertEquals(date.ValueOf('2023-08-08'), result.startDate);
        System.assertEquals(3, result.contractTerm); 
        System.assertEquals('00109000026rH7zAAE', result.accountId);
    }   
}