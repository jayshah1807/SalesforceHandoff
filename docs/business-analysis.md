# Business analysis and delivery brief

## Problem and objective

At a fictional B2B software company, sales hands won deals to Customer Success using email and a shared spreadsheet. Handoffs can lack a start date, contact, success criteria, or a named owner. The proposed solution creates one traceable onboarding request from a selected won opportunity and routes unassigned work to triage.

This problem statement and the following stakeholder positions are simulation assumptions, not interview findings. The project does not claim access to Kinaxis processes.

## Stakeholder needs

| Persona | Need | Question to validate in a real workshop |
|---|---|---|
| Sales representative | Close a deal without a separate handoff form | Which fields are already captured during the sale? |
| Customer Success coordinator | Receive complete, owned requests | Which missing information prevents work from starting? |
| Sales Operations manager | See backlog and aging | Does “late” mean past requested start or a contractual SLA? |
| Salesforce administrator | Predictable configuration and recoverable failures | Which existing flows, validation rules, and access policies apply? |
| IT business partner | Controlled delivery and user adoption | Who accepts the release and owns support? |

## Scope

In scope: explicitly selected opportunities; handoff data validation; request creation; owner/queue routing; duplicate prevention; list views and reporting; business-rule tests; support and release procedures.

Out of scope: contracts, billing, email delivery, ERP integration, live customer data, AI scoring, automatic SLA escalation, automatic cancellation after reopening, and production rollout. In a real engagement, the business owner must approve retention, access, and lifecycle decisions.

## Current and future process

Current (assumed): deal closes → seller writes email → coordinator checks spreadsheet → missing details are requested → owner is chosen → onboarding is tracked manually.

Future: seller opts in and fills handoff details → won opportunity save is validated → existing request is checked → one request is created → named CSM owns it, or triage queue receives it → coordinator resolves triage and progresses work → manager reviews aging and overdue work.

## Requirements and traceability

| ID | Requirement / acceptance criterion | Implementation | Verification |
|---|---|---|---|
| R01 | Only opted-in won opportunities create a request | Flow entry conditions | T01, T05, T06 |
| R02 | Account, email, start date and nonblank success criteria are required for opted-in won deals | Opportunity validation | T07 |
| R03 | Named CSM owns a Ready request with copied handoff data | Flow formulas and assignments | T01 |
| R04 | Missing CSM routes to Onboarding Triage and flags the request | Queue and Flow | T02 |
| R05 | Repeated edits and reopening never create a second request or overwrite progress | Existing-record lookup; unique source key | T03, T04, T09 |
| R06 | Source relationship and key cannot be changed after creation | Request validation | T08 |
| R07 | Triage work requires a user owner and cleared flag before progress | Request validation | T10, T11 |
| R08 | Overdue means requested start has passed and status is not Complete | Formula and list view | T12 |
| R09 | 200 eligible opportunities in one transaction produce 200 requests | Bulk-safe Flow elements | T13 |
| R10 | Sales can read requests; coordinators edit permitted fields on records they can edit | Permission sets and sharing | T14, T15 |
| R11 | Failure to create a request does not silently commit a handoff | Flow fault propagates; originating save rolls back | T16 |
| R12 | Users can understand status, triage and known limitations | User guide and demo | T17 |

## User stories

US01 (Must, R01–R03): As a seller, I want a complete handoff generated when an opted-in deal is won, so that I do not re-enter information. Acceptance: one linked request; copied data; Ready status; owner matches selected CSM.

US02 (Must, R04/R07): As a coordinator, I want unassigned work in a triage queue, so that missing ownership is visible. Acceptance: queue owns request; flag and status indicate triage; progress blocked until user owner is assigned and flag cleared.

US03 (Must, R05/R06): As an application owner, I want retries to preserve the original request, so that onboarding work is not duplicated or reset. Acceptance: repeat save and reopen/reclose preserve record ID and existing status.

US04 (Should, R08): As a manager, I want aging and overdue views, so that I can prioritize follow-up. Acceptance: overdue excludes completed requests; aging represents calendar days since creation, not a business-hours SLA.

US05 (Must, R10–R12): As a support analyst, I want testable access and troubleshooting guidance, so that I can investigate missing or inaccessible requests consistently.

## Decision log

| Decision | Reason | Tradeoff |
|---|---|---|
| Explicit opt-in checkbox | Isolates prototype from unrelated opportunities | Sellers must opt in |
| Validate critical details before won save | Prevents incomplete handoffs | An opted-in sale cannot be saved as won until fields are complete |
| Separate request object | Onboarding has its own owner and lifecycle | Additional object and access configuration |
| Queue when no CSM is selected | Keeps work visible without guessing an owner | Someone must triage the queue |
| Snapshot data at first handoff | Protects in-progress onboarding from later sales edits | Corrections require an explicit coordinator update |
| Preserve request after reopening | Avoids deleting work and re-creating duplicates | Cancellation review remains manual |
| Unique opportunity key plus lookup | Handles normal retries and adds a database constraint | Concurrent conflicting saves can fail; retry after refresh |
| Surface creation errors | Avoids silently lost handoffs | No separate durable incident is created in a rolled-back transaction |
| Public read-only request sharing in practice org | Simple cross-team visibility with edit ownership | Not a production privacy recommendation; revisit for real customer data |

## Proposed workshop (30 minutes)

5 min: agree the handoff outcome. 10 min: walk through a normal and failed handoff. 5 min: decide required fields and ownership. 5 min: review exceptions and access. 5 min: capture decisions, owners, and unresolved items. No real workshop has been claimed as completed.

## Two-sprint backlog

Sprint 1: scope and process map; data model; validation; opt-in Flow; assigned and queue paths; functional tests. Exit: R01–R07 validated in the org.

Sprint 2: aging views and reports; access UAT; bulk and failure tests; user guide; support rehearsal; demo evidence. Exit: release gates pass or unresolved limitations are explicitly disclosed.

## Measurement plan

Use identical synthetic scenarios to compare a manually executed email/spreadsheet-style handoff and the configured Salesforce process. Record start/end timestamps, manual actions, missing fields, and duplicate requests for each trial. Run at least 10 paired trials and report the sample size, median elapsed time, and errors. Do not turn synthetic test results into real business savings.

No measured time reduction or monetary return is currently claimed. The shipped implementation removes the separate manual request-creation step by design; the actual performance and user benefit require observation.
