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

Clone the repository or copy the script to your local machine:

```bash
git clone https://github.com/your-org/RVToolsExplorer.git
cd RVToolsExplorer
