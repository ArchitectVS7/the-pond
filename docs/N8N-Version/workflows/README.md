# N8N Workflows for GENESIS Pipeline

This directory contains N8N workflow definitions for all 12 phases of the GENESIS pipeline.

## 📁 Workflow Files

### Phase Workflows (Individual)

| File | Phase | Template | Description |
|------|-------|----------|-------------|
| `phase-01-ideation.json` | Phase 1 | dialectic | Dreamer/Doer creative conversation |
| `phase-02-focus-group.json` | Phase 2 | roundtable | 5 user personas validate vision |
| `phase-03-engineering-meeting.json` | Phase 3 | engineering-board | Create PRD from vision |
| `phase-04-stakeholder-review.json` | Phase 4 | roundtable | Validate PRD with stakeholders |
| `phase-05-triage.json` | Phase 5 | engineering-board | Prioritize features into phases |
| `phase-06-architecture.json` | Phase 6 | engineering-board | Design system architecture |
| `phase-07a-epic-planning.json` | Phase 7a | planning-session | Break into epics |
| `phase-07b-story-planning.json` | Phase 7b | planning-session | Expand stories |
| `phase-08-approval-gate.json` | Phase 8 | engineering-board | Approve build plan |
| `phase-09-build.json` | Phase 9 | build-cycle | Implement code |
| `phase-10-alpha-testing.json` | Phase 10 | roundtable | Internal testing |
| `phase-11-beta-testing.json` | Phase 11 | roundtable | Extended testing |
| `phase-12-release.json` | Phase 12 | engineering-board | Production approval |

### Master Workflow

| File | Description |
|------|-------------|
| `master-genesis-pipeline.json` | Full pipeline orchestrator that chains all 12 phases |

## 🔄 Implementation Status

### ✅ Implemented
- **phase-01-ideation.json** - Full implementation with dialectic pattern

### 📝 To Implement
The remaining 11 phase workflows follow the same pattern as Phase 1:
1. Webhook trigger
2. Load configuration
3. Load personas
4. Execute template workflow
5. Generate artifacts
6. Save to filesystem
7. Return response

## 🎯 How to Use

### 1. Import Workflows into N8N

```bash
# In N8N UI:
# Workflows → Import from File → Select JSON file
```

### 2. Configure Credentials

**Required**:
- Claude API credentials (HTTP Header Auth with `x-api-key`)
- Filesystem access (or S3 for cloud storage)

**Optional**:
- AgentDB connection (for memory persistence)
- Monitoring/logging endpoints

### 3. Trigger a Phase

**Via Webhook**:
```bash
curl -X POST http://localhost:5678/webhook/genesis/phase-1 \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "my-project",
    "idea_text": "Your product idea"
  }'
```

**Via N8N UI**:
- Open workflow
- Click "Execute Workflow"
- Provide test data

## 🏗️ Workflow Architecture

Each phase workflow follows this structure:

```
[Webhook] → [Validate] → [Load Config] → [Load Personas]
                                              ↓
                                        [Spawn Agents]
                                              ↓
                                    [Execute State Machine]
                                              ↓
                                      [Generate Artifacts]
                                              ↓
                                     [Save to Filesystem]
                                              ↓
                                      [Webhook Response]
```

## 📊 Template Mapping

### Dialectic Template (Phase 1)
- Agents: Dreamer, Doer, Facilitator, Synthesizer
- Pattern: Iterative 2-agent conversation with exit conditions
- Complexity: ~15 nodes

### Roundtable Template (Phases 2, 4, 10, 11)
- Agents: Facilitator + N participants + Researcher + Synthesizer
- Pattern: Multi-round structured discussion
- Complexity: ~20 nodes

### Engineering Board Template (Phases 3, 5, 6, 8, 12)
- Agents: Board Chair + Board Members + Writer (+ Researcher)
- Pattern: Evaluation and decision-making
- Complexity: ~25 nodes (more for spawn_substages)

### Planning Session Template (Phases 7a, 7b)
- Agents: Lead Planner + Domain Experts + Writer
- Pattern: Iterative refinement through stages
- Complexity: ~30 nodes

### Build Cycle Template (Phase 9)
- Agents: Orchestrator + Developers + Reviewers + Testers
- Pattern: Queue-based implementation with review loops
- Complexity: ~40 nodes

## 🔧 Customization Guide

### Adding Custom Agents

1. Create persona file in `.thursian/personas/`
2. Update workflow to load new persona
3. Add agent to conversation flow

### Modifying Exit Conditions

Edit the "Check Exit Condition" node:
```javascript
// Example: Add custom trigger
const custom_exit = last_text.includes('DONE');
if (custom_exit) {
  session.should_exit = true;
  session.exit_reason = 'custom_trigger';
}
```

### Changing AI Models

Update HTTP Request nodes:
```json
{
  "model": "claude-opus-4.5",  // or haiku, etc.
  "max_tokens": 8192,
  "temperature": 0.7
}
```

## 🚀 Performance Optimization

### Parallel Agent Spawning
- Use **Split in Batches** with `runOnceForAllItems: true`
- Spawn all agents simultaneously instead of sequentially

### Caching
- Cache persona files in workflow variables
- Reuse loaded configurations across rounds

### Rate Limiting
- Add **Wait** nodes between API calls
- Implement exponential backoff on errors

## 🐛 Debugging

### Enable Verbose Logging
```javascript
// Add to Function nodes
console.log('Current state:', JSON.stringify($json, null, 2));
```

### Test Individual Nodes
- Click on any node → "Execute Node"
- Inspect input/output data

### View Execution History
- **Executions** tab shows all workflow runs
- Click execution → See full data flow

## 📚 Related Documentation

- [../guides/02-N8N-Setup-Guide.md](../guides/02-N8N-Setup-Guide.md) - Complete setup instructions
- [../guides/03-Template-Reference.md](../guides/03-Template-Reference.md) - Template specifications
- [../examples/webhook-payloads.json](../examples/webhook-payloads.json) - Example API calls

## 🔗 Integration with Automaton

These workflows are designed to integrate with the **Automaton** project at `C:\dev\GIT\automaton`.

**Directory Structure**:
```
C:\dev\GIT\automaton\
├── n8n-data/               # N8N instance data
├── .thursian/              # Templates and personas
│   ├── personas/
│   └── templates/
└── automaton-projects/     # Generated projects
    └── {project-name}/
        └── .thursian/      # Project artifacts
```

## 📝 Next Steps

1. **Implement remaining workflows**: Use `phase-01-ideation.json` as template
2. **Add error handling**: Wrap API calls in try-catch
3. **Implement retry logic**: Add retry nodes for failed API calls
4. **Add monitoring**: Send metrics to observability platform
5. **Test full pipeline**: Run all 12 phases end-to-end

---

**Note**: `phase-01-ideation.json` is fully implemented. Remaining phases follow the same pattern but with template-specific logic. Refer to `../guides/01-GENESIS-Pipeline-Manual.md` for detailed phase specifications.
