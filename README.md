# rvtoolsexplorer

**author**: anthony chambet  
**date**: july 2025  

## overview

`rvtoolsexplorer.sh` is a bash utility for extracting and summarizing compute and inventory metrics from rvtools exports.  
it produces a structured view of vmware vsphere environments, useful for sizing exercises, technical assessments, and planning activities.  

the script consumes `.csv` files exported from rvtools and generates summaries across areas such as host inventory, vm configuration, guest os distribution, snapshots, and resource utilization ratios.  

---

## requirements

- unix-like environment (macos, linux, wsl)  
- bash 4.x or higher  
- rvtools export in `.csv` format (semicolon `;` separated)  

---

## preparing input

1. export the rvtools workbook (`.xlsx`) from the target environment.  
2. save each worksheet as a separate **semicolon-delimited `.csv` file**.  
3. place all `.csv` files in the same working directory as the script.  

commonly required files:  
- `vinfo.csv`  
- `vhost.csv`  
- `vcluster.csv`  
- `vsnapshot.csv`  
- `vdatastore.csv`  
- `vtools.csv`  

---

## usage

```bash
chmod +x rvtoolsexplorer.sh
./rvtoolsexplorer.sh <path_to_csv_directory>
```

output is printed to standard output and can be redirected or logged.  

---

## roadmap

planned improvements to address issues encountered in enterprise usage:  

### input validation
- check file presence, header consistency, and delimiter format  
- detect encoding mismatches (utf-8 vs windows-1252)  
- provide clear warnings on incomplete or corrupted data  

### output options
- modular output formats: human-readable text, json, markdown, csv  
- logging to a versioned `output/` directory  

### interactive mode
- optional guided mode for users less familiar with cli  
- profiles for quick analysis presets (e.g. pre-sales vs delivery)  

### containerization
- docker image for reproducible execution across platforms  
- self-contained runtime with bash/awk utilities included  

### multi-site aggregation
- accept multiple input sets for cross-site analysis  
- normalize metrics across datacenters and provide deltas  

### ci integration
- gitlab ci/runner support for pre-checks and data validation  
- early fail/pass status before deeper analysis  

### extended metrics
- snapshot age and size reporting  
- vm uptime and creation history  
- thin vs thick disk provisioning ratios  
- os lifecycle status (eos detection)  

### reporting export (optional)
- conversion to `.xlsx` or `.docx` for customer deliverables  
- integration with `pandoc` or similar tooling  

---

## design principles

- no external dependencies (bash/awk only by default)  
- deterministic results across environments  
- fail-safe parsing (no silent skips)  
- separation of logic, presentation, and post-processing  
- composability for integration into larger toolchains  
