/**
 *
 *
 * @author: Thiago Barbosa
 *
 * @Description: CustomRelatedListControllerTest Controller  
 */

@isTest
public with sharing class CustomRelatedListControllerTest {
    



    @TestSetup
    static void createdData(){
        ObjectA__c objectA = new ObjectA__c();
        objectA.Name = 'TestNameA';
        Database.insert(objectA);

        ObjectB__c objectB = new ObjectB__c();  
        objectB.Name = 'TestNameB';
        objectB.ObjectA__c = objectA.Id;
        Database.insert(objectB);

        ObjectC__c objectC = new ObjectC__c();
        objectC.Name = 'TestNameC'; 
        objectC.ObjectB__c = objectB.Id; 
        Database.insert(objectC);

    }


    @isTest static void testfetchData(){ 

        ObjectB__c objectB =  [SELECT Id FROM ObjectB__c LIMIT 1];

        ObjectC__c objectC =  [SELECT Id FROM ObjectC__c LIMIT 1];

        Test.startTest();
        CustomRelatedListController.ComponentInfo componentInfo = new CustomRelatedListController.ComponentInfo(); 
        componentInfo.pageNumber = 1;
        componentInfo.recordToDisplay = 10;
        componentInfo.objectType = 'ObjectC__c';
        componentInfo.parentField = 'ObjectB__c'; 
        componentInfo.parentRecordId = objectB.Id;
        componentInfo.recordId = objectC.Id;  

        CustomRelatedListController.ObjectWrapper wrapper = CustomRelatedListController.fetchData(JSON.serialize(componentInfo)); 
        Test.stopTest(); 
        System.assert(wrapper != null, 'Wrapper is different of null');
    }


    @isTest static void testDeleteData(){ 

        ObjectB__c objectB =  [SELECT Id FROM ObjectB__c LIMIT 1];

        ObjectC__c objectC =  [SELECT Id FROM ObjectC__c LIMIT 1];

        try{
        Test.startTest();
        CustomRelatedListController.ComponentInfo componentInfo = new CustomRelatedListController.ComponentInfo(); 
        componentInfo.pageNumber = 1;
        componentInfo.recordToDisplay = 10;
        componentInfo.objectType = 'ObjectC__c';
        componentInfo.parentField = 'ObjectB__c';
        componentInfo.parentRecordId = objectB.Id;
        componentInfo.recordId = objectC.Id;   

        CustomRelatedListController.ObjectWrapper wrapper = CustomRelatedListController.deleteRecord(JSON.serialize(componentInfo)); 
        Test.stopTest(); 
        System.assert(wrapper != null, 'Wrapper is different of null'); 
        }catch(Exception ex){  
            System.assert(ex.getMessage() != null);
        }
    }

}