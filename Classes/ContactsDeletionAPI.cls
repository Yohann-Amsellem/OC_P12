@RestResource(urlMapping='/contacts/deletion/')

global class ContactsDeletionAPI {
    @HttpPatch
    global static void disableContact() {
        try {
            String contactId = RestContext.request.requestURI.substringAfterLast('/');

            // Check if the contact exists in Salesforce
            Contact existingContact = [SELECT Id, IsDisabled__c FROM Contact WHERE Id = :contactId LIMIT 1];

            if (existingContact != null) {
                // Set the custom field IsDisabled__c to true to disable the contact
                existingContact.IsDisabled__c = true;

                // Update the contact to disable it
                update existingContact;

                // Return a success confirmation as the response
                RestContext.response.addHeader('Content-Type', 'text/plain');
                RestContext.response.responseBody = Blob.valueOf('The contact has been disabled successfully.');
                RestContext.response.statusCode = 200; // Set the status code to 200 for success
            } else {
                // The contact with the specified ID does not exist
                throw new AuraHandledException('Contact not found.');
            }
        } catch (Exception e) {
            // Set the response status code to 400 (Bad Request)
            RestContext.response.statusCode = 400;
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf('Error disabling contact: ' + e.getMessage());
        }
    }
}