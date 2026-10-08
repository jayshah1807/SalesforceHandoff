# Handoff Operations — Salesforce Portfolio Project

An independent Business Analyst portfolio project aligned with enterprise application support, Salesforce configuration, requirements analysis, low-code delivery, testing, and release management.

**Status: deployed and verified in Salesforce Developer Edition on 7 October 2026. All 17 automated tests passed. Live reports show three requests and one overdue request; genuine screenshots are included.** See `evidence/verification.md` for the authoritative verification record. Do not describe planned tests as passed.

## Start here

- `CASE-STUDY.html` — polished reviewer-facing case study; open in a browser.
- `Project-Brief.pdf` — four-page project overview with the current verification status.
- `docs/business-analysis.md` — business problem, requirements, decisions, scope, traceability, and sprint backlog.
- `docs/implementation.md` — data model, access model, automation, limits, deployment, and rollback.
- `docs/user-guide.md` — sales and coordinator workflows and troubleshooting.
- `docs/demo-and-submission.md` — five-minute walkthrough, evidence capture, and accurate submission wording.
- `docs/uat.md` — functional and access tests with acceptance conditions.
- `docs/support-runbook.md` — three simulated tickets and investigation procedures.
- `force-app/` — Salesforce metadata, active Flow, and automated Apex tests.
- `scripts/seed-demo.apex` — small, synthetic demonstration dataset.

## Portfolio integrity

The company, business problem, stakeholder needs, and records are simulated. This is not Kinaxis internal work, a real client engagement, or a claim of business savings. The project was prepared with AI assistance. The candidate should execute the walkthrough and understand the design before presenting it as a portfolio project. No job application has been submitted.

## Platform and cost

Targets Salesforce Developer Edition, a free testing and development environment. No paid packages, integrations, AI services, or production licenses are required. An existing Trailhead Playground may also work but must pass deployment validation. A Salesforce admin login is needed for setup. API version 64.0 is used deliberately for compatibility; target-org validation remains authoritative.

Official references:
- https://developer.salesforce.com/docs/platform/api-rest/guide/quickstart-dev-org.html
- https://developer.salesforce.com/docs/platform/salesforce-cli-reference/guide/cli_reference_project_deploy_start.html
- https://trailhead.salesforce.com/content/learn/trails/automate-business-processes-admin
- https://trailhead.salesforce.com/content/learn/modules/flow-implementation-2/grant-flow-permissions-and-context
