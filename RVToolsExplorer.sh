#!/bin/bash
# RVToolsExplorer.sh
#
# Author: Anthony Chambet - Solution Architect
# Created: July 10th 2025
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
#
# ==============================================================================

set -euo pipefail

# === Input CSV files ===
VCPU="vCPU-Tableau 1.csv"
VMEM="vMemory-Tableau 1.csv"
VINFO="vInfo-Tableau 1.csv"
VDATASTORE="vDatastore-Tableau 1.csv"
VHOST="vHost-Tableau 1.csv"
VPART="vPartition-Tableau 1.csv"
VTOOLS="vTools-Tableau 1.csv"
VDISK="vDisk-Tableau 1.csv"

# === Validate required files ===
for file in "$VCPU" "$VMEM" "$VINFO" "$VDATASTORE" "$VHOST" "$VPART" "$VTOOLS" "$VDISK"; do
    [[ ! -f "$file" ]] && echo "Missing file: $file" && exit 1
done

echo "===== RVTools Compute Summary ====="

vcpus=$(LC_ALL=C awk -F";" 'NR > 1 && $5 ~ /^[0-9]/ {gsub("[^0-9]", "", $5); sum += $5} END {print sum}' "$VCPU")
ram=$(LC_ALL=C awk -F";" 'NR > 1 && $5 ~ /^[0-9]/ {gsub("[^0-9]", "", $5); sum += $5} END {printf "%.0f", sum / 1024}' "$VMEM")
disk=$(LC_ALL=C awk -F";" 'NR > 1 && $7 ~ /^[0-9]/ {gsub("[^0-9]", "", $7); sum += $7} END {print int(sum / 1024)}' "$VPART")

echo "Total vCPUs provisioned: $vcpus"
echo "Total RAM provisioned (GiB): $ram"
echo "Total VM disk provisioned (GiB): $disk"

read ds_total ds_free <<< $(LC_ALL=C awk -F";" 'NR > 1 {
    gsub("[^0-9]", "", $8); total += $8
    gsub("[^0-9]", "", $11); free += $11
} END {
    printf "%d %d", total / 1024, free / 1024
}' "$VDATASTORE" || echo "0 0")
if [[ "$ds_total" == "0" && "$ds_free" == "0" ]]; then
    echo "Warning: error parsing $VDATASTORE"
fi
echo "Total datastore capacity (GiB): $ds_total"
echo "Total datastore free space (GiB): $ds_free"

echo ""
echo "===== Physical Host Overview ====="
LC_ALL=C awk -F";" 'NR > 1 {
    cpu = $13
    cores = $14
    ram = $28
    gsub("[^0-9]", "", ram)
    printf "- %s: %s CPUs, %s Cores, %d GiB RAM\n", $1, cpu, cores, ram / 1024
}' "$VHOST"

echo ""
echo "===== Host Resources ====="
total_cores=$(LC_ALL=C awk -F";" 'NR > 1 && $14 ~ /^[0-9]/ {sum += $14} END {print sum}' "$VHOST")
total_ram_phys=$(LC_ALL=C awk -F";" 'NR > 1 && $28 ~ /^[0-9]/ {gsub("[^0-9]", "", $28); sum += $28} END {print int(sum / 1024)}' "$VHOST")
echo "Total physical cores: $total_cores"
echo "Total physical RAM (GiB): $total_ram_phys"
printf "vCPU/pCPU ratio: %.2f
" "$(awk -v v="$vcpus" -v c="$total_cores" 'BEGIN {print v / c}')"

echo ""
echo "===== VM Inventory Summary ====="
total_vms=$(awk -F";" 'NR > 1 && $2 != "" {count++} END {print count+0}' "$VINFO")
powered_on=$(awk -F";" 'NR > 1 && tolower($2) ~ /on/ {n++} END {print n+0}' "$VINFO")
powered_off=$(awk -F";" 'NR > 1 && tolower($2) ~ /off/ {n++} END {print n+0}' "$VINFO")
echo "Total VMs: $total_vms"
echo "Powered On VMs: $powered_on"
echo "Powered Off VMs: $powered_off"

outdated=$(awk -F";" 'NR > 1 && $6 !~ /current/i {n++} END {print n+0}' "$VTOOLS")
echo "VMs with outdated VMware Tools: $outdated"

thin=$(awk -F";" 'NR > 1 && tolower($7) == "true" {n++} END {print n+0}' "$VDISK")
thick=$(awk -F";" 'NR > 1 && tolower($7) == "false" {n++} END {print n+0}' "$VDISK")
echo "Thin-provisioned disks: $thin"
echo "Thick-provisioned disks: $thick"

echo "VM hardware versions:"
awk -F";" 'NR > 1 && $68 != "" {v[$68]++} END {for (h in v) printf "  VMX %s: %d\n", h, v[h]}' "$VINFO"

LC_ALL=C awk -F";" 'NR > 1 {
    val1 = $5; gsub("[^0-9]", "", val1); prov += val1
    val2 = $9; gsub("[^0-9]", "", val2); used += val2
} END {
    printf "RAM provisioned (GiB): %.0f\n", prov / 1024
    printf "RAM consumed (GiB): %.0f\n", used / 1024
    printf "RAM overcommit ratio: %.2f\n", prov / used
}' "$VMEM"

echo ""
echo "===== VM Count per OS (VMware Tools) ====="
awk -F";" 'NR > 1 && $82 != "" { os[$82]++ }
END {
    for (o in os) {
        printf "%4d  %s\n", os[o], o
    }
}' "$VINFO" | sort -nr

echo ""

echo "===== VM Distribution by Cluster ====="
# Initialize cluster VM count
vm_count_in_clusters=0
awk -F";" 'NR > 1 && $79 != "" { cluster[$79]++ }
END {
    for (c in cluster) {
        printf "%4d  %s\n", cluster[c], c
    }
}' "$VINFO" | sort -nr | tee /tmp/cluster_count.tmp
# Calculate the sum of VMs from cluster distribution
vm_count_in_clusters=$(awk '{sum += $1} END {print sum}' /tmp/cluster_count.tmp)
rm /tmp/cluster_count.tmp
echo "Cluster assignment checksum: $vm_count_in_clusters VMs assigned to clusters out of $total_vms total VMs"
if [ "$vm_count_in_clusters" -eq "$total_vms" ]; then
    echo "Result: VM-to-cluster mapping is consistent."
else
    echo "Warning: Discrepancy detected in VM-to-cluster mapping. Some VMs may lack cluster association."
fi

echo ""
echo "===== Ratios & Density Metrics ====="
printf "Average vCPUs per VM: %.2f
" "$(awk -v v="$vcpus" -v t="$total_vms" 'BEGIN {print v / t}')"
printf "Average RAM per VM (GiB): %.2f
" "$(awk -v r="$ram" -v t="$total_vms" 'BEGIN {print r / t}')"
printf "RAM per vCPU (GiB): %.2f
" "$(awk -v r="$ram" -v v="$vcpus" 'BEGIN {print r / v}')"
printf "VMs per physical core: %.2f
" "$(awk -v vm="$total_vms" -v core="$total_cores" 'BEGIN {print vm / core}')"
printf "RAM provisioned per physical core (GiB): %.2f
" "$(awk -v r="$ram" -v core="$total_cores" 'BEGIN {print r / core}')"
printf "Average disk per VM (GiB): %.1f
" "$(awk -v d="$disk" -v t="$total_vms" 'BEGIN {print d / t}')"
printf "Datastore usage: %.1f%%
" "$(awk -v t="$ds_total" -v f="$ds_free" 'BEGIN {print 100 * (t - f) / t}')"
