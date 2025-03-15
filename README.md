# LazyScout

LazyScout is an automated reconnaissance tool for finding subdomains, live hosts, and extracting URLs.

## Features
- **Subdomain Enumeration**: Finds subdomains using Subfinder and Amass (optional).
- **Live Host Detection**: Uses httpx to check which subdomains are active.
- **URL Extraction**: Collects URLs from Wayback Machine, Gau, Katana, and GoSpider.
- **Categorization**: Filters URLs by type (JavaScript, PHP, admin panels, etc.).

## Usage
```bash
./lazyscout.sh [-useamass] [-t <threads>] [-rl <rate limit>] <domain | file>
```

### Options:
- `-h` : Show help message.
- `-useamass` : Use Amass for subdomain discovery.
- `-t <number>` : Set threads (default: 10).
- `-rl <value>` : Set rate limit.

### Example:
```bash
./lazyscout.sh -useamass -t 20 -rl 5 domains.txt
```

## Output
Results are saved in the `lazyscout` directory:
- `all_subdomains.txt` - Unique subdomains.
- `httpx_all.txt` - Live hosts.
- `all_urls.txt` - Extracted URLs.

## Dependencies
Requires:
- `subfinder`, `amass`, `httpx`, `waybackurls`, `gau`, `katana`, `gospider`

For silent execution:
```bash
./lazyscout.sh example.com &> /dev/null
```

