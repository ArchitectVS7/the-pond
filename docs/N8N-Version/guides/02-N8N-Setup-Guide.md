# N8N Setup Guide for GENESIS Pipeline

This guide shows you how to replicate the GENESIS pipeline in N8N for the Automaton project.

## 📋 Prerequisites

1. **N8N Instance** running (Docker or cloud)
2. **Claude API Access** (Anthropic API key)
3. **File Storage** (local filesystem or S3)
4. **AgentDB** or compatible memory backend (optional but recommended)
5. **Automaton Project** at `C:\dev\GIT\automaton`

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────┐
│   HTTP Webhook (Trigger)                    │
│   POST /webhook/genesis/{phase}             │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│   N8N Workflow Engine                       │
│   - Load configuration                      │
│   - Validate inputs                         │
│   - Initialize memory namespace             │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│   Agent Spawning Loop                       │
│   - For each agent in template              │
│   - Call Claude API with persona prompt     │
│   - Store response in memory                │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│   Workflow Execution                        │
│   - Run template state machine              │
│   - Coordinate agent interactions           │
│   - Track conversation rounds               │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│   Artifact Generation                       │
│   - Synthesizer creates final document      │
│   - Save to filesystem                      │
│   - Update project metadata                 │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│   Webhook Response                          │
│   - Return phase completion status          │
│   - Include artifact paths                  │
│   - Next phase recommendations              │
└─────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Step 1: N8N Installation

**Using Docker**:
```bash
cd C:\dev\GIT\automaton
docker-compose up -d n8n
```

**Docker Compose Config**:
```yaml
version: '3'
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_password
      - WEBHOOK_URL=http://localhost:5678/
    volumes:
      - ./n8n-data:/home/node/.n8n
      - ./automaton-workspace:/workspace
    restart: unless-stopped
```

### Step 2: Import Workflows

1. Open N8N: `http://localhost:5678`
2. Go to **Workflows** → **Import from File**
3. Import each phase workflow from `docs/N8N-Version/workflows/`
4. Import master orchestrator: `master-genesis-pipeline.json`

### Step 3: Configure Credentials

**Anthropic API**:
1. **Settings** → **Credentials** → **Add Credential**
2. Type: **HTTP Header Auth**
3. Name: `Claude-API`
4. Header Name: `x-api-key`
5. Header Value: `your_anthropic_api_key`

**File Storage**:
1. **Settings** → **Credentials** → **Add Credential**
2. Type: **Filesystem** (or **AWS S3** for cloud)
3. Configure paths:
   - Base path: `/workspace/automaton-projects`
   - Artifacts: `/workspace/automaton-projects/{project}/.thursian`

### Step 4: Test Single Phase

**Trigger Phase 1 (Ideation)**:
```bash
curl -X POST http://localhost:5678/webhook/genesis/phase-1 \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "test-project",
    "idea_text": "A productivity app that uses AI to auto-schedule your day based on energy levels"
  }'
```

**Expected Response**:
```json
{
  "status": "completed",
  "phase": "phase_1_ideation",
  "artifacts": {
    "vision_document": "/workspace/automaton-projects/test-project/.thursian/visions/vision-v1.md",
    "conversation_log": "/workspace/automaton-projects/test-project/.thursian/conversations/ideation-full.md"
  },
  "next_phase": "phase_2_focus_group",
  "execution_time_ms": 18234
}
```

### Step 5: Run Full Pipeline

**Using Master Orchestrator**:
```bash
curl -X POST http://localhost:5678/webhook/genesis/run-pipeline \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "my-awesome-product",
    "idea_file": "/workspace/ideas/initial-idea.md",
    "execution_mode": "idea_to_approved",
    "auto_advance": true,
    "human_review_phases": [4, 8]
  }'
```

**Execution Modes**:
- `full_genesis`: All 12 phases
- `idea_to_approved`: Phases 1-8 (planning only)
- `idea_to_prototype`: Phases 1-9 (build MVP)
- `idea_to_alpha`: Phases 1-10 (internal testing)

---

## 📐 N8N Workflow Structure

### Template: Phase Workflow

Each phase workflow follows this structure:

