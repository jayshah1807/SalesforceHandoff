# Test plan and execution ledger

Executed 7 October 2026 in Developer Edition. SH_HandoffTests: 17 methods passed, zero failures. T14–T16 use automated tests; access checks explicitly perform user-mode operations with minimum-access test users and the relevant permission set. This is technical acceptance evidence, not independent stakeholder sign-off. See evidence/apex-test-results.json.

| ID | Test | Steps | Expected | Status |
|---|---|---|---|---|
| T01 | assignedHandoffCopiesBusinessData | Insert opted-in won deal with CSM | One Ready request, correct owner and copied fields | PASS — automated |
| T02 | unassignedHandoffRoutesToQueue | Insert opted-in won deal without CSM | One Needs Triage request owned by the configured queue | PASS — automated |
| T03 | repeatedEditsDoNotDuplicateOrOverwrite | Progress request; edit source twice | Same one request; status and snapshot preserved | PASS — automated |
| T04 | reopenAndReclosePreservesRequest | Reopen and reclose source opportunity | Same request ID; count remains one | PASS — automated |
| T05 | openDealWaitsUntilWon | Save open opted-in deal, then mark won | Zero before win; one after win | PASS — automated |
| T06 | unselectedDealIsUnaffected | Save unselected won deal with no handoff details | Save succeeds; zero requests | PASS — automated |
| T07 | missingDetailsBlockSave | Omit each of Account/email/date/criteria | Each save fails validation; no request | PASS — automated |
| T08 | sourceKeyCannotBeChanged | Attempt to edit source key | Validation blocks change | PASS — automated |
| T09 | duplicateKeyIsRejected | Insert a second request with same key | Duplicate-value error; original remains | PASS — automated |
| T10 | triageCannotBeSkipped | Progress queue-owned flagged request | Validation blocks change | PASS — automated |
| T11 | triageCanBeResolved | Assign user, clear flag, progress | Update succeeds | PASS — automated |
| T12 | overdueExcludesCompletedRequests | Past requested start; then complete request | Overdue true before completion, false after | PASS — automated |
| T13 | bulkCloseCreatesOnePerOpportunity | Insert 200 eligible deals in one transaction | 200 requests without limit failure | PASS — automated |
| T14 | salesPersonaCanReadButCannotEditRequest | Non-admin sales user-mode query and update | Read succeeds; edit denied | PASS — automated user mode |
| T15 | coordinatorPersonaCanProgressOwnedRequest; coordinatorCanClaimQueuedRequest | Non-admin user-mode claim and update; create/delete attempts | Claim/progress succeeds; create/delete denied | PASS — automated user mode |
| T16 | failedRequestCreationRollsBackSource | Inactive CSM causes controlled Flow creation failure in test transaction | Source save fails; no source or request persists | PASS — automated rollback |
| T17 | Administrator UI smoke check | Inspect request list, triage detail and dashboard; execute reports via API | Three requests, one triage and one overdue | PASS — admin UI + API |

Evidence: `evidence/apex-test-results.json`, `evidence/live-data-check.json`, and `evidence/screenshots/`. Automated tests run in isolated test transactions. T15 contains two test methods, so the ledger has 17 scenarios and the class has 17 methods. No browser session as a non-admin persona or independent stakeholder usability study was conducted; these remain production acceptance activities. The fault test verifies rollback, not an operational recovery drill.
