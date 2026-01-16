# Docker MCP Custom Catalog Debugging Summary

**Date:** 2026-01-16
**Status:** Issue Identified & Workaround Verified

## Issue Description
A custom MCP server definition imported via a local YAML catalog (`custom-mcps.yaml`) was successfully enabled, but:
1.  The server **description** was missing from `docker mcp server ls` and the Docker Desktop UI.
2.  The server **tools** were not exposed to clients or visible in `docker mcp server inspect`.

## Findings

### 1. Description Visibility
*   **Root Cause:** There appears to be a limitation or bug in how the Docker MCP CLI processes metadata (specifically the `description` field) from **custom imported catalogs**.
*   **Verification:**
    *   When imported via `custom-mcps.yaml`, the description was empty in the server list.
    *   When the **exact same YAML entry** was appended to the default `docker-mcp.yaml` file, the description appeared correctly.

### 2. Tool Exposure
*   **Requirement:** The `toolsUrl` field is strictly required for tools to be inspecting/exposed before connection.
*   **Protocol Limitation:** The Windows `docker.exe` client (running via WSL bridge) **rejected** `file:///` protocols for the `toolsUrl` and `readme` fields.
*   **Success Path:** Hosting the `tools.json` and `readme.md` files on a standard HTTP server (verified using a local Nginx container) allowed the tools to be correctly loaded and inspected.

## Actions to Fix

To fully resolve the issue and ensure a stable development environment:

1.  **Host Metadata on HTTP**:
    *   Place `tools.json` and `readme.md` on a consistently accessible HTTP endpoint (e.g., GitHub Pages, Gist, or a dedicated local service).
    *   Update the `toolsUrl` and `readme` fields in your YAML definition to point to these HTTP URLs.

2.  **Catalog Strategy**:
    *   **Recommended (Stable):** Append your custom server definition directly to the default `docker-mcp.yaml` located at:
        `%USERPROFILE%\.docker\mcp\catalogs\docker-mcp.yaml`
    *   **Alternative (Dev):** Continue using `custom-mcps.yaml` but be aware that the description might remain invisible in the UI, even though the server functionality (once tools are properly exposed via HTTP) should work.

## Verified Configuration Example

```yaml
  mcp-github-agentic:
    description: "Agentic GitHub operations."
    title: MCP GitHub Agentic
    type: server
    dateAdded: "2026-01-16T12:00:00Z"
    image: oven/bun:alpine
    ref: ""
    # MUST be HTTP/HTTPS, file:/// is not supported by the client
    readme: "http://your-host:8080/readme.md"
    toolsUrl: "http://your-host:8080/tools.json"
    tools:
      - name: repository_management
    prompts: 0
    resources: {}
    metadata:
      pulls: 0
      stars: 0
      githubStars: 0
      category: development
      tags:
        - github
        - agentic
        - mcp
      license: "MIT"
      owner: chilledether
```
