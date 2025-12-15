{
  "name": "GENESIS Phase 1: Ideation",
  "nodes": [
    {
      "parameters": {
        "path": "genesis/phase-1",
        "method": "POST",
        "responseMode": "responseNode"
      },
      "name": "Webhook Trigger",
      "type": "n8n-nodes-base.webhook",
      "position": [250, 300]
    },
    {
      "parameters": {
        "functionCode": "// Validate input\nconst input = items[0].json;\n\nif (!input.project_name) {\n  throw new Error('project_name is required');\n}\nif (!input.idea_text && !input.idea_file) {\n  throw new Error('idea_text or idea_file is required');\n}\n\n// Initialize session\nconst session = {\n  project_name: input.project_name,\n  session_id: Date.now().toString(36),\n  phase: 'phase_1_ideation',\n  current_round: 0,\n  max_rounds: input.max_rounds || 8,\n  min_rounds: input.min_rounds || 4,\n  conversation_history: [],\n  idea_text: input.idea_text || '',\n  aha_triggers: ['aha', 'ah-ha', 'I see it now', 'this is it', 'that\\'s the game']\n};\n\nreturn [{ json: session }];"
      },
      "name": "Initialize Session",
      "type": "n8n-nodes-base.function",
      "position": [450, 300]
    },
    {
      "parameters": {
        "filePath": "=/workspace/automaton/.thursian/personas/ideation/dreamer.md"
      },
      "name": "Load Dreamer Persona",
      "type": "n8n-nodes-base.readFile",
      "position": [650, 200]
    },
    {
      "parameters": {
        "filePath": "=/workspace/automaton/.thursian/personas/ideation/doer.md"
      },
      "name": "Load Doer Persona",
      "type": "n8n-nodes-base.readFile",
      "position": [650, 300]
    },
    {
      "parameters": {
        "filePath": "=/workspace/automaton/.thursian/personas/ideation/synthesizer.md"
      },
      "name": "Load Synthesizer Persona",
      "type": "n8n-nodes-base.readFile",
      "position": [650, 400]
    },
    {
      "parameters": {
        "batchSize": 1,
        "options": {
          "reset": false
        }
      },
      "name": "Dialectic Round Loop",
      "type": "n8n-nodes-base.splitInBatches",
      "position": [850, 300]
    },
    {
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
        "specifyBody": "json",
        "jsonBody": "={\n  \"model\": \"claude-sonnet-4.5\",\n  \"max_tokens\": 4096,\n  \"system\": {{ $node['Load Dreamer Persona'].json.data }},\n  \"messages\": {{ $json.conversation_history }}\n}"
      },
      "name": "Dreamer Responds",
      "type": "n8n-nodes-base.httpRequest",
      "position": [1050, 200]
    },
    {
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
        "specifyBody": "json",
        "jsonBody": "={\n  \"model\": \"claude-sonnet-4.5\",\n  \"max_tokens\": 4096,\n  \"system\": {{ $node['Load Doer Persona'].json.data }},\n  \"messages\": {{ $json.conversation_history }}\n}"
      },
      "name": "Doer Responds",
      "type": "n8n-nodes-base.httpRequest",
      "position": [1250, 200]
    },
    {
      "parameters": {
        "functionCode": "// Check exit conditions\nconst session = items[0].json;\nconst last_message = session.conversation_history[session.conversation_history.length - 1];\nconst last_text = last_message?.content?.[0]?.text || '';\n\n// Check for aha moment\nconst has_aha = session.aha_triggers.some(trigger => \n  last_text.toLowerCase().includes(trigger.toLowerCase())\n);\n\nsession.current_round += 1;\n\nif (has_aha && session.current_round >= session.min_rounds) {\n  session.exit_reason = 'aha_moment';\n  session.should_exit = true;\n} else if (session.current_round >= session.max_rounds) {\n  session.exit_reason = 'max_rounds';\n  session.should_exit = true;\n} else {\n  session.should_exit = false;\n}\n\nreturn [{ json: session }];"
      },
      "name": "Check Exit Condition",
      "type": "n8n-nodes-base.function",
      "position": [1450, 300]
    },
    {
      "parameters": {
        "conditions": {
          "boolean": [
            {
              "value1": "={{ $json.should_exit }}",
              "value2": true
            }
          ]
        }
      },
      "name": "Should Exit?",
      "type": "n8n-nodes-base.if",
      "position": [1650, 300]
    },
    {
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
        "specifyBody": "json",
        "jsonBody": "={\n  \"model\": \"claude-sonnet-4.5\",\n  \"max_tokens\": 8192,\n  \"system\": {{ $node['Load Synthesizer Persona'].json.data }},\n  \"messages\": [{\n    \"role\": \"user\",\n    \"content\": \"Create a vision document with these sections: Executive Summary, Vision Statement, Key Themes, Opportunities, Constraints, Next Steps.\\n\\nConversation:\\n{{ JSON.stringify($json.conversation_history) }}\"\n  }]\n}"
      },
      "name": "Synthesize Vision",
      "type": "n8n-nodes-base.httpRequest",
      "position": [1850, 200]
    },
    {
      "parameters": {
        "fileName": "=/workspace/automaton-projects/{{ $json.project_name }}/.thursian/visions/vision-v1.md",
        "data": "={{ $json.content[0].text }}"
      },
      "name": "Save Vision Document",
      "type": "n8n-nodes-base.writeFile",
      "position": [2050, 200]
    },
    {
      "parameters": {
        "fileName": "=/workspace/automaton-projects/{{ $json.project_name }}/.thursian/conversations/ideation-full.md",
        "data": "=# Ideation Conversation\\n\\nProject: {{ $json.project_name }}\\nRounds: {{ $json.current_round }}\\nExit Reason: {{ $json.exit_reason }}\\n\\n{{ JSON.stringify($json.conversation_history, null, 2) }}"
      },
      "name": "Save Conversation Log",
      "type": "n8n-nodes-base.writeFile",
      "position": [2050, 300]
    },
    {
      "parameters": {
        "respondWith": "json",
        "responseBody": "={\n  \"status\": \"completed\",\n  \"phase\": \"phase_1_ideation\",\n  \"artifacts\": {\n    \"vision_document\": \"/workspace/automaton-projects/{{ $json.project_name }}/.thursian/visions/vision-v1.md\",\n    \"conversation_log\": \"/workspace/automaton-projects/{{ $json.project_name }}/.thursian/conversations/ideation-full.md\"\n  },\n  \"next_phase\": \"phase_2_focus_group\",\n  \"rounds_completed\": {{ $json.current_round }},\n  \"exit_reason\": \"{{ $json.exit_reason }}\",\n  \"execution_time_ms\": {{ $now.diff($json.start_time) }}\n}"
      },
      "name": "Success Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "position": [2250, 250]
    }
  ],
  "connections": {
    "Webhook Trigger": {
      "main": [[{ "node": "Initialize Session", "type": "main", "index": 0 }]]
    },
    "Initialize Session": {
      "main": [
        [
          { "node": "Load Dreamer Persona", "type": "main", "index": 0 },
          { "node": "Load Doer Persona", "type": "main", "index": 0 },
          { "node": "Load Synthesizer Persona", "type": "main", "index": 0 }
        ]
      ]
    },
    "Load Doer Persona": {
      "main": [[{ "node": "Dialectic Round Loop", "type": "main", "index": 0 }]]
    },
    "Dialectic Round Loop": {
      "main": [
        [{ "node": "Dreamer Responds", "type": "main", "index": 0 }],
        [{ "node": "Check Exit Condition", "type": "main", "index": 0 }]
      ]
    },
    "Dreamer Responds": {
      "main": [[{ "node": "Doer Responds", "type": "main", "index": 0 }]]
    },
    "Doer Responds": {
      "main": [[{ "node": "Dialectic Round Loop", "type": "main", "index": 0 }]]
    },
    "Check Exit Condition": {
      "main": [[{ "node": "Should Exit?", "type": "main", "index": 0 }]]
    },
    "Should Exit?": {
      "main": [
        [{ "node": "Synthesize Vision", "type": "main", "index": 0 }],
        [{ "node": "Dialectic Round Loop", "type": "main", "index": 0 }]
      ]
    },
    "Synthesize Vision": {
      "main": [
        [
          { "node": "Save Vision Document", "type": "main", "index": 0 },
          { "node": "Save Conversation Log", "type": "main", "index": 0 }
        ]
      ]
    },
    "Save Conversation Log": {
      "main": [[{ "node": "Success Response", "type": "main", "index": 0 }]]
    }
  }
}
