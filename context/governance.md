# AI Agent Governance & Interaction Modes

This document defines the operating protocols for AI Agents interacting with this project. AI Agents **MUST** adhere to these modes to ensure deep requirement understanding change safety.

---

## 1. Approval Mode (Default)

**Status:** ✅ **ACTIVE BY DEFAULT**

In this mode, the AI Agent prioritizes **Requirement Gathering** and **Planning** over speed. No significant changes are executed without explicit user confirmation.

### Workflow
1.  **Requirement Gathering:**
    - Ask clarifying questions until the goal is 100% clear.
    - Do not assume intent.
2.  **Plan Formulation:**
    - Propose a detailed plan (files to touch, commands to run).
    - Explain *why* this approach was chosen.
3.  **Approval Request:**
    - "Do you approve this plan?"
4.  **Execution:**
    - Only proceed after user says "Yes/Proceed".

---

## 2. Auto Pilot Mode

**Status:** ⏸️ **Requires Explicit Activation**

Use this mode only when the user explicitly requests "Auto Pilot" or "Fast Mode".

### A. Recommended Profile (Default for Auto Pilot)

Balanced efficiency. The AI automates obvious steps but pauses for decisions.

- **Plan:** Still required, but can be brief.
- **Execution:**
    - **Explicit/Safe Actions:** Auto-execute (e.g., `ls`, `cat`, reading files, safe installs).
    - **Ambiguous/Risky Actions:** STOP and ASK (e.g., overwriting custom configs, choosing between rival packages).
- **Safety Net:** If a command fails or result is unexpected, STOP and report.

### B. Aggressive Profile

Maximum autonomy. The AI takes optimal calculated risks.

- **Activation Requirement:**
    - User must explicitly request "Aggressive" profile.
    - AI **MUST** provide a **Risk Warning** before enabling.
    - AI **MUST** get explicit User Consent ("I accept the risks").
- **Workflow:**
    - **Multiple Options:** AI chooses the *best technical decision* automatically without asking.
    - **Execution:** Auto-executes almost everything.
- **Compliance:**
    - **Header:** Every response must start with: `⚠️ [AUTO PILOT: AGGRESSIVE MODE]`
    - **Logging:** Briefly explain key decisions made autonomously.

---

## Mode Switching

| From | To | Trigger |
|------|----|---------|
| Any | **Approval** | Default start, or User says "Stop/Wait", "Let's plan" |
| Approval | **Auto Pilot** | User says "Auto pilot", "Go ahead", "Do it" |
| Auto Pilot | **Aggressive** | User says "Aggressive mode" → AI Warnings → User "Yes" |

---

## Quick Reference for Agents

| Mode | Planning | Execution | Decision Making |
|------|----------|-----------|-----------------|
| **Approval** | **Deep** | Ask First | User Decides |
| **Rec. Auto Pilot** | Brief | Local/Safe=Auto | User Decides Ambiguity |
| **Aggressive AP** | Minimal | **Auto** | **AI Decides** |
