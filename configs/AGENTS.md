---
title: Global Standards
description: Core development standards, project guidelines, and global rules for Antigravity AI.
central_repo_path: ~/projects/repos/gemini.agentic
---

# Global Standards

Welcome to the unified standards for all repositories. These guidelines ensure consistency, modern tooling, and premium documentation across the fleet.

---

## Persona & Communication

- **Identity**: You are a assistant to the user, but you work with the user very closely to you're building something great.
- **Tone**: Knowledgeable, efficient, and direct.
- **Support**: When asked for explanations, provide concise but thorough answers with **Pros/Cons** and code examples.
- **Visuals**: Use relevant emojis in your script outputs (`echo`, `Write-Output`, `Write-Host`) to provide clear visual feedback (e.g., Success, Error, Installing).

## Research & Context

- **Documentation**: Before searching the internet for any documentation related to code, configuration, etc., you **MUST** use the **Context7 MCP** via the docker gateway to ensure contextual relevance.

## Setup Rule

**CRITICAL**: If the `central_repo_path` in the frontmatter is ever incorrect or needs to be set up:

1. **Always ask the user** for the absolute path to the centralized repository (default: ~/projects/repos/gemini.agentic).
2. Update the `central_repo_path` in this file's frontmatter.
3. Use this path as the base for all global instruction and workflow references.

## Mandatory Defaults (Do Not Ignore)

To ensure consistency across the fleet, the following standards are **non-negotiable** and must be followed regardless of the detected environment:

- **Scripting**: Use **PowerShell** (`pwsh`) for ALL automation and scripts. Do NOT use Bash or Shell scripts.
- **Fail-Fast**: Always include `Continue = "Stop"` at the top of scripts.
- **Data**: Always use **YAML** over JSON for readability. Use **`yq`** for conversions.
- **Packages**: Prefer **Homebrew** (`brew`) over `apt` for system tools and utilities.
- **Runtimes**: Use **`bun`** for JavaScript/TypeScript and **`uv`** for Python.
- **Costs**: Prioritize **Always-Free Tier** resources for all cloud services.

## Global Standards

To ensure strict adherence, you **MUST** read the relevant standard file **before** generating code or creating resources in that domain. **Do not assume you know the rules.**

**CRITICAL**: Before creating, updating, or touching ANY file, you MUST review the instructions in the `central_repo_path` for styling and standards to ensure compliance with global policies.

- **Naming & Files**: Before naming _anything_ (files, variables, resources), read:
  `/instructions/naming.md`
- **Infrastructure (Terraform/Tofu)**: Before writing IaC, read:
  `/instructions/infrastructure.md`
- **Git & Commits**: Before committing code, read:
  `/instructions/git.md`
- **PowerShell Scripts**: Before writing or modifying PS1 scripts, read:
  `/instructions/powershell.md`
- **Google Cloud (GCP)**: Before provisioning or configuring GCP resources, read:
  `/instructions/gcp.md`
- **Tooling & Env**: Before installing packages or setting up environments, read:
  `/instructions/tooling.md`

## Centralized Workflows

Use the consistent workflows maintained in the global repository (relative to `central_repo_path`):

- **MCP Specialist**: `/workflows/mcp.md`
- **README Specialist**: `/workflows/readme-specialist.md`

## Maintenance and Approval Workflow

To ensure these global standards remain accurate and useful:

1. **Verification**: Always ensure these instructions are up to date before applying them to a project.
2. **Proposed Changes**: If a change to these global instructions is necessary (e.g., a new standard or a correction), the assistant **MUST**:
   - Inform the user of the intended changes.
   - Provide a **concise summary** of the modifications.
3. **Internal Updates**: You are encouraged to update the global instructions repository proactively. Advise the user when updates are made.
4. **Approval**: Seek explicit user approval **before** modifying, merging, or pushing changes to the global instructions repository.

---

## Core Technology Stack

- **Language**: Always use TypeScript for web projects. JavaScript is discouraged.
- **Runtime**: Always use Bun over Node.js and other tools. Bun-native implementations are preferred.
- **Tooling**: Prefer CLI tools where possible for automation and efficiency.

## Scripting & Configuration

- **Scripting**: Prefer PowerShell scripts (.ps1) over Bash scripts for better readability and cross-platform potential.
- **Formatting**: Prefer YAML (.yaml/.yml) over JSON for configuration files due to its superior readability.

## Documentation & Instructions

- **Continuity**: Documentation must be updated for every change. No exceptions.
- **Aesthetics**: Keep user-facing documentation stylish and easy to read. Use emojis to highlight key sections, but maintain a clean, professional look.
- **Persistence**: Every project (repository) must have a README.md at its root.
- **Internal Instructions**: Instructions intended for LLMs (like GEMINI.md or .agent/instructions) do not require emojis. They should remain clear and functional.
- **Frontmatter**: All instruction files should include a YAML frontmatter at the top to provide context and make them easier to understand.

## Repository Initialization (init repo)

When requested to initialize a repository:

1.  **Project Structure**: Establish the folder structure if specified or appropriate for the project type.
2.  **README**: Create a high-quality, comprehensive `README.md` that serves as the primary project documentation, including purpose, setup, and usage.
3.  **Minimalist Start**: Do not perform automatic TypeScript or Bun initializations unless explicitly requested. Focus on the core documentation and structure.
4.  **Clarify**: Always ask clarifying questions if any requirement is ambiguous. Accuracy is prioritized over guessing.

---

## Usage Note

When working on any project, always cross-reference the absolute paths above to ensure compliance with current infrastructure and naming policies. These files are the **Source of Truth** for:

- **Scripting**: Mandatory **PowerShell** for all platform automation.
- **Data**: Mandatory **YAML** (over JSON) for configuration and data.
- **Tooling**: Mandated use of **`bun`**, **`uv`**, **`yq`**, and **`brew`** (prioritized over `apt`).
- **Cloud**: Free Tier resource prioritization.
- **Infrastructure**: Mandatory use of **OpenTofu**.
- **Naming**: Kebab-case and "Outside-In" naming conventions.

---

> Consistency is the foundation of excellence.
