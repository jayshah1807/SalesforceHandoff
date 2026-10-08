# Simulated support incidents

These are training scenarios, not incidents observed in a real company. Root causes below are proposed causes to reproduce and verify; they are not claimed as diagnosed production events.

## INC-001 — Won deal has no onboarding request

Impact: one seller's handoff is delayed. Initial priority: normal; raise priority if many users are affected or a time-critical customer start is blocked.

Investigation: confirm the opportunity save succeeded; inspect IsWon and Enable Handoff; search SH_Onboarding__c by Opportunity_Key__c; check active Flow and error details; compare with a successful record. Likely scenario cause: the explicit opt-in was not selected.

Resolution rehearsal: fill required fields and select Enable Handoff on the won test opportunity; save; verify exactly one request with matching data. Repeat an unrelated edit and verify no duplicate. Add the opt-in step to training if it caused confusion.

## INC-002 — Coordinator cannot see or edit a request

Impact: one user cannot begin onboarding. Check whether this affects one record or all records before assigning priority.

Investigation: an administrator verifies the record exists; affected user checks list-view filters; inspect assigned permission sets, object rights, field-level security, ownership, queue membership, and sharing. Do not use “works as admin” as acceptance evidence.

Resolution rehearsal: grant only the intended practice permission set or add the intended coordinator to the practice triage queue; retest as that user; claim the record; edit Status. Confirm a sales-only test user still cannot edit request operational fields. Record the specific missing permission rather than claiming a generic “permissions issue.”

## INC-003 — Reclosing a deal appears not to create a new request

Impact: user expects a second handoff. Search by source key and inspect the original request. Expected behavior is one request per opportunity even after reopening. This is initially a user inquiry, not a confirmed defect.

Resolution rehearsal: demonstrate the existing record and unchanged progress. If the business requires multiple onboarding cycles, capture an enhancement for a cycle identifier and uniqueness per opportunity-plus-cycle; estimate data migration and reporting impacts. Do not remove the unique-key constraint as a quick fix.

## Incident versus request versus enhancement

A failed expected behavior is an incident. Adding a permitted coordinator is a service request. Multiple onboarding cycles is an enhancement. Prioritize by business impact and urgency rather than the requester's job title alone.

## Knowledge article: a missing handoff

Check opt-in → won stage → successful save → source-key record search → list filters/access → Flow status/error. If a record exists, investigate visibility before creating any replacement. Attach reproduction steps, actual result, expected result, timestamp, and sanitized record references. Escalate with the Flow version and error details when necessary.
