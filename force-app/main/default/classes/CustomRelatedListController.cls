/**
 *
 *
 * @author: Thiago Barbosa
 *
 * @Description: CustomRelatedList Controller
 */
public with sharing class CustomRelatedListController{
    @AuraEnabled
    public static ObjectWrapper fetchData(String infoJSON){
        try{
            ComponentInfo info = (ComponentInfo)JSON.deserialize(infoJSON, ComponentInfo.class);

            if (String.isNotEmpty(info.objectType)){
                String countQuery = getCountQueryString(info);
                String queryObjects = getObjectQueryString(info);
                
                System.debug('Database.countQuery(countQuery)' + Database.countQuery(countQuery)); 
                System.debug('Database.query(queryObjects)' + Database.query(queryObjects));  
                return new ObjectWrapper(info.recordToDisplay, info.pageNumber, Database.countQuery(countQuery), Database.query(queryObjects));
            } else{
                return new ObjectWrapper(); 
            }
        } catch (Exception ex){ 
            throw new AuraHandledException('Error Message' + ex.getMessage()); 
        }
    }

    private static String getCountQueryString(ComponentInfo info){
        String objectType = String.escapeSingleQuotes(info.objectType);
        String parentField = info.parentField;
        Id parentRecordId = info.parentRecordId;

        String countQuery = 'SELECT count() FROM ';
        countQuery += objectType;

        System.debug('parentRecordId 1' + parentRecordId);

        if (String.isNotEmpty(parentField) && parentRecordId != null){
            parentField = String.escapeSingleQuotes(parentField);
            countQuery += ' WHERE ' + parentField + '= \'' + String.escapeSingleQuotes(parentRecordId) + '\''; 
        }
        System.debug('countQuery' + countQuery);
        return countQuery;
    }

    private static String getObjectQueryString(ComponentInfo info){
        String objectType = String.escapeSingleQuotes(info.objectType);
        String parentField = info.parentField;
        Id parentRecordId = info.parentRecordId;

        String queryObjects = 'SELECT Id, Name, CreatedDate, LastModifiedDate FROM '; 
        queryObjects += objectType;

        if (String.isNotEmpty(parentField) && parentRecordId != null){
            System.debug('parentRecordId 2' + parentRecordId);
            parentField = String.escapeSingleQuotes(parentField);  
            queryObjects += ' WHERE ' + parentField + '= \'' + String.escapeSingleQuotes(parentRecordId) + '\''; 
        } else{
            queryObjects += ' ORDER BY Name ASC LIMIT ' + info.recordToDisplay + ' OFFSET ' + (info.pageNumber - 1) * info.recordToDisplay;
        }

        System.debug('queryObjects' + queryObjects);
        return queryObjects;
    }

    @AuraEnabled
    public static ObjectWrapper deleteRecord(String infoJSON){
        ComponentInfo info = (ComponentInfo)JSON.deserialize(infoJSON, ComponentInfo.class);
        UserRecordAccess recAccess = [SELECT HasEditAccess, HasDeleteAccess, RecordId
                                      FROM UserRecordAccess
                                      WHERE UserId = :UserInfo.getUserId() AND RecordId = :info.recordId];

        if (recAccess != null && recAccess.HasDeleteAccess){
            try{
                sObject sObj = Schema.getGlobalDescribe().get(info.objectType).newSObject();
                sObj.Id = info.recordId;
                delete sObj;
            } catch (DmlException e){
                throw new AuraHandledException('Error while deleting data.');
            }
        }

        return fetchData(infoJSON);
    }

    public class ObjectWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer page{ get; set; }

        @AuraEnabled
        public Integer total{ get; set; }

        @AuraEnabled
        public List<sObject> data{ get; set; }

        ObjectWrapper(Integer pageSize, Integer page, Integer total, List<sObject> data){
            this.pageSize = pageSize;
            this.page = page;
            this.total = total;
            this.data = data;
        }

        ObjectWrapper(){
        }

    }

    public class ComponentInfo{
        public Integer pageNumber;
        public Integer recordToDisplay;
        public String objectType;
        public String parentField;
        public Id parentRecordId;
        public Id recordId; 

    }

}