```
[Webhook Trigger]
    │
    ▼
[Validate Input]
    │
    ▼
[Load Configuration]
    │
    ▼
[Initialize Memory]
    │
    ▼
[Load Personas] ──┐
    │             │
    ▼             │
[Spawn Agents] <──┘ (Loop for each agent)
    │
    ▼
[Execute State Machine]
    │
    ├─> [State: Initialize]
    ├─> [State: Open Discussion/Dialectic]
    ├─> [State: Conversation Rounds] (Loop)
    ├─> [State: Evaluate Exit Conditions]
    ├─> [State: Prepare Synthesis]
    └─> [State: Synthesize Output]
    │
    ▼
[Generate Artifacts]
    │
    ▼
[Save to Filesystem]
    │
    ▼
[Update Metadata]
    │
    ▼
[Webhook Response]
```

### Example: Phase 1 (Ideation) Workflow

**Node 1: Webhook Trigger**
```json
{
  "name": "GENESIS Phase 1 Trigger",
  "type": "n8n-nodes-base.webhook",
  "parameters": {
    "path": "genesis/phase-1",
    "method": "POST",
    "responseMode": "responseNode"
  }
}
```

**Node 2: Validate Input**
```json
{
  "name": "Validate Input",
  "type": "n8n-nodes-base.function",
  "parameters": {
    "functionCode": "const input = items[0].json;\n\nif (!input.project_name) throw new Error('project_name required');\nif (!input.idea_text && !input.idea_file) throw new Error('idea_text or idea_file required');\n\nreturn items;"
  }
}
```

**Node 3: Load Idea**
```json
{
  "name": "Load Idea",
  "type": "n8n-nodes-base.readFile",
  "parameters": {
    "filePath": "={{ $json.idea_file || '/tmp/idea.txt' }}"
  }
}
```

**Node 4: Load Dreamer Persona**
```json
{
  "name": "Load Dreamer Persona",
  "type": "n8n-nodes-base.readFile",
  "parameters": {
    "filePath": "/workspace/automaton/.thursian/personas/ideation/dreamer.md"
  }
}
```

**Node 5: Load Doer Persona**
```json
{
  "name": "Load Doer Persona",
  "type": "n8n-nodes-base.readFile",
  "parameters": {
    "filePath": "/workspace/automaton/.thursian/personas/ideation/doer.md"
  }
}
```

**Node 6: Initialize Session**
```json
{
  "name": "Initialize Session",
  "type": "n8n-nodes-base.function",
  "parameters": {
    "functionCode": "const session = {\n  project_name: $json.project_name,\n  session_id: Date.now().toString(36),\n  phase: 'phase_1_ideation',\n  current_round: 0,\n  max_rounds: 8,\n  min_rounds: 4,\n  conversation_history: [],\n  idea_text: $json.idea_text || $node['Load Idea'].json.data\n};\n\nreturn [{ json: session }];"
  }
}
```

**Node 7: Dialectic Round Loop**
```json
{
  "name": "Dialectic Round",
  "type": "n8n-nodes-base.splitInBatches",
  "parameters": {
    "batchSize": 1,
    "options": {
      "reset": false
    }
  }
}
```

**Node 8: Dreamer Response (Claude API)**
```json
{
  "name": "Dreamer Responds",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.anthropic.com/v1/messages",
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "claudeApi",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {
          "name": "anthropic-version",
          "value": "2023-06-01"
        }
      ]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "model",
          "value": "claude-sonnet-4.5"
        },
        {
          "name": "max_tokens",
          "value": 4096
        },
        {
          "name": "system",
          "value": "={{ $node['Load Dreamer Persona'].json.data }}"
        },
        {
          "name": "messages",
          "value": "={{ $json.conversation_history }}"
        }
      ]
    }
  }
}
```

**Node 9: Doer Response (Claude API)**
```json
{
  "name": "Doer Responds",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.anthropic.com/v1/messages",
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "claudeApi",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {
          "name": "anthropic-version",
          "value": "2023-06-01"
        }
      ]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "model",
          "value": "claude-sonnet-4.5"
        },
        {
          "name": "max_tokens",
          "value": 4096
        },
        {
          "name": "system",
          "value": "={{ $node['Load Doer Persona'].json.data }}"
        },
        {
          "name": "messages",
          "value": "={{ $json.conversation_history }}"
        }
      ]
    }
  }
}
```

