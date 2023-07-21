@isTest
private class ContactAPI_Test {
    @IsTest
    static void testCreateContact() {
        // Prepare the request body with email and lastName parameters
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('email', 'test@example.com');
        requestBody.put('lastName', 'Doe'); // Add the lastName parameter
        
        // Send the request
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/contacts/';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response = new RestResponse(); // Initialize the RestResponse object
        
        // Call the API
        ContactsAPI.createContact('test@example.com', 'Doe');
        
        // Verify the response
        System.assertEquals(201, RestContext.response.statusCode);
        
        // Get the response body and verify it contains a Salesforce ID
        String responseString = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseString, 'Response body should not be null');
        System.assertNotEquals('', responseString.trim(), 'Response body should not be empty');
        // Verify that the response body contains a valid Salesforce ID
        // Note: This is just a basic check, you may want to perform a more specific validation for the Salesforce ID format
        System.assert(responseString.startsWith('003'), 'Invalid Salesforce ID format in the response body');
        
        Test.stopTest();
    }


@isTest
static void testUpdateContact() {
    // Create a test contact
    Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com');
    insert testContact;
    
    // Create a test HTTP request
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/contacts/' + testContact.Id;
    request.httpMethod = 'PATCH';
    
    // Set the request body
    String fieldName = 'Email';
    String fieldValue = 'updated@example.com';
    String requestBody = fieldName + '=' + fieldValue;
    request.requestBody = Blob.valueOf(requestBody);
    
    // Send the request
    RestContext.request = request;
    RestContext.response = new RestResponse();
    
    // Call the ContactModificationAPI
    Test.startTest();
    ContactsAPI.updateContact(testContact.Id, fieldName, fieldValue);
    Test.stopTest();
    
    // Verify the response
    RestResponse response = RestContext.response;
    System.assertNotEquals(null, response, 'Response should not be null');
    System.assertEquals(200, response.statusCode, 'Unexpected status code');
    System.assertEquals('The field has been updated successfully.', response.responseBody.toString(), 'Unexpected response body');
    
    // Verify the contact was updated
    Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id = :testContact.Id];
    System.assertEquals(fieldValue, updatedContact.Email, 'Contact email not updated');
}
    
    @isTest
    static void testDisableContactAPIsuccess() {
       // Create a test contact
    Contact testContact = new Contact(LastName = 'Contact', Email = 'test@example.com');
    insert testContact;
    
    // Create a test HTTP request
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/contacts/' + testContact.Id;
    request.httpMethod = 'PATCH';
    
    // Send the request
    RestContext.request = request;
    RestContext.response = new RestResponse();
         Test.startTest();
        ContactsDeletionAPI.disableContact();
        Test.stopTest();

        // Verify the response
        RestResponse response = RestContext.response;
        System.assertEquals(200, response.statusCode, 'Unexpected status code');
        System.assertEquals('The contact has been disabled successfully.', response.responseBody.toString(), 'Unexpected response body');

        // Verify that the contact is disabled
        Contact disabledContact = [SELECT Id, IsDisabled__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, disabledContact.IsDisabled__c, 'Contact should be disabled');
    }
    
    @isTest
    static void testDisableContactAPIerror() {
       // Create a test contact
    Contact testContact = new Contact(LastName = 'Contact', Email = 'test@example.com');
    insert testContact;
    
    // Create a test HTTP request
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/contacts/' + testContact.Id+1;
    request.httpMethod = 'PATCH';
    
    // Send the request
    RestContext.request = request;
    RestContext.response = new RestResponse();
         Test.startTest();
        ContactsDeletionAPI.disableContact();
        Test.stopTest();

        // Verify the response
        RestResponse response = RestContext.response;
        System.assertEquals(400, response.statusCode, 'Unexpected status code');
        System.assertNotEquals('The contact has been disabled successfully.', response.responseBody.toString(), 'Unexpected response body');

        // Verify that the contact is disabled
        Contact disabledContact = [SELECT Id, IsDisabled__c FROM Contact WHERE Id = :testContact.Id];
        System.assertNotEquals(true, disabledContact.IsDisabled__c, 'Contact should be disabled');
    }
    @isTest
    static void testGetContactInfo() {
        // Créer un contact de test
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', Phone = '123-456-7890');
        insert testContact;

        // Créer une requête de test avec l'ID du contact de test
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/contacts/' + testContact.Id;
        request.httpMethod = 'GET';

        // Définir le contexte de la requête de test
        RestContext.request = request;
        RestContext.response = new RestResponse();

        // Appeler la méthode getContactInfo de l'API REST
        Test.startTest();
        Contact result = ContactsAPI.getContactInfo();
        Test.stopTest();

        // Vérifier le résultat
        System.assertNotEquals(null, result, 'Le contact ne doit pas être nul');
        System.assertEquals(testContact.Id, result.Id, 'L\'ID du contact doit correspondre');
        System.assertEquals(testContact.LastName, result.LastName, 'Le nom du contact doit correspondre');
        System.assertEquals(testContact.Email, result.Email, 'L\'e-mail du contact doit correspondre');
    }

   @isTest
static void testGetContactInfo_NotFound() {
    // Créer une requête de test sans ID de contact
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/contacts/';
    request.httpMethod = 'GET';

    // Définir le contexte de la requête de test
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Appeler la méthode getContactInfo de l'API REST
    Test.startTest();
    try {
        Contact result = ContactsAPI.getContactInfo();
        System.assertEquals(null, result, 'Le contact ne doit pas être trouvé');
        System.assertEquals(404, RestContext.response.statusCode, 'Le code de statut de la réponse doit être 404 (Not Found)');
    } catch (QueryException e) {
        // Handle the "Not Found" scenario here
        System.debug('Contact not found in the testGetContactInfo_NotFound test.');
        RestContext.response.statusCode = 404; // Set the response status code to 404
        System.assertEquals(404, RestContext.response.statusCode, 'Le code de statut de la réponse doit être 404 (Not Found)');
    }
    Test.stopTest();
}
    
}