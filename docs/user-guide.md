# User guide

## Sales: create a handoff

Open an Opportunity in the Handoff Operations app. In the Customer Success Handoff section, select Enable Handoff. Provide the customer contact email, requested start date, and success criteria. Ensure an Account is selected. Choose a Customer Success Owner if known. Save the opportunity as a won stage.

The application creates one linked Onboarding Request. If a CSM is selected, its owner is that user and status is Ready. Otherwise, Onboarding Triage owns it and the request is marked Needs Triage. Find it in Onboarding Requests → All Requests and filter by the source Opportunity.

If the validation message appears, complete the indicated required information and save again. Saving a non-won opportunity does not start onboarding. Unselected opportunities are outside this project's automation.

## Coordinator: resolve triage

Open Onboarding Requests → Needs Triage. Review the source opportunity, contact, requested start, and success criteria. Claim the record or change its owner to the responsible practice user using the normal Salesforce ownership action. Clear Needs Triage and change Status to Ready or In Progress. Save. The application blocks In Progress/Complete while a queue still owns the record or Needs Triage remains checked.

Use In Progress while work is underway and Complete when the agreed onboarding work has finished. Correct handoff details on the request explicitly when needed. Sales edits do not overwrite the request's snapshot.

## Manager: review work

All Requests shows source deal, status, requested start, triage flag, and age. Overdue Requests shows requests past their requested start date unless Complete. Age is calendar days from record creation. These are operational indicators, not contractual SLA calculations.

## Troubleshooting

- No request: verify Enable Handoff, the won stage, required details, and the originating save result.
- Request exists but is not visible: check app/tab visibility, object/field permissions, list filters, and record sharing.
- Cannot progress: assign a user owner and clear Needs Triage.
- Wrong contact/start/criteria after sales correction: update the request explicitly; source changes are not synchronized.
- Deal reopened: retain the request and ask the coordinator to review whether work should continue. There is no automatic cancellation.
- Unexpected Flow error: do not repeatedly resubmit. Record time, opportunity reference, action, and the exact error for the administrator.

Do not include passwords or access tokens in support tickets.