**Node 10: Check Exit Condition**
```json
{
  "name": "Check Exit Condition",
  "type": "n8n-nodes-base.function",
  "parameters": {
    "functionCode": "const session = $json;\nconst last_message = session.conversation_history[session.conversation_history.length - 1];\n\n// Check for aha moment\nconst aha_triggers = ['aha', 'ah-ha', 'I see it now', 'this is it'];\nconst has_aha = aha_triggers.some(trigger => \n  last_message.content[0].text.toLowerCase().includes(trigger)\n);\n\nsession.current_round += 1;\n\nif (has_aha && session.current_round >= session.min_rounds) {\n  session.exit_reason = 'aha_moment';\n  session.should_exit = true;\n} else if (session.current_round >= session.max_rounds) {\n  session.exit_reason = 'max_rounds';\n  session.should_exit = true;\n} else {\n  session.should_exit = false;\n}\n\nreturn [{ json: session }];"
  }
}
```

**Node 11: Branch on Exit**
```json
{
  "name": "Should Exit?",
  "type": "n8n-nodes-base.if",
  "parameters": {
    "conditions": {
      "boolean": [
        {
          "value1": "={{ $json.should_exit }}",
          "value2": true
        }
      ]
    }
  }
}
```

**Node 12: Synthesize Vision (Claude API)**
```json
{
  "name": "Synthesize Vision",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.anthropic.com/v1/messages",
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "claudeApi",
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "model",
          "value": "claude-sonnet-4.5"
        },
        {
          "name": "max_tokens",
          "value": 8192
        },
        {
          "name": "system",
          "value": "={{ $node['Load Synthesizer Persona'].json.data }}"
        },
        {
          "name": "messages",
          "value": "[{\n  \"role\": \"user\",\n  \"content\": \"Create a vision document from this conversation:\\n\\n{{ $json.conversation_history }}\"\n}]"
        }
      ]
    }
  }
}
```

**Node 13: Save Vision Document**
```json
{
  "name": "Save Vision",
  "type": "n8n-nodes-base.writeFile",
  "parameters": {
    "fileName": "={{ '/workspace/automaton-projects/' + $json.project_name + '/.thursian/visions/vision-v1.md' }}",
    "data": "={{ $json.content[0].text }}"
  }
}
```

**Node 14: Save Conversation Log**
```json
{
  "name": "Save Conversation",
  "type": "n8n-nodes-base.writeFile",
  "parameters": {
    "fileName": "={{ '/workspace/automaton-projects/' + $json.project_name + '/.thursian/conversations/ideation-full.md' }}",
    "data": "={{ $json.conversation_history }}"
  }
}
```

**Node 15: Webhook Response**
```json
{
  "name": "Success Response",
  "type": "n8n-nodes-base.respondToWebhook",
  "parameters": {
    "respondWith": "json",
    "responseBody": "={\n  \"status\": \"completed\",\n  \"phase\": \"phase_1_ideation\",\n  \"artifacts\": {\n    \"vision_document\": {{ $node['Save Vision'].json.filePath }},\n    \"conversation_log\": {{ $node['Save Conversation'].json.filePath }}\n  },\n  \"next_phase\": \"phase_2_focus_group\",\n  \"rounds_completed\": {{ $json.current_round }},\n  \"exit_reason\": {{ $json.exit_reason }}\n}"
  }
}
```

---

## 🔧 Configuration Files

### Master Configuration

**File**: `automaton/n8n-config/genesis-config.json`

```json
{
  "genesis": {
    "version": "2.0.0",
    "base_path": "/workspace/automaton-projects",
    "persona_path": "/workspace/automaton/.thursian/personas",
    "template_path": "/workspace/automaton/.thursian/templates"
  },
  "claude_api": {
    "endpoint": "https://api.anthropic.com/v1/messages",
    "model": "claude-sonnet-4.5",
    "default_max_tokens": 4096,
    "default_temperature": 0.7
  },
  "memory": {
    "backend": "agentdb",
    "namespace_template": "genesis/{project_name}/{phase}",
    "persistence": true
  },
  "execution": {
    "default_mode": "full_genesis",
    "auto_advance": false,
    "human_review_phases": [4, 8, 12],
    "max_parallel_agents": 5
  }
}
```

### Phase Configuration Example

**File**: `automaton/n8n-config/phase-1-config.json`

