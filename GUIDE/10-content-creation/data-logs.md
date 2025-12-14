# Data Logs

Data logs are the evidence the player discovers. Each one reveals part of the environmental conspiracy, from corporate memos to suppressed research. This chapter covers how to write effective data logs.

---

## Structure

Every data log has three parts:

### 1. TL;DR

A 1-2 sentence summary of what the document reveals. This appears in the conspiracy board's quick-view mode.

```markdown
## TL;DR
Internal memo from AgriCorp VP reveals plan to dump untreated agricultural
waste directly into wetlands to avoid treatment costs. Projected savings:
$2.3M annually.
```

### 2. Full Document

The actual in-world document. This is what the player reads in the document viewer.

```markdown
## Full Document

**TO:** Regional Operations Directors
**FROM:** Marcus Chen, VP of Cost Optimization
**DATE:** March 15, 2024
**RE:** Q2 Cost Reduction Initiative - Waste Management Protocol Revision
**CLASSIFICATION:** Internal Use Only

Colleagues,

As we approach the end of Q1...
```

### 3. Narrative Context

A brief paragraph explaining where the player found this and how it connects to their personal story. Written from the frog's perspective.

```markdown
## Narrative Context (Player Discovery)

You found this memo tucked inside a corroded filing cabinet near the old
processing plant. The signature is still visible, though water damage has
made parts of the document illegible. The date is from eight months ago—
right when the algae blooms started choking the lily pads.

Your tadpole sibling disappeared shortly after April. You never knew why.

Now you do.
```

---

## Document Types

| Type | Voice | Content |
|------|-------|---------|
| Corporate Memo | Formal, euphemistic | Decisions, directives |
| Internal Email | Casual, hurried | Conversations, warnings |
| Research Report | Technical, hedged | Data, findings |
| Legal Document | Dense, protective | Contracts, settlements |
| News Article | Journalistic | Public-facing spin |
| Personal Letter | Emotional | Whistleblower testimony |

---

## Writing Corporate Voice

Corporate documents use specific language patterns:

### Euphemisms

| Real Meaning | Corporate Speak |
|--------------|-----------------|
| Dump waste | "Natural remediation" |
| Ignore regulations | "Regulatory optimization" |
| Fire whistleblowers | "Organizational restructuring" |
| Bribe officials | "Stakeholder engagement" |
| Cover up | "Reputation management" |

### Distancing Language

```markdown
# Bad - too direct
"We will pollute the wetlands to save money."

# Good - corporate voice
"Transitioning to natural remediation pathways will optimize our cost
structure while leveraging existing ecological infrastructure."
```

### Plausible Deniability

Corporate documents never explicitly admit wrongdoing:

```markdown
"While our environmental consultants have flagged potential concerns
regarding nitrogen runoff concentrations, historical data suggests these
effects will be offset by natural ecosystem resilience."
```

---

## Writing Emotional Hooks

The narrative context connects evidence to the player's personal story:

### Connection Patterns

| Pattern | Example |
|---------|---------|
| Timing | "The date is from eight months ago—right when..." |
| Location | "Near where your family used to swim..." |
| Names | "The research subject ID matches your sister's..." |
| Consequence | "Now you understand why the heron never came back." |

### Escalation

Early logs have local connections. Later logs reveal systemic problems:

```markdown
# Early game
"Your pond isn't the only one. There are dozens of facilities
across the region following the same 'protocol.'"

# Late game
"The memo CC list includes names you recognize from the
government oversight committee."
```

---

## Example: Corporate Memo

