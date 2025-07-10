# RVToolsExplorer

Author: Anthony Chambet  
Date: July 2025

## Description

`RVToolsExplorer.sh` is a Bash script designed to extract and summarize key compute and inventory metrics from RVTools exports. It helps generate a structured overview of a VMware vSphere environment, useful for quick sizing, technical assessment, and planning activities.

The script operates on `.csv` files exported from RVTools and generates summaries in categories such as compute provisioning, physical host inventory, VM configuration, guest OS distribution, and resource density ratios.

## Requirements

- Unix-like environment (macOS, Linux, WSL)
- Bash 4.x or higher
- RVTools exported as `.csv` files (semicolon `;` separated)

## Input Preparation

1. Export the RVTools `.xlsx` workbook from the customer environment.
2. Open the Excel file and export each sheet as a **separate `.csv` file**, using **semicolon (;)** as the delimiter.
3. Place all `.csv` files in a single working directory alongside the script.

Required files typically include:

- `vInfo.csv`
- `vHost.csv`
- `vCluster.csv`
- `vSnapshot.csv`
- `vDatastore.csv`
- `vTools.csv`

## Installation

Clone the repository or copy the script to your local machine.
Chmod it and you know..

## Roadmap

The following roadmap outlines planned technical evolutions, driven by practical usage at scale, maintainability, and operational constraints typically encountered in enterprise infrastructure assessment and migration projects.

### 1. Input Handling & Validation

**Problem:**  
RVTools exports are manually created and prone to formatting errors — wrong delimiters, renamed headers, partial exports.

**Planned improvements:**

- Add robust input validation layer: file presence, header integrity, delimiter enforcement (`LC_ALL=C`, field detection via `awk -F";"`).
- Heuristics to detect corrupt or incomplete data, with meaningful warnings.
- Auto-detection of `UTF-8` vs `Windows-1252` encoding inconsistencies.

**Outcome:**  
Improves script robustness when used by multiple people in various environments (pre-sales, delivery, operations).

---

### 2. Output Format Modularization

**Problem:**  
The current output is CLI-only and non-exportable. Engineers often need structured outputs for reports, slides, or automation.

**Planned improvements:**

- Abstract current logic into `awk` processing modules that can switch between:
  - Human-readable text (default)
  - JSON (for pipelines)
  - Markdown (for internal reporting)
  - CSV (for Excel reimport)
- Use `tee` and `>>` to log results to a versioned `output/` directory.

**Outcome:**  
Better integration with existing tooling (Excel, Notion, SharePoint, Confluence, GitLab reports).

---

### 3. Interactive Usage (Optional Mode)

**Problem:**  
Not all users are comfortable with CLI parameters or file layout assumptions.

**Planned improvements:**

- Add interactive CLI mode (basic TUI or dialog-based)
- Prompt user for `.csv` location, validate structure, confirm parsing results before execution
- Preset profiles (e.g., “Pre-sales Quick View”, “Delivery Deep Dive”) to toggle section-level output

**Outcome:**  
Reduces onboarding friction, improves usage across non-technical teams or pre-sales engineers.

---

### 4. Containerized Execution Environment

**Problem:**  
Script has minor dependency on consistent Bash/Awk behavior. Execution may differ across macOS, Linux, or WSL environments (especially field splitting, numeric formats).

**Planned improvements:**

- Provide a minimal Alpine/Debian-based Docker image with all CSV logic embedded
- Mount the working directory and run in isolated, reproducible environment
- Include shell and optional TUI inside container for exploratory workflows

**Outcome:**  
Guaranteed consistency, usable from any OS, easy to deploy as a standalone analysis tool in CI or controlled environments.

---

### 5. Cross-Site Aggregation Logic

**Problem:**  
Analysis is currently per-site, while real-world migration or consolidation requires global views across multiple RVTools exports.

**Planned improvements:**

- Accept batch mode with input directories for each site
- Normalize metrics (per-core, per-TB, per-VM) across sites
- Generate aggregated summary with site-by-site deltas
- Detect common inefficiencies (e.g., VMs with identical roles across sites, OS version drift, capacity fragmentation)

**Outcome:**  
Enables multi-datacenter consolidation scenarios and regional/global sizing proposals.

---

### 6. CI Integration for Data Integrity & Pre-checks

**Problem:**  
Data quality is often only validated after analysis, delaying sizing work.

**Planned improvements:**

- Make the script executable in CI (e.g., GitLab Runner with mounted RVTools folder)
- Run pre-check jobs: file integrity, delimiter check, host/VM count parity, schema drift
- Return fail/pass status or early warnings

**Outcome:**  
Shifts validation left, enabling early detection of incomplete or corrupted customer exports.

---

### 7. Extended Metric Coverage (Planned Modules)

**Problem:**  
Additional context is often required for sizing or technical recommendations, not covered in vInfo alone.

**Planned additions:**

- Snapshot age and size analysis (from `vSnapshot.csv`)
- Guest uptime / VM creation date (if data available)
- Disk thin vs thick provisioning ratio
- Host-to-cluster imbalance (e.g., memory skew, NUMA issues)
- OS end-of-support detection via mapping (RHEL6, Win2008, etc.)

**Outcome:**  
Increases the script’s utility in delivering actionable technical insights, not just raw inventory data.

---

### 8. Export to Reporting Format (Optional)

**Planned:**  
Optional module to convert output to `.xlsx` or `.docx` via `pandoc`, `csvkit`, or other automation tools.  

**Rationale:**  
Allows sales engineers or delivery architects to build repeatable customer deliverables with minimal formatting effort.

---

### General Design Principles

- **No external dependencies.** Bash/Awk-based by default.
- **Reproducibility.** Execution should be deterministic across environments.
- **Fail-safe logic.** No parsing should silently skip malformed fields.
- **Clear separation.** Logic vs presentation vs post-processing layers.
- **Composable.** Ability to integrate into a larger toolchain later (Ansible, Terraform, or internal sizing portals).

