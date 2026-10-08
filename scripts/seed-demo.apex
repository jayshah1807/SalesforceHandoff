// Synthetic records only; repeat execution exits before creating duplicate demo data.
String marker = 'PORTFOLIO-SH-DEMO';
System.assertEquals(0, [SELECT count() FROM Account WHERE Name IN ('Northstar Demo Systems','Harbour Demo Analytics','Maple Demo Manufacturing','Cedar Demo Logistics')], 'Demo data already exists. Do not rerun seed.');
String won = [SELECT MasterLabel FROM OpportunityStage WHERE IsWon = true AND IsActive = true LIMIT 1].MasterLabel;
String openStage = [SELECT MasterLabel FROM OpportunityStage WHERE IsClosed = false AND IsActive = true LIMIT 1].MasterLabel;
List<Account> accounts = new List<Account>();
for (String n : new List<String>{'Northstar Demo Systems','Harbour Demo Analytics','Maple Demo Manufacturing','Cedar Demo Logistics'}) accounts.add(new Account(Name=n, Description=marker));
insert accounts;
List<Opportunity> deals = new List<Opportunity>();
for (Integer i=0; i<4; i++) deals.add(new Opportunity(Name='DEMO - '+accounts[i].Name,AccountId=accounts[i].Id,StageName=i==3 ? openStage : won,CloseDate=Date.today(),Amount=10000*(i+1),SH_Enabled__c=true,SH_Contact_Email__c='onboarding'+i+'@example.com',SH_Start_Date__c=Date.today().addDays(i==2 ? -2 : 7+i),SH_Success_Criteria__c='Agree onboarding milestones and complete administrator training.',SH_CSM__c=i==1 ? null : UserInfo.getUserId()));
insert deals;
List<SH_Onboarding__c> requests = [SELECT Id, Status__c, Opportunity__c FROM SH_Onboarding__c WHERE Opportunity__c IN :deals];
for(SH_Onboarding__c r : requests) if(r.Opportunity__c==deals[0].Id) r.Status__c='In Progress';
update requests;
System.assertEquals(3,requests.size(),'Expected three requests and one open opportunity without a request.');
System.debug('DEMO_SEED_OK: 4 accounts, 4 opportunities, 3 onboarding requests.');
