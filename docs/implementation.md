# Implementation, deployment, and release

## Data model

Opportunity → one SH_Onboarding__c per source opportunity. The lookup is required; Opportunity_Key__c is a required unique external-ID text field containing the 18-character opportunity ID. A validation rule keeps the key and source immutable. Opportunity deletion is restricted while a request refers to it.

Opportunity fields: SH_Enabled__c (checkbox; default false), SH_Contact_Email__c (email), SH_Start_Date__c (date), SH_Success_Criteria__c (255-character text), SH_CSM__c (User lookup).

Onboarding fields: Opportunity__c, Opportunity_Key__c, Contact_Email__c, Requested_Start__c, Success_Criteria__c, Status__c, Needs_Triage__c. Age_Days__c is calendar days since creation. Overdue__c is true when the requested start is before today and status is not Complete.

## Automation

SH_Create_Onboarding is an active after-save record-triggered Flow for Opportunity creates and updates where SH_Enabled__c and IsWon are true. It finds the source key, exits if a request exists, looks up the queue by developer name (no hardcoded org ID), and creates a request using the named CSM or queue. Standard elements allow Salesforce to bulkify operations; the 200-record test passed in the Developer Edition org.

Creation faults are not swallowed: Salesforce must fail the originating transaction. Support investigates the surfaced error and Flow details. There is no outbound email or external service. An invalid/inactive assigned owner is not silently replaced; fix the assignment and retry.

## Access model

SH_Sales grants edit/read access to the five Opportunity handoff fields and read access to the request object. Existing Opportunity object rights come from the user's base profile; the permission set does not grant broad new Opportunity privileges.

SH_Coordinator grants read access to the Opportunity handoff fields, read/edit access to requests, and edit access to operational request fields. Neither set grants delete, create, Modify All, or View All on requests. Flow creates requests in its record-triggered execution context. Permission sets are additive: use a minimally privileged test user rather than an administrator to verify restrictions.

Request object sharing is public read-only. Owners and appropriately configured queue members can work their records under normal Salesforce sharing rules. Add actual coordinator users to the triage queue through Setup; verify ownership transfer with the target profile. Broader coordinator edit sharing is intentionally not granted. This model is for synthetic demonstration data; production would require a separate privacy and sharing review.

## Deploy from project root

Use a dedicated Developer Edition practice org. Install the official Salesforce CLI if absent, then run:

```sh
sf org login web --alias handoff-portfolio
sf data query --target-org handoff-portfolio --query "SELECT OrganizationType, IsSandbox FROM Organization"
bash scripts/deploy.sh handoff-portfolio
sf apex run --target-org handoff-portfolio --file scripts/seed-demo.apex
```

Deploy only after OrganizationType confirms the intended practice environment. Keep dry-run/deploy/test evidence, excluding authentication data. Never include .sf, .sfdx, tokens, or user credentials in the submission. The seed script refuses to run if its tagged Account data already exists.

## UI setup and acceptance

1. Assign Handoff Sales and/or Handoff Coordinator only to intended practice users. An administrator already has broad privileges and is not a substitute for access UAT.
2. In Opportunity page layout, add a “Customer Success Handoff” section with the five SH_ fields. The portable deployment leaves standard layouts intact. The current practice org already has this section merged. Its exact layout snapshot is in org-setup/ for reference; do not overwrite another org's layout with that snapshot without reviewing differences.
3. Assign “Onboarding Request Layout” to the practice profiles if it is not automatically used. Confirm the Handoff Operations app and Onboarding Requests tab are visible.
4. Add the designated practice coordinator to the Onboarding Triage queue. Verify the user can claim a request and edit it.
5. Open the supplied report folder and run the status/aging reports. Verify counts against the seeded records and that the report folder is visible to the demonstration user.
6. Review the executed technical acceptance ledger in docs/uat.md. Repeat persona testing and business-user walkthroughs for any target deployment.

## Release gates

- Target practice-org identity checked.
- Metadata dry-run and actual deployment successful.
- All automated business-rule tests pass.
- Automated sales/coordinator user-mode access and queue-claim tests pass; independent business-user acceptance remains outside the portfolio scope.
- List/report counts match source records.
- Demo performed and screenshots captured.
- Limitations and authorship accurately stated.

## Rollback and recovery

For this first release, deactivate SH_Create_Onboarding in Setup → Flows to stop future automatic creation. Existing requests remain. If users must continue editing affected won opportunities while a fault is investigated, an administrator can temporarily deactivate SH_Require_Handoff_Details in the practice org and document that temporary exception. Reactivate it after recovery.

Do not delete the custom object as a rollback: that would remove evidence and request data. For a subsequent release, retrieve the current Flow and metadata before deploying; restore the previously verified version if regression occurs. No production rollback has been performed or claimed.

## Known limits

- Changes to source handoff fields after creation are not synchronized.
- Reopened or lost deals require manual review of their existing request.
- Past requested start dates are allowed and intentionally show as overdue.
- Queue membership and standard Opportunity layout are org-specific setup.
- No automatic SLA escalation, notifications, or external integration.
- Concurrent attempts rely on unique-key enforcement; a losing transaction may require retry.
- Business-rule tests and explicit user-mode access tests passed. Browser checks used an administrator; they do not replace non-admin UI acceptance or stakeholder sign-off.

## Verified release — 7 October 2026

Core configuration, active Flow, test class, reports and dashboard deployed successfully. Both permission sets were assigned to the practice administrator, the administrator was added to the triage queue, and the Opportunity layout was merged. Seeding succeeded once: four opportunities, three requests. Two reports return 3 total requests and 1 overdue request. See evidence/verification.md.

The deployment helper stages core metadata first, assigns field permissions to the deploying user, then deploys reports and dashboard. This lets reporting resolve the newly created custom fields. Dashboard running user defaults to the deploying user; configure explicitly before any broader use.
