({
    getDataObjectA: function(component, page) {
        component.set("v.spinner", true);
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectTypeB");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldNameB"); 

        var action = component.get("c.fetchData");
        console.log('parentRecordId' + parentRecordId); 
        action.setParams({
            infoJSON : JSON.stringify({
                        "pageNumber": page,
                        "recordToDisplay": recordToDisplay,
                        "objectType" : objectType, 
                        "parentRecordId": parentRecordId, 
                        "parentField": parentField, 
                        "recordId": null
            })
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result 1' + JSON.stringify(result));   
                
                console.log('entrou no A'); 
                
                console.log('result.total' + result.total);  
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisplay));
                for (let i = 0; i <= result.data.length; i++) { 
                    console.log('result data' + i);  
                    console.log('result.data[i].Id' + result.data[i].Id); 
                    console.log('result.page' + result.page);  
                    this.getDataObjectC(component,  component.get("v.page"), result.data[i].Id, result.data, result.page, result.total);  
                } 
                component.set("v.spinner", false);
            } else if (state === "ERROR") {
                console.log('response.getError()' + JSON.stringify(response.getError())); 
                this.handleResponseError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },



    getDataObjectC: function(component, page, recordIdB, resultData, resultPage, resultTotal) { 
        console.log('recordIdB' + recordIdB); 
       component.set("v.spinner", true);
        var recordToDisplay = component.get("v.tableSize"); 
        
        var objectType = component.get("v.objectTypeC");
        var parentRecordId = recordIdB;  
        var parentField = component.get("v.parentFieldNameC");
        
        console.log('entrou no B');
        var action = component.get("c.fetchData");
        action.setParams({
            infoJSON : JSON.stringify({
                        "pageNumber": page,
                        "recordToDisplay": recordToDisplay, 
                        "objectType" : objectType, 
                        "parentRecordId": recordIdB,    
                        "parentField": parentField, 
                        "recordId": parentRecordId 
            })
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result 2' + JSON.stringify(result));  
                    for(var i=0 ; i <= result.data.length; i++){
                        if(result.data[i] != null){
                            resultData.push(result.data[i]);
                        } 
                    } 
                var pageTotal = parseInt(result.page) + parseInt(page); 
                component.set("v.data", resultData);     
                component.set("v.page", result.page);   
                component.set("v.total", pageTotal);  
                console.log('pageTotal' + pageTotal); 
                console.log('recordToDisplay' + recordToDisplay); 
                component.set("v.pages", pageTotal);   
                component.set("v.spinner", false); 
            } else if (state === "ERROR") { 
                this.handleResponseError(response.getError());
            }
        });
        $A.enqueueAction(action); 
    }, 

    sortData: function (component, fieldName, sortDirection) {
        component.set("v.spinner", true);
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
        component.set("v.spinner", false);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    showToast : function(component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Related List Message',
            message: message,
            duration:' 3000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },

    handleResponseError: function (helper, errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showToast(component, 'error', "Error message: " +
                    errors[0].message);
            }
        } else {
            this.showToast(component, 'error', 'Unknown error.');
        }
        component.set("v.spinner", false);
    }
})