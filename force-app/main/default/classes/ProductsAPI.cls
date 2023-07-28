@RestResource(urlMapping='/products/*')
global with sharing class ProductsAPI {
    
    @HttpGet
    global static Product2 GetProductInfo() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String productId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Product2 product = [SELECT Id,isActive,Description,Name  FROM Product2 WHERE Id = :productId ];
        return product;
    }
}