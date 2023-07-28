@RestResource(urlMapping='/contact/*')
global with sharing class ContactsAPI {
  @HttpPost
  global static void createContact(String email, String lastName) {
    try {
      // Check if a contact with the provided email exists
      List<Contact> existingContacts = [
        SELECT Id, Email, LastName
        FROM Contact
        WHERE Email = :email
        LIMIT 1
      ];

      if (!existingContacts.isEmpty()) {
        Contact existingContact = existingContacts[0];

        // Return the Salesforce ID as the response
        RestContext.response.addHeader('Content-Type', 'text/plain');
        RestContext.response.responseBody = Blob.valueOf(existingContact.Id);
        RestContext.response.statusCode = 200; // Set the status code to 200 for success
      } else {
        // The email does not exist, create a new contact in Salesforce
        Contact newContact = new Contact();
        newContact.Email = email;
        newContact.LastName = lastName; // Set the last name
        insert newContact;

        String salesforceContactId = newContact.Id;

        // Return the Salesforce ID as the response
        RestContext.response.addHeader('Content-Type', 'text/plain');
        RestContext.response.responseBody = Blob.valueOf(salesforceContactId);
        RestContext.response.statusCode = 201; // Set the status code to 201 for created
      }
    } catch (Exception e) {
      System.debug('Error message: ' + e.getMessage());
      // Set the response status code to 400 (Bad Request)
      RestContext.response.statusCode = 400;
      RestContext.response.addHeader('Content-Type', 'text/plain');
      RestContext.response.responseBody = Blob.valueOf(
        'Error creating contact: ' + e.getMessage()
      );
    }
  }

  @HttpPatch
  global static void updateContact(
    Id contactId,
    String fieldName,
    String fieldValue
  ) {
    try {
      Contact existingContact = [
        SELECT Id, Email
        FROM Contact
        WHERE Id = :contactId
        LIMIT 1
      ];

      if (existingContact != null) {
        // Update the specified field on the existing contact
        if (fieldName == 'Email') {
          existingContact.Email = fieldValue;
        }
        if (fieldName == 'LastName') {
          existingContact.LastName = fieldValue;
        }
        if (fieldName == 'FirstName') {
          existingContact.FirstName = fieldValue;
        }
        update existingContact;

        // Return a success confirmation as the response
        RestContext.response.addHeader('Content-Type', 'text/plain');
        RestContext.response.responseBody = Blob.valueOf(
          'The field has been updated successfully.'
        );
        RestContext.response.statusCode = 200; // Set the status code to 200 for success
      } else {
        // Throw an AuraHandledException if the contact is not found
        throw new AuraHandledException('Contact not found.');
      }
    } catch (Exception e) {
      // Set the response status code to 400 (Bad Request)
      RestContext.response.statusCode = 400;
      // Return the error message as the response body
      RestContext.response.addHeader('Content-Type', 'text/plain');
      RestContext.response.responseBody = Blob.valueOf(
        'Error updating contact: ' + e.getMessage()
      );
    }
  }

  @HttpGet
  global static Contact GetContactInfo() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String contactId = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    Contact contact = [
      SELECT Id, lastName, Email
      FROM Contact
      WHERE Id = :contactId
    ];
    return contact;
  }
}
