@IsTest
private class SH_HandoffTests {
    private static User persona(String permissionName) {
        Profile p=[SELECT Id FROM Profile WHERE Name='Minimum Access - Salesforce' LIMIT 1];
        String suffix=permissionName+String.valueOf(DateTime.now().getTime())+UserInfo.getOrganizationId();
        User u=new User(Alias='shqa',Email='shqa@example.com',EmailEncodingKey='UTF-8',
            LastName='Synthetic Handoff Tester',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
            ProfileId=p.Id,TimeZoneSidKey='America/Toronto',Username=suffix+'@example.invalid');
        insert u;
        PermissionSet ps=[SELECT Id FROM PermissionSet WHERE Name=:permissionName LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=ps.Id);
        return u;
    }
    @IsTest static void salesPersonaCanReadButCannotEditRequest() {
        User seller=persona('SH_Sales');
        Id requestId;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Opportunity o=deal(true,true,true);insert o;
            requestId=[SELECT Id FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id].Id;
        }
        System.runAs(seller) {
            SH_Onboarding__c visible=[SELECT Id,Status__c FROM SH_Onboarding__c WHERE Id=:requestId WITH USER_MODE];
            System.assertEquals(false,SH_Onboarding__c.SObjectType.getDescribe().isUpdateable());
            visible.Status__c='Complete';
            Database.SaveResult result=Database.update(visible,false,AccessLevel.USER_MODE);
            System.assertEquals(false,result.isSuccess(),'Sales must not edit onboarding requests.');
        }
    }
    @IsTest static void coordinatorPersonaCanProgressOwnedRequest() {
        User coordinator=persona('SH_Coordinator');
        Id requestId;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Opportunity o=deal(true,true,true);o.SH_CSM__c=coordinator.Id;insert o;
            requestId=[SELECT Id FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id].Id;
        }
        System.runAs(coordinator) {
            SH_Onboarding__c visible=[SELECT Id,Status__c FROM SH_Onboarding__c WHERE Id=:requestId WITH USER_MODE];
            visible.Status__c='In Progress';
            Database.SaveResult result=Database.update(visible,false,AccessLevel.USER_MODE);
            System.assertEquals(true,result.isSuccess(),'Coordinator must be able to progress an owned request.');
            System.assertEquals(false,SH_Onboarding__c.SObjectType.getDescribe().isCreateable());
            System.assertEquals(false,SH_Onboarding__c.SObjectType.getDescribe().isDeletable());
        }
    }
    @IsTest static void coordinatorCanClaimQueuedRequest() {
        User coordinator=persona('SH_Coordinator');
        Group q=[SELECT Id FROM Group WHERE DeveloperName='SH_Onboarding_Triage' AND Type='Queue' LIMIT 1];
        insert new GroupMember(GroupId=q.Id,UserOrGroupId=coordinator.Id);
        Id requestId;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Opportunity o=deal(true,true,false);insert o;
            requestId=[SELECT Id FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id].Id;
        }
        System.runAs(coordinator) {
            SH_Onboarding__c claimed=new SH_Onboarding__c(Id=requestId,OwnerId=coordinator.Id,
                Needs_Triage__c=false,Status__c='In Progress');
            Database.SaveResult result=Database.update(claimed,false,AccessLevel.USER_MODE);
            System.assertEquals(true,result.isSuccess(),'Queue member must be able to claim and progress request: '+JSON.serialize(result.getErrors()));
        }
    }
    @IsTest static void failedRequestCreationRollsBackSource() {
        User inactive=persona('SH_Coordinator');inactive.IsActive=false;update inactive;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Opportunity o=deal(true,true,true);o.SH_CSM__c=inactive.Id;
            Test.startTest(); Database.SaveResult result=Database.insert(o,false); Test.stopTest();
            System.assertEquals(false,result.isSuccess(),'An inactive request owner must fail the handoff.');
            System.assertEquals(StatusCode.CANNOT_EXECUTE_FLOW_TRIGGER,result.getErrors()[0].getStatusCode());
            System.assertEquals(0,[SELECT count() FROM Opportunity WHERE Name='Synthetic Deal']);
            System.assertEquals(0,[SELECT count() FROM SH_Onboarding__c]);
        }
    }
    private static String wonStage() {
        return [SELECT MasterLabel FROM OpportunityStage WHERE IsWon=true AND IsActive=true LIMIT 1].MasterLabel;
    }
    private static String openStage() {
        return [SELECT MasterLabel FROM OpportunityStage WHERE IsClosed=false AND IsActive=true LIMIT 1].MasterLabel;
    }
    private static Opportunity deal(Boolean enabled, Boolean won, Boolean assigned) {
        Account a = new Account(Name='Synthetic Handoff Test');
        insert a;
        return new Opportunity(Name='Synthetic Deal', AccountId=a.Id, StageName=won ? wonStage() : openStage(),
            CloseDate=Date.today(), SH_Enabled__c=enabled, SH_Contact_Email__c='test@example.com',
            SH_Start_Date__c=Date.today().addDays(7), SH_Success_Criteria__c='Complete training',
            SH_CSM__c=assigned ? UserInfo.getUserId() : null);
    }
    @IsTest static void assignedHandoffCopiesBusinessData() {
        Opportunity o=deal(true,true,true);
        Test.startTest(); insert o; Test.stopTest();
        SH_Onboarding__c r=[SELECT OwnerId,Opportunity_Key__c,Contact_Email__c,Requested_Start__c,Success_Criteria__c,Status__c,Needs_Triage__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        System.assertEquals(UserInfo.getUserId(),r.OwnerId);
        System.assertEquals(String.valueOf(o.Id),r.Opportunity_Key__c);
        System.assertEquals(o.SH_Contact_Email__c,r.Contact_Email__c);
        System.assertEquals(o.SH_Start_Date__c,r.Requested_Start__c);
        System.assertEquals(o.SH_Success_Criteria__c,r.Success_Criteria__c);
        System.assertEquals('Ready',r.Status__c);
        System.assertEquals(false,r.Needs_Triage__c);
    }
    @IsTest static void unassignedHandoffRoutesToQueue() {
        Opportunity o=deal(true,true,false);
        Test.startTest(); insert o; Test.stopTest();
        SH_Onboarding__c r=[SELECT OwnerId,Status__c,Needs_Triage__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        Group q=[SELECT Id FROM Group WHERE DeveloperName='SH_Onboarding_Triage' AND Type='Queue' LIMIT 1];
        System.assertEquals(q.Id,r.OwnerId);
        System.assertEquals('Needs Triage',r.Status__c);
        System.assertEquals(true,r.Needs_Triage__c);
    }
    @IsTest static void repeatedEditsDoNotDuplicateOrOverwrite() {
        Opportunity o=deal(true,true,true); insert o;
        SH_Onboarding__c r=[SELECT Id,Status__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        r.Status__c='In Progress'; update r;
        Test.startTest();
        o.Description='Unrelated edit'; update o;
        o.SH_Success_Criteria__c='Changed after handoff'; update o;
        Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id]);
        r=[SELECT Status__c,Success_Criteria__c FROM SH_Onboarding__c WHERE Id=:r.Id];
        System.assertEquals('In Progress',r.Status__c);
        System.assertEquals('Complete training',r.Success_Criteria__c);
    }
    @IsTest static void reopenAndReclosePreservesRequest() {
        Opportunity o=deal(true,true,true); insert o;
        Id first=[SELECT Id FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id].Id;
        Test.startTest(); o.StageName=openStage(); update o; o.StageName=wonStage(); update o; Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id]);
        System.assertEquals(first,[SELECT Id FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id].Id);
    }
    @IsTest static void openDealWaitsUntilWon() {
        Opportunity o=deal(true,false,true); insert o;
        System.assertEquals(0,[SELECT count() FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id]);
        Test.startTest(); o.StageName=wonStage(); update o; Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id]);
    }
    @IsTest static void unselectedDealIsUnaffected() {
        Opportunity o=deal(false,true,true); o.SH_Contact_Email__c=null; o.SH_Start_Date__c=null; o.SH_Success_Criteria__c=null;
        Test.startTest(); insert o; Test.stopTest();
        System.assertEquals(0,[SELECT count() FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id]);
    }
    @IsTest static void missingDetailsBlockSave() {
        Opportunity template=deal(true,true,true);
        List<Opportunity> rows=new List<Opportunity>();
        for(Integer i=0;i<4;i++) {
            Opportunity o=template.clone(false,true,false,false);
            if(i==0) o.AccountId=null;
            if(i==1) o.SH_Contact_Email__c=null;
            if(i==2) o.SH_Start_Date__c=null;
            if(i==3) o.SH_Success_Criteria__c='   ';
            rows.add(o);
        }
        Test.startTest(); Database.SaveResult[] results=Database.insert(rows,false); Test.stopTest();
        for(Database.SaveResult result:results) {
            System.assertEquals(false,result.isSuccess());
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,result.getErrors()[0].getStatusCode());
        }
        System.assertEquals(0,[SELECT count() FROM SH_Onboarding__c]);
    }
    @IsTest static void sourceKeyCannotBeChanged() {
        Opportunity o=deal(true,true,true); insert o;
        SH_Onboarding__c r=[SELECT Id,Opportunity_Key__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        r.Opportunity_Key__c='006000000000000AAA';
        Test.startTest(); Database.SaveResult result=Database.update(r,false); Test.stopTest();
        System.assertEquals(false,result.isSuccess());
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,result.getErrors()[0].getStatusCode());
    }
    @IsTest static void duplicateKeyIsRejected() {
        Opportunity o=deal(true,true,true); insert o;
        SH_Onboarding__c duplicate=new SH_Onboarding__c(Opportunity__c=o.Id,Opportunity_Key__c=String.valueOf(o.Id));
        Test.startTest(); Database.SaveResult result=Database.insert(duplicate,false); Test.stopTest();
        System.assertEquals(false,result.isSuccess());
        System.assertEquals(StatusCode.DUPLICATE_VALUE,result.getErrors()[0].getStatusCode());
    }
    @IsTest static void triageCannotBeSkipped() {
        Opportunity o=deal(true,true,false); insert o;
        SH_Onboarding__c r=[SELECT Id,Status__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        r.Status__c='In Progress';
        Test.startTest(); Database.SaveResult result=Database.update(r,false); Test.stopTest();
        System.assertEquals(false,result.isSuccess());
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,result.getErrors()[0].getStatusCode());
    }
    @IsTest static void triageCanBeResolved() {
        Opportunity o=deal(true,true,false); insert o;
        SH_Onboarding__c r=[SELECT Id,Status__c,OwnerId,Needs_Triage__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        r.OwnerId=UserInfo.getUserId(); r.Needs_Triage__c=false; r.Status__c='In Progress';
        Test.startTest(); update r; Test.stopTest();
        System.assertEquals('In Progress',[SELECT Status__c FROM SH_Onboarding__c WHERE Id=:r.Id].Status__c);
    }
    @IsTest static void overdueExcludesCompletedRequests() {
        Opportunity o=deal(true,true,true); o.SH_Start_Date__c=Date.today().addDays(-1); insert o;
        SH_Onboarding__c r=[SELECT Id,Status__c,Overdue__c FROM SH_Onboarding__c WHERE Opportunity__c=:o.Id];
        System.assertEquals(true,r.Overdue__c);
        Test.startTest(); r.Status__c='Complete'; update r; Test.stopTest();
        System.assertEquals(false,[SELECT Overdue__c FROM SH_Onboarding__c WHERE Id=:r.Id].Overdue__c);
    }
    @IsTest static void bulkCloseCreatesOnePerOpportunity() {
        Opportunity template=deal(true,true,true);
        List<Opportunity> rows=new List<Opportunity>();
        for(Integer i=0;i<200;i++) { Opportunity o=template.clone(false,true,false,false); o.Name='Bulk '+i; rows.add(o); }
        Test.startTest(); insert rows; Test.stopTest();
        System.assertEquals(200,[SELECT count() FROM SH_Onboarding__c WHERE Opportunity__c IN :rows]);
    }
}
