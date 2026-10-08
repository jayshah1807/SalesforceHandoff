# Demo and submission guide

## Five-minute demo

0:00–0:35 — State that this is a simulated B2B software handoff project. Explain the missing-information and ownership problem.

0:35–1:25 — Open the seeded open opportunity, show the handoff fields, and change to a won stage. Show the resulting request and copied fields.

1:25–2:10 — Show an unassigned request in Needs Triage. Assign its owner, clear the flag, and progress it. Explain the queue decision.

2:10–2:50 — Edit the same source opportunity again and demonstrate that the original request and progress remain. Explain the unique key and snapshot tradeoff.

2:50–3:35 — Attempt to save an opted-in won opportunity with a missing required detail. Show the validation. Use a disposable demo record for this step.

3:35–4:15 — Show the overdue view and status/aging report. Explain that overdue is based on requested start, not an SLA promise.

4:15–5:00 — Show actual test evidence and one support investigation. State limitations, AI assistance, and what would require business approval before production.

## Evidence and optional demo captures

- Flow canvas with entry conditions and create path.
- Opportunity handoff section and validation message.
- Assigned request and triage request.
- Duplicate prevention demonstrated by same request ID/count.
- Overdue and status reporting.
- Successful deployment and Apex test summary.
- Non-admin access UAT results.

Use genuine screenshots. Do not fabricate a Salesforce screen or label a mockup as a deployment. Crop usernames, org identifiers, and unrelated records before sharing externally.

## Submission wording after successful validation

“Handoff Operations is an independent Salesforce Developer Edition portfolio project using synthetic B2B software data. It translates a simulated sales-to-Customer-Success handoff problem into documented requirements, a record-triggered Flow, validation rules, queue routing, duplicate controls, reporting, and a support runbook. The attached verification record states which automated and user acceptance tests were executed. Developed with AI assistance; design decisions and limitations are documented.”

Deployment and 17 automated test passes are now verified. The screenshots show actual request lists, a triage request and the dashboard. Non-admin access was tested through explicit user-mode operations, not a browser login. Do not claim stakeholder sign-off, measured savings or end-user adoption.

## Interview preparation

Be ready to explain: why use an opt-in; why a separate request object; why validate before handoff; why preserve snapshots; why a queue; why two duplicate controls; why an administrator is inadequate for access tests; what happens on creation failure; how a production release would differ.

You should personally execute the demo and understand the Flow before submitting. One explained design decision is more credible than an unsupported claim of enterprise impact.

## Sharing

Attach Project-Brief.pdf and, where accepted, the source ZIP. CASE-STUDY.html opens locally after extracting the ZIP. The live org requires your Salesforce login; it is not a public reviewer link. Use the included screenshots for an asynchronous review and your own signed-in session for a live demo. Never share credentials.
