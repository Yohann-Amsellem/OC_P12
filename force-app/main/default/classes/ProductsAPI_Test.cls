@isTest
public class ProductsAPI_Test {

     @isTest
     static void testGetProductInfo(){
        Product2 prod = new Product2(Name = 'Test Product API',Description='Lorem ipsum ...');
        insert prod;
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/Products/' + prod.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        Product2 result = ProductsAPI.GetProductInfo();
        System.assert(result != null);
        System.assertEquals('Test Product API', result.Name);
        System.assertEquals('Lorem ipsum ...', result.Description); 
    }   
}