```json
{
  "phase_id": "phase_1_ideation",
  "template": "dialectic",
  "agents": {
    "agent_a": {
      "role": "dreamer",
      "persona_file": "ideation/dreamer.md",
      "model": "claude-sonnet-4.5",
      "temperature": 0.9
    },
    "agent_b": {
      "role": "doer",
      "persona_file": "ideation/doer.md",
      "model": "claude-sonnet-4.5",
      "temperature": 0.7
    },
    "facilitator": {
      "role": "conversation_manager",
      "persona_file": "facilitation/dialectic-facilitator.md",
      "model": "claude-sonnet-4.5",
      "temperature": 0.5
    },
    "synthesizer": {
      "role": "output_writer",
      "persona_file": "ideation/synthesizer.md",
      "model": "claude-sonnet-4.5",
      "temperature": 0.3
    }
  },
  "parameters": {
    "exit_condition": "aha_moment",
    "max_rounds": 8,
    "min_rounds": 4,
    "output_format": "vision"
  },
  "outputs": {
    "vision_document": "visions/vision-v1.md",
    "conversation_log": "conversations/ideation-full.md"
  }
}
```

---

## 🎯 Advanced Features

### Parallel Agent Spawning

Use N8N's **Split in Batches** node with **Run Once for All Items** to spawn multiple agents in parallel:

```json
{
  "name": "Spawn All Agents",
  "type": "n8n-nodes-base.splitInBatches",
  "parameters": {
    "batchSize": "={{ $json.agents.length }}",
    "options": {
      "reset": false,
      "runOnceForAllItems": true
    }
  }
}
```

### Memory Integration

Use N8N's **Execute Workflow** node to call AgentDB operations:

```json
{
  "name": "Store in Memory",
  "type": "n8n-nodes-base.executeWorkflow",
  "parameters": {
    "workflowId": "agentdb-store",
    "data": {
      "namespace": "={{ 'genesis/' + $json.project_name + '/phase_1' }}",
      "key": "={{ 'conversation_round_' + $json.current_round }}",
      "value": "={{ $json.conversation_history }}"
    }
  }
}
```

### Error Handling

Add error handling nodes:

```json
{
  "name": "On Error",
  "type": "n8n-nodes-base.errorTrigger",
  "parameters": {}
},
{
  "name": "Log Error",
  "type": "n8n-nodes-base.writeFile",
  "parameters": {
    "fileName": "={{ '/workspace/automaton-projects/' + $json.project_name + '/.thursian/errors/phase-1-error.log' }}",
    "data": "={{ $json.error }}"
  }
},
{
  "name": "Error Response",
  "type": "n8n-nodes-base.respondToWebhook",
  "parameters": {
    "respondWith": "json",
    "responseBody": "={\n  \"status\": \"error\",\n  \"phase\": \"phase_1_ideation\",\n  \"error\": {{ $json.error }}\n}"
  }
}
```

---

## 📊 Monitoring & Debugging

### Enable Workflow Execution Logging

1. **Settings** → **Log Output** → **Verbose**
2. View logs: **Executions** → Select workflow → **Execution Data**

### Monitor Agent Performance

Create a monitoring workflow that tracks:
- Execution time per phase
- Token usage per agent
- Success/failure rates
- Artifact sizes

### Debug Mode

Add **Sticky Notes** and **Function** nodes to inspect data:

```javascript
// Debug node
console.log('Current state:', JSON.stringify($json, null, 2));
return items;
```

---

## 🔐 Security Best Practices

1. **API Keys**: Store in N8N credentials, never in workflows
2. **Webhook Auth**: Enable basic auth or API key validation
3. **File Permissions**: Restrict write access to project directories
4. **Rate Limiting**: Implement rate limits on webhooks
5. **Input Validation**: Sanitize all user inputs

---

## 🚢 Deployment

### Production Deployment

1. **Use N8N Cloud** or self-hosted with SSL
2. **Configure backup** for workflows and data
3. **Set up monitoring** (Prometheus, Grafana)
4. **Enable high availability** (multiple N8N instances)
5. **Use queue mode** for long-running workflows

### Environment Variables

```bash
export N8N_BASIC_AUTH_ACTIVE=true
export N8N_BASIC_AUTH_USER=admin
export N8N_BASIC_AUTH_PASSWORD=secure_password
export WEBHOOK_URL=https://your-domain.com/
export GENERIC_TIMEZONE=America/Chicago
export N8N_LOG_LEVEL=info
export EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
export EXECUTIONS_DATA_SAVE_ON_ERROR=all
export EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
```

---

## 📚 Next Steps

1. **Import all 12 phase workflows** from `workflows/` directory
2. **Test each phase individually** with example payloads
3. **Run the full pipeline** with the master orchestrator
4. **Customize personas** for your specific domain
5. **Extend templates** for custom use cases

See [03-Template-Reference.md](03-Template-Reference.md) for template customization.
