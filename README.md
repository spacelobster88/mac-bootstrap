# Auspex

**One who reads the signs and prepares the ground. Bootstrap a fresh Mac with your AI service stack.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue.svg)]()
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M1%2B-black.svg)]()

Auspex transforms a bare Mac — Mini, MacBook, or Studio — into a fully operational AI service hub. It installs dependencies, clones projects, configures secrets, and starts persistent services, all in three phases.

> *In ancient Rome, the auspex read the signs before any great endeavor. Auspex reads your Mac and prepares the ground for deploying [Centurion](https://github.com/spacelobster88/centurion) fleets.*

## ⚠️ Disclaimer

**This script installs system-level software, modifies LaunchAgents configuration, and writes files to your HOME directory.**

Risks include but are not limited to:
- System configuration changes
- Conflicts with existing software
- High resource usage from runaway services
- Security issues from misconfigured keys/tokens

**Any system damage, data loss, service disruption, or security incidents caused by using these scripts are entirely the user's responsibility. The developer assumes no liability whatsoever.**

Read each script carefully before running. Make sure you understand every step.

---

## Hardware Requirements

| Item | Minimum | Recommended |
|------|---------|-------------|
| Chip | Apple Silicon (M1+) | M2 / M4 |
| RAM | 16 GB | 32 GB+ (each Claude agent uses ~250 MB) |
| Disk | 30 GB free | 100 GB+ (Ollama models, brew packages, project code) |
| macOS | 14.0 (Sonoma)+ | Latest |
| Mac type | Mac Mini, MacBook, Mac Studio, Mac Pro | Any Apple Silicon Mac |

## What Gets Deployed

```
┌─────────────────────────────────────────────────────┐
│                    Your Mac                           │
│                                                      │
│  Ollama (11434)          ← Vector embeddings         │
│    └─▶ mini-claude-bot (8000)  ← Claude gateway      │
│          └─▶ telegram-claude-hero  ← Telegram bridge  │
│                                                      │
│  Centurion (8100)        ← Agent fleet orchestrator  │
│                                                      │
│  Harness Loop (.harness/) ← Project orchestrator     │
└─────────────────────────────────────────────────────┘
```

| Service | Stack | Port | Description |
|---------|-------|------|-------------|
| Ollama | Homebrew | 11434 | nomic-embed-text model, provides vector embeddings for mini-claude-bot |
| mini-claude-bot | Python 3.13 / FastAPI | 8000 | Multi-session Claude gateway, cron scheduling, semantic memory, daily reports |
| telegram-claude-hero | Go 1.25 | - | Telegram Bot bridge, forwards messages to mini-claude-bot |
| centurion | Python 3.12+ / FastAPI | 8100 | AI Agent orchestration engine, manages multiple Claude CLI processes |

## Usage

### Phase 0: Manual Prerequisites

These steps cannot be automated and must be done before running scripts:

1. **macOS permissions** (System Settings → Privacy & Security):
   - Grant Terminal.app or iTerm2: **Accessibility**
   - Grant Terminal.app or iTerm2: **Full Disk Access**
   - Grant Terminal.app or iTerm2: **Automation**

2. **Have the following ready**:
   - GitHub account (for cloning private repos)
   - Telegram Bot Token (from [@BotFather](https://t.me/BotFather))
   - Anthropic account (for Claude CLI login)

### Phase 1: Install System Dependencies

```bash
git clone https://github.com/spacelobster88/auspex.git
cd auspex
chmod +x *.sh
./install.sh
```

Installs: Homebrew, Python, Go, Node.js, Ollama, Claude CLI, tectonic (LaTeX), GitHub CLI.

### Phase 2: Clone Projects + Configure + Start Services

```bash
# Complete GitHub and Claude login first
gh auth login
claude login

# Then run
./setup.sh
```

The script will interactively guide you to:
- Clone 3 project repos
- Build each project (Python venv, Go build)
- Enter Telegram Bot Token and other secrets
- Install and start 4 LaunchAgent services

### Phase 3: Verify

```bash
./health-check.sh
```

Verifies all services are running correctly.

### Uninstall

```bash
./uninstall.sh
```

Stops all services and removes LaunchAgent configurations.

## Directory Structure

```
auspex/
├── README.md                 # This document
├── LICENSE                   # MIT
├── install.sh                # Phase 1: System dependencies
├── setup.sh                  # Phase 2: Project config + service startup
├── health-check.sh           # Phase 3: Service verification
├── uninstall.sh              # Teardown
├── Brewfile                  # Homebrew dependency manifest
├── launchd/                  # LaunchAgent plist templates
│   ├── com.eddie.ollama.plist.template
│   ├── com.eddie.mini-claude-bot.plist.template
│   ├── com.eddie.telegram-claude-hero.plist.template
│   └── com.eddie.centurion.plist.template
└── env/                      # Environment variable templates
    ├── mini-claude-bot.env.example
    └── centurion.env.example
```

## Part of the Centurion Ecosystem

Auspex is the setup tool for the broader AI agent stack:

| Project | Role | Link |
|---------|------|------|
| **Auspex** | Mac provisioning (you are here) | [GitHub](https://github.com/spacelobster88/auspex) |
| **Centurion** | Fleet-level agent orchestration (100+ agents) | [GitHub](https://github.com/spacelobster88/centurion) |
| **mini-claude-bot** | Claude gateway + memory + cron | [GitHub](https://github.com/spacelobster88/mini-claude-bot) |
| **telegram-claude-hero** | Telegram bot bridge | [GitHub](https://github.com/spacelobster88/telegram-claude-hero) |

## Manual Steps Checklist

The following require browser interaction or manual configuration. Scripts will prompt at the appropriate time:

| Step | Command / Action | Notes |
|------|-----------------|-------|
| GitHub login | `gh auth login` | Required for cloning private repos |
| Claude login | `claude login` | Requires Anthropic account, browser interaction |
| macOS permissions | System Settings → Privacy & Security | Terminal/iTerm2 needs Accessibility + Full Disk Access + Automation |
| Telegram Token | @BotFather | setup.sh will prompt for input |
| Gmail App Password | Google Account settings | Only needed for daily report emails |

## Data Migration (Optional)

If migrating from an old machine, copy the following:

```bash
# Chat history + memory database
scp old-mac:~/Projects/mini-claude-bot/data/mini-claude-bot.db \
    ~/Projects/mini-claude-bot/data/

# Telegram config (contains bot token)
scp old-mac:~/.telegram-claude-hero.json ~/

# Claude config
scp -r old-mac:~/.claude/ ~/
```

## License

MIT