```markdown
# Data Log 01: Corporate Memo - Cost Reduction Initiative

## TL;DR
Internal memo from AgriCorp VP reveals plan to dump untreated agricultural
waste directly into wetlands to avoid treatment costs. Projected savings:
$2.3M annually. Environmental impact dismissed as "acceptable risk."

---

## Full Document

**TO:** Regional Operations Directors
**FROM:** Marcus Chen, VP of Cost Optimization
**DATE:** March 15, 2024
**RE:** Q2 Cost Reduction Initiative - Waste Management Protocol Revision
**CLASSIFICATION:** Internal Use Only

Colleagues,

As we approach the end of Q1, I'm pleased to report that our fertilizer
production output has increased 18% year-over-year. However, our waste
treatment expenses have risen disproportionately, now consuming 14% of
operational budgets across our Midwest facilities.

After consultation with Legal and our external environmental consultants,
we've identified an opportunity to significantly reduce these costs through
strategic realignment of our waste discharge protocols.

**Current Situation:**
Our River Valley facility currently routes agricultural runoff through a
three-stage treatment system before discharge. This process costs
approximately $47,000 per week in chemicals, energy, and maintenance.

**Proposed Solution:**
Transition to "natural remediation" by routing untreated runoff directly
into adjacent wetland buffer zones. These ecosystems are classified as
non-navigable waters under the 2020 Clean Water Rule revision, placing
them outside direct EPA jurisdiction.

**Financial Impact:**
- Immediate Savings: $2.3M annually (River Valley site alone)
- Avoided Capital Expenses: $8.5M (deferred treatment plant upgrade)
- ROI Timeline: Immediate

Questions or concerns should be directed to Legal (ext. 4421) rather
than discussed via email.

Best regards,
Marcus Chen
Vice President, Cost Optimization
AgriCorp Industries

**CONFIDENTIAL - DO NOT FORWARD**

---

## Narrative Context (Player Discovery)

You found this memo tucked inside a corroded filing cabinet near the old
processing plant. The signature is still visible, though water damage has
made parts of the document illegible. The date is from eight months ago—
right when the algae blooms started choking the lily pads.

Your tadpole sibling disappeared shortly after April. Now you do.
```

---

## Research Foundation

Base content on real patterns:

| Topic | Research Areas |
|-------|----------------|
| Wetland dumping | EPA enforcement actions |
| Corporate memos | Documented misconduct cases |
| Regulatory gaps | Clean Water Rule history |
| Cost-benefit | Industrial economics |

### Sources to Reference

- EPA ECHO database (enforcement actions)
- ProPublica environmental investigations
- Academic papers on wetland ecosystems
- Corporate disclosure documents

---

## Length Guidelines

| Section | Target Length |
|---------|---------------|
| TL;DR | 1-2 sentences |
| Full Document | 200-400 words |
| Narrative Context | 2-3 sentences |

Documents that are too long won't be read. Too short won't feel substantial. The sweet spot is a document that feels complete but doesn't overstay its welcome.

---

## Conspiracy Connections

Each log connects to others:

```markdown
Log 01: Corporate Memo
  ↓ Mentions "Legal consultation"
Log 05: Legal Strategy Document
  ↓ Mentions "Senator Ribbit's office"
Log 09: Lobbying Records
  ↓ Reveals political corruption
```

Document the intended connections in comments:

```markdown
<!-- CONNECTIONS:
- Links TO: Log 05 (legal team mentioned)
- Links FROM: Log 03 (same VP name)
- THEME: Cost over safety
-->
```

---

## Quality Checklist

Before finalizing a data log:

- [ ] TL;DR is exactly 1-2 sentences
- [ ] Full document uses appropriate voice
- [ ] No real company/person names
- [ ] Facts are plausible and researched
- [ ] Narrative context is personal
- [ ] Connections to other logs are clear
- [ ] Length is 200-400 words
- [ ] No spelling/grammar errors

---

## File Naming

```
conspiracy_board/content/data_logs/
├── 01_corporate_memo.md
├── 02_internal_email.md
├── 03_research_report.md
├── 04_legal_settlement.md
└── ...
```

Use sequential numbering for discovery order.

---

## Summary

| Element | Purpose |
|---------|---------|
| TL;DR | Quick reference for conspiracy board |
| Full Document | Immersive reading experience |
| Narrative Context | Emotional connection to player |
| Connections | Web of evidence |

Data logs are the backbone of The Pond's story. Good logs feel like real documents that reveal real wrongdoing, grounded in research but told through the lens of a frog who's lost family to corporate greed.

---

[← Back to Overview](overview.md) | [Next: Dialogue →](dialogue.md)
