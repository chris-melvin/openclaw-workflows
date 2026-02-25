# OpenClaw Workflows

A collection of presentations, documentation, and examples for building AI-powered workflows with OpenClaw on AWS EC2.

## 📚 Table of Contents

### Presentations

| File | Description | Audience |
|------|-------------|----------|
| [`openclaw-learning-mis.html`](presentations/openclaw-learning-mis.html) | Learning automation (Notion + cron) and MIS for non-technical teams | Mixed technical/non-technical |
| [`openclaw-ec2-kimi-linear.html`](presentations/openclaw-ec2-kimi-linear.html) | Deep dive into EC2 + Kimi + Linear setup for tech teams | Technical (developers, DevOps) |

### Documentation

| Topic | Description |
|-------|-------------|
| [Architecture Overview](#architecture-overview) | High-level system design |
| [Setup Guide](#setup-guide) | Step-by-step installation instructions |
| [Workflow Examples](#workflow-examples) | Real-world automation examples |
| [Cost Analysis](#cost-analysis) | Monthly cost breakdown |

### Examples

| Example | Description |
|---------|-------------|
| Daily Learning System | 8-subject rotation with Notion tracking |
| Linear Standup Reporter | Automated daily standup summaries |
| SWE Learning Bot | Software engineering topics delivered daily |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS EC2 (t3.medium)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   OpenClaw   │  │    Cron      │  │    PM2       │           │
│  │   Gateway    │──│   Scheduler  │──│  Process Mgr │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────────────────────────────────┐                   │
│  │           Kimi API (K2.5)                │                   │
│  │    - 200K context window                 │                   │
│  │    - Coding-optimized                    │                   │
│  │    - Cost-effective                      │                   │
│  └─────────────────────────────────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌──────────┐         ┌──────────┐
   │ Telegram│          │  Notion  │         │  Linear  │
   │ (Chat)  │          │(Knowledge│         │(Project  │
   └─────────┘          │   Base)  │         │  Mgmt)   │
                        └──────────┘         └──────────┘
```

## Setup Guide

### 1. Infrastructure (EC2)

```bash
# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-0c8d3c6b \
  --instance-type t3.medium \
  --key-name my-key \
  --security-group-ids sg-xxxxx

# Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install OpenClaw
npm install -g openclaw
```

### 2. Configure OpenClaw

```bash
# Initialize config
openclaw config init

# Edit ~/.config/openclaw/config.json
{
  "models": {
    "default": "kimi-coding/k2p5",
    "providers": {
      "kimi-coding": {
        "apiKey": "${KIMI_API_KEY}",
        "baseUrl": "https://api.moonshot.cn/v1"
      }
    }
  }
}
```

### 3. Set Up Process Manager

```bash
# Install PM2
npm install -g pm2

# Start OpenClaw
pm2 start "openclaw gateway" --name openclaw
pm2 save
pm2 startup
```

### 4. Configure Integrations

**Telegram Bot:**
- Create bot via @BotFather
- Add token to OpenClaw config

**Notion:**
- Create integration at notion.so/my-integrations
- Share databases with integration
- Add token to `TOOLS.md`

**Linear:**
- Generate API key at linear.app/settings/api
- Store in environment: `export LINEAR_API_KEY="lin_api_xxxxx"`

## Workflow Examples

### Daily Learning System

**What it does:**
- Rotates through 8 subjects (Calculus → Spanish → System Design → ...)
- Generates lesson + quiz daily at 6 PM
- Updates Notion schedule database
- Sends Telegram reminder

**Cron schedule:**
```json
{
  "name": "Daily Learning Session",
  "schedule": { "kind": "cron", "expr": "0 18 * * *", "tz": "Asia/Manila" },
  "payload": { "kind": "agentTurn", "message": "Run daily learning session" }
}
```

### Linear Standup Reporter

**What it does:**
- Fetches issues updated in last 24h
- Generates summary per team member
- Posts formatted report to Telegram at 9 AM

**Key GraphQL query:**
```graphql
query {
  issues(filter: { team: { name: { eq: "ENG" } }, updatedAt: { gt: "24h" } }) {
    nodes {
      id
      title
      state { name }
      assignee { name }
      updatedAt
    }
  }
}
```

### SWE Learning Bot

**What it does:**
- Delivers software engineering topics daily at 8 AM
- Covers architecture, patterns, testing, DevOps
- Examples: CDCT, Feature Flags, Load Balancing

## Cost Analysis

| Component | Monthly Cost |
|-----------|--------------|
| EC2 t3.medium (on-demand) | ~$30 |
| EC2 t3.medium (reserved) | ~$18 |
| Kimi API (moderate usage) | ~$5-20 |
| Linear (free tier) | $0 |
| Telegram | $0 |
| **Total** | **~$25-50/month** |

## Repository Structure

```
openclaw-workflows/
├── presentations/
│   ├── openclaw-learning-mis.html      # Learning + MIS presentation
│   └── openclaw-ec2-kimi-linear.html   # Technical setup presentation
├── docs/
│   └── (additional documentation)
├── examples/
│   └── (workflow configuration examples)
└── README.md                           # This file
```

## Presenting These Slides

Both HTML presentations are self-contained and work offline:

1. **Open in browser:**
   ```bash
   open presentations/openclaw-ec2-kimi-linear.html
   ```

2. **Navigation:**
   - `← / →` or click to navigate
   - `F` for fullscreen
   - `P` to print to PDF

3. **Mobile/touch:**
   - Swipe left/right to navigate

## Key Features Demonstrated

### What Makes This Different from ChatGPT/Claude Web

| Feature | Chat Interface | OpenClaw Setup |
|---------|---------------|----------------|
| Scheduled execution | ❌ | ✅ Cron jobs |
| File system access | ❌ | ✅ Full access |
| API integrations | ❌ | ✅ Notion, Linear, Telegram |
| Persistent memory | ❌ | ✅ Files + databases |
| Long-running workflows | ❌ | ✅ Background jobs |
| Cost control | ❌ | ✅ Predictable EC2 + API costs |

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Kimi API Documentation](https://platform.moonshot.cn)
- [Linear API Documentation](https://developers.linear.com)

## License

MIT - Feel free to use these presentations and examples for your own teams.

---

**Questions?** Open an issue or reach out on Telegram.
