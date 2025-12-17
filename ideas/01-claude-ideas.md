You've designed **an autonomous product studio** that goes from napkin sketch to shipped product with:

- Real market validation (not simulated)
- Persona-driven UX testing (grounded in actual research)
- Iterative refinement loops with governance
- Automated QA with visual evidence
- Human-in-the-loop at strategic checkpoints

**This is not "too advanced for a one-shot prompt."** This is a **14-stage orchestrated pipeline** that absolutely requires external orchestration—which is exactly what you've identified with n8n + SSH to Claude Code.

---

## The SSH Bridge: Why This Changes Everything

You're right that I said n8n couldn't directly orchestrate Claude Code. But **SSH changes that equation**.

If n8n can SSH into your machine and invoke Claude Code CLI commands:

```bash
# n8n executes via SSH
claude --project /path/to/project --message "Execute stage 2: Auto-Ideation per WORKFLOW.md"
```

Then n8n becomes the **rigid orchestrator** you need:

```
n8n Workflow (Deterministic State Machine)
    ↓ SSH command
Claude Code Session (Fuzzy Executor)
    ↓ writes output files
n8n File Watcher
    ↓ validates output exists
n8n Decision Node
    ↓ advances to next stage or retries
[Next Stage]
```

**This solves your core problem**: Claude can't drift if n8n controls the session lifecycle and validates outputs before advancing.

---

## Your Workflow Formalized

Let me give this a proper name and structure:

# **GENESIS Protocol**
### *From Ideation to Production: A 14-Stage Autonomous Product Development Pipeline*

---

### **Phase 0: Initialization**

| Stage | Name | Trigger |
|-------|------|---------|
| **0A** | **Genesis: New Idea** | User provides initial concept |
| **0B** | **Genesis: Resurrection** | Point to stalled repository |

**Output**: Initial context bundle (idea statement OR inferred mission/vision from existing code)

---

### **Phase 1: Vision Crystallization**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **1** | **Auto-Ideation** | Dreamer + Doer | Conversational loop until "ah-ha" moment |

**Dreamer**: Lives in "what if" - expands possibilities
**Doer**: Lives in "let's build it" - grounds in feasibility

**Output**: Vision Statement (1-3 pages)
**Exit Criteria**: Doer says "let me call some friends"

---

### **Phase 2: Market Validation**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **2** | **User Focus Group** | 5 Personas + Doer (facilitator) | 5 rounds + parallel web research |

**Personas**: Domain-relevant demographics (e.g., board gamer, mobile gamer, game designer)

**Research Integration**: 
- Actual game reviews, user scores
- Subreddit sentiment analysis
- Demographic alignment with personas

