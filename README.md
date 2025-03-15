# LazyScout - Automated Reconnaissance Tool

## Overview

**LazyScout** is a fully automated reconnaissance script designed for **penetration testers, bug bounty hunters, and security researchers**. It identifies subdomains, checks for live hosts, and extracts useful URLs from target domains. It provides categorized results for easy analysis.

## Features

✅ **Subdomain Enumeration** using `subfinder` (with optional `amass` support) ✅ **Live Host Detection** using `httpx` ✅ **Detailed HTTP Status Analysis** (200, 301/302, 401, 403 responses) ✅ **URL Extraction** from sources like `waybackurls`, `gau`, `katana`, and `gospider` ✅ **Categorized URLs** (JS, PHP, JSP, ASPX, admin-related, and parameterized URLs) ✅ **Execution Summary** including counts and elapsed time ✅ **Minimal Interaction Required** (fully automated!)

---

## Installation

To use LazyScout from anywhere in your terminal, move it to `/usr/local/bin/`:

```bash
chmod +x lazyscout.sh
sudo mv lazyscout.sh /usr/local/bin/lazyscout
```

---

## Usage

### **Basic Usage** (Single Domain)

```bash
lazyscout example.com
```

### **Multiple Domains from a File**

```bash
lazyscout domains.txt
```

*(The file should contain one domain per line.)*

### **Enable Amass for Subdomain Enumeration**

```bash
lazyscout -useamass example.com
```

### **Help Menu**

```bash
lazyscout -h
```

---

## Output Files

LazyScout stores results in the `lazyscout/` directory. Here’s what you’ll find:

| **File**               | **Description**                         |
| ---------------------- | --------------------------------------- |
| `all_subdomains.txt`   | All discovered subdomains               |
| `httpx_200.txt`        | Live hosts with HTTP 200 responses      |
| `httpx_301_302.txt`    | Live hosts with HTTP 301/302 redirects  |
| `httpx_401.txt`        | Live hosts with HTTP 401 responses      |
| `httpx_403.txt`        | Live hosts with HTTP 403 responses      |
| `httpx_detailed.txt`   | Hosts with status, title, and tech info |
| `all_urls.txt`         | Merged URLs from all sources            |
| `js_urls.txt`          | JavaScript files (`.js`)                |
| `php_urls.txt`         | PHP files (`.php`)                      |
| `jsp_urls.txt`         | JSP files (`.jsp`)                      |
| `aspx_urls.txt`        | ASPX files (`.aspx`)                    |
| `admin_urls.txt`       | URLs containing `admin`, `login`, etc.  |
| `urls_with_params.txt` | URLs containing parameters (`?`)        |

---

## Example Output

After running `lazyscout example.com`, you will see:

```
[*] Step 1: Finding subdomains...
[*] Step 2: Combining and sorting unique subdomains...
[*] Step 3: Identifying live hosts with httpx...
[*] Step 4: Extracting URLs from live hosts...
[*] Step 5: Sorting and categorizing URLs...

================= LazyScout Summary =================
[*] Subdomains found: 153
[*] Live hosts found: 47
[*] Total URLs extracted: 512
   - JavaScript URLs: 29
   - PHP URLs: 47
   - JSP URLs: 5
   - ASPX URLs: 7
   - Admin/Login URLs: 18
   - URLs with Parameters: 103
[*] Total execution time: 54 seconds
====================================================
```

---

## Dependencies

Ensure you have the following tools installed before running LazyScout:

```bash
sudo apt install subfinder amass httpx waybackurls gau katana gospider
```

Or install them via `go`:

```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v3/...@master
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/jaeles-project/gospider@latest
```

---

## Disclaimer

LazyScout is an **offensive security tool** intended for **authorized testing only**. **Do not** use this tool against domains you do not have explicit permission to test.

---
