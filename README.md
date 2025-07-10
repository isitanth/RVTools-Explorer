# RVToolsExplorer.sh
#
# Author: Anthony Chambet
# Created: July 2025
#
# Description:
# This script analyzes RVTools exports (converted to .CSV format) to provide
# a quick and structured overview of compute, storage, and VM inventory metrics.
# It is designed to assist with initial sizing, assessment, and capacity planning.
#
# Usage:
#   1. Export RVTools Excel file to individual .CSV files (semicolon-separated).
#   2. Place this script in the root folder containing the .CSV files.
#   3. Run the script: ./RVToolsExplorer.sh
#
# Output includes:
#   - Compute summary
#   - Host-level hardware overview
#   - VM inventory breakdown
#   - OS and cluster distribution
#   - Density and ratio metrics