**Rounds**:
1. Initial reactions to idea
2. Expanding wider (adjacent possibilities)
3. Diving deeper (core mechanics/features)
4. Pain points (what's frustrating in current solutions)
5. Final thoughts (excitement level, dealbreakers)

**Output**: User Validation Report with research citations

---

### **Phase 3: Initial Design**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **3** | **Engineering Roundtable** | Domain Expert + Business Manager + Marketing Analyst + 2 others | 5 rounds + competitive research |

**Research Integration**:
- Competitive analysis (what exists)
- Gap analysis (what's missing)
- Library/framework survey (what can we leverage)
- Saturation assessment (is market crowded)

**Output**: PRD v1.0 (WHAT, not HOW)

---

### **Phase 4: Vision Alignment**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **4** | **Stakeholder Review** | Engineering Manager + Dreamer + Focus Group | PRD section-by-section review |

**Review Rounds** (per PRD section):
1. Initial reactions
2. Anything missing you expected?
3. Anything you'd change?
4. Which issues are critical?
5. Which issues are nice-to-have?

**Output**: Prioritized feedback matrix

---

### **Phase 5: Design Refinement**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **5** | **Engineering Review** | Engineering Team | Triage feedback into MVP/Alpha/Beta/Future |

**Categorization**:
- MVP Critical
- Alpha Release
- Beta Release
- Post-Launch
- Out of Scope

**Output**: PRD v0.2 (refined)

---


---

### **Phase 7: Project Planning**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **7A** | **Scheduling** | Project Manager | Epic → Story breakdown |
| **7B** | **Story Expansion** | PM + Technical Leads | Iterate until bulletproof |

**Stage 7A Output**:
- Epics with story slugs (not verbose)
- Traceability matrix (every story → PRD requirement)
- Milestones
- Resource requirements (Python expert, SQL expert, etc.)

**Stage 7B Output**:
- Detailed story specs
- Blockers
- Dependencies
- Acceptance criteria
- Implementation recipes

---

### **Phase 8: Build Approval Gate**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **8** | **Approval for Build** | Full Engineering Board | Consensus review |

**Process**:
- Every document reviewed for consistency
- Max 3 iteration rounds
- **Exit Criteria**: 95% approval OR escalate to human

**Output**: BUILD APPROVED or HUMAN REVIEW REQUIRED

---

### **Phase 9: Prototype Build**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **9A** | **Build Prototype** | Developer and Review Agents | Implement → Review → Test |
| **9B** | **Test Prototype** | Test Agents | Self-Play |

**Automated Testing**:
- Playwright/Puppeteer runs application
- Screenshots saved to disk
- Video recording of session
- Test reports generated

**Output**: Working prototype + visual evidence

---

### **Phase 10: Alpha Testing**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **10** | **Closed Alpha** | Alpha Group (Dreamer + Doer + Focus Groups + Engineering) | Full UX playthrough |

**Process**:
- Every button clicked
- Every text field populated
- Every response reviewed
- Screenshots captured
- Video recorded
- Persona-specific feedback collected

**Feedback Triage**:
- Critical → Implement before Beta
- High → Implement before Beta
- Medium → Beta backlog
- Low → Post-launch

**Output**: Alpha Test Report + Backlog updates

---

### **Phase 11: Beta Testing**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **11** | **Open Beta** | Beta Group (Alpha × 3 with demographic variation) | Expanded UX playthrough |

**Persona Multiplication**:
- Vary ages
- Vary experience levels
- Vary preferences
- Vary use cases

**Process**: Same as Alpha but broader coverage

**Output**: Beta Test Report + Final backlog triage

---

### **Phase 12: Release**

| Stage | Name | Agents | Method |
|-------|------|--------|--------|
| **12** | **Production Launch** | Release Manager | Final validation + deployment |

**Output**: **Finished product, seen by human for the first time**

---

## The n8n Orchestration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    n8n GENESIS WORKFLOW                     │
│                  (Deterministic Orchestrator)               │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  Stage Node   │    │  Stage Node   │    │  Stage Node   │
│   (1A/1B)     │───▶│     (2)       │───▶│     (3)       │
│   Genesis     │    │  Auto-Ideate  │    │ Focus Group   │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  SSH Execute  │    │  SSH Execute  │    │  SSH Execute  │
│  Claude Code  │    │  Claude Code  │    │  Claude Code  │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ File Watcher  │    │ File Watcher  │    │ File Watcher  │
│ Validate Out  │    │ Validate Out  │    │ Validate Out  │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│   Decision    │    │   Decision    │    │   Decision    │
│ Output Valid? │    │ Output Valid? │    │ Output Valid? │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
   ┌────┴────┐           ┌────┴────┐           ┌────┴────┐
   ▼         ▼           ▼         ▼           ▼         ▼
[Next]    [Retry]     [Next]    [Retry]     [Next]    [Retry]
```

---

## The Tools You Mentioned

### [Continuous Claude](https://github.com/AnandChowdhary/continuous-claude)
**What it does**: Keeps Claude sessions running continuously
**Relevance**: Could solve the "session dies mid-workflow" problem
**Integration**: n8n triggers continuous-claude instead of raw SSH

### [Swarms](https://github.com/kyegomez/swarms)
**What it does**: Multi-agent orchestration framework
**Relevance**: Could replace the subagent spawning you're doing manually
**Integration**: n8n → Swarms → Claude Code (adds another orchestration layer)

**My recommendation**: Start with n8n + SSH to Claude Code directly. Add Swarms or continuous-claude only if you hit specific limitations.

---

## What This Means for Thursian

**You've just designed Thursian's first Department**: The Product Development Department.

The GENESIS Protocol IS a Thursian workflow. It has:
- ✅ Deterministic stages
- ✅ Role-locked agents (Dreamer, Doer, Facilitator, PM, etc.)
- ✅ STOP gates (Stage 10: 95% approval)
- ✅ External orchestration (n8n)
- ✅ Validation at each stage
- ✅ Audit trail (all outputs saved to disk)

**The difference from what we designed earlier**: 
- n8n replaces LangGraph as the orchestrator
- SSH to Claude Code replaces the file-based contract layer
- Playwright/Puppeteer adds automated testing you didn't have before
- Web research integration grounds personas in reality

---

## Immediate Next Steps

### 1. **Validate SSH → Claude Code** (Tonight)
```bash
# Test if this works
ssh localhost "claude --version"
ssh localhost "claude --project /path/to/test --message 'Hello from SSH'"
```

### 2. **Create Stage 2 Prompt** (This weekend)
Write the Auto-Ideation prompt that spawns Dreamer + Doer:
```markdown
# Auto-Ideation Protocol

## Context
{INITIAL_IDEA or RESURRECTION_CONTEXT}

## Agents
- **Dreamer**: Expansive, "what if" thinking
- **Doer**: Grounded, "let's build it" thinking

## Exit Condition
Doer reaches "ah-ha" moment and proposes calling friends

## Output
/outputs/stage-2-vision.md (1-3 pages)
```

### 3. **Build n8n Skeleton** (Next week)
Create the 14-stage workflow with placeholder SSH commands

### 4. **Implement Stage by Stage**
Don't try to build all 14 at once. Start with 1A → 2 → 3, validate, then expand.

---

## The Big Picture

You asked earlier if you'd "shortcut Thursian" with simple markdown + subagents.

**Answer**: No. You've designed something **more ambitious than Thursian Core**—a complete autonomous product studio. The simple markdown approach worked for 2 epics. GENESIS is designed to ship **entire products**.

This is the real vision. Build this.

Want me to draft the n8n workflow skeleton or the Stage 2 Auto-Ideation prompt?