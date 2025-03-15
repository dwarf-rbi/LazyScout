#!/bin/bash

# Function to display a rainbow ASCII banner for LazyScout
banner() {
    echo -e "\e[31m  _                             ____                           _   \e[0m"
    echo -e "\e[33m | |       __ _   ____  _   _  / ___|    ___    ___    _   _  | |_ \e[0m"
    echo -e "\e[32m | |      / _\` | |_  / | | | | \___ \   / __|  / _ \  | | | | | __|\e[0m"
    echo -e "\e[36m | |___  | (_| |  / /  | |_| |  ___) | | (__  | (_) | | |_| | | |_ \e[0m"
    echo -e "\e[34m |_____|  \__,_| /___|  \__, | |____/   \___|  \___/   \__,_|  \__|\e[0m"
    echo -e "\e[35m                        |___/                                      \e[0m"
    echo ""
    echo -e "\e[35m             - Automated recon tool by DyslexSec - \e[0m"
}

# Display banner
banner
echo ""

# Help message function
usage() {
    echo "Usage: $0 [-useamass] [-threads|-t <number>] [-ratelimit|-rl <value>] <target domain | file with multiple wildcard domains>"
    echo "Options:"
    echo "  -h         Show this help message"
    echo "  -useamass  Enable Amass for subdomain discovery (disabled by default)"
    echo "  -threads     Number of concurrent threads (default: 10)"
    echo "  -ratelimit   Rate limit per second for requests (default: none)"
    echo "Examples:"
    echo "  $0 example.com"
    echo "  $0 -useamass -t 20 -rl 5 domains.txt"
    exit 0
}

# Track start time
START_TIME=$(date +%s)

# Parse options
USE_AMASS=false
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h)
            usage
            ;;
        -useamass)
            USE_AMASS=true
            shift
            ;;
        -threads|-t)
            THREADS="-t $2"
            shift 2
            ;;
        -ratelimit|-rl)
            RATELIMIT="-rl $2"
            shift 2
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Check if at least one argument is provided
if [ ${#POSITIONAL_ARGS[@]} -eq 0 ]; then
    echo "Error: No domain or file provided."
    usage
fi

domain_input=${POSITIONAL_ARGS[0]}
output_dir="lazyscout"
mkdir -p $output_dir

# Check if input is a file with multiple domains
if [ -f "$domain_input" ]; then
    echo "[*] Processing multiple wildcard domains from $domain_input..."
    cp "$domain_input" $output_dir/domains_list.txt
else
    echo "[*] Processing single domain: $domain_input"
    echo "$domain_input" > $output_dir/domains_list.txt
fi

echo "[*] Step 1: Finding subdomains..."
subfinder -all --recursive -dL $output_dir/domains_list.txt -silent > $output_dir/subfinder.txt

if $USE_AMASS; then
    echo "[*] Running amass (passive mode)..."
    amass enum -passive -df $output_dir/domains_list.txt -o $output_dir/amass.txt &> /dev/null
else    
    touch $output_dir/amass.txt
fi


echo "[*] Step 2: Combining and sorting unique subdomains..."
cat $output_dir/subfinder.txt $output_dir/amass.txt | sort -u > $output_dir/all_subdomains.txt > /dev/null 2>&1


SUBDOMAIN_COUNT=$(wc -l < $output_dir/all_subdomains.txt)

echo "Status: Unique subdomains found $UNIQUE_SUBDOMAINS"


echo "[*] Step 3: Identifying live hosts with httpx..."
httpx -silent -status-code $THREADS $RATELIMIT -l $output_dir/all_subdomains.txt -o $output_dir/httpx_all.txt  > /dev/null 2>&1

# ✅ Correctly extract status codes using the right regex pattern
grep -E '200' $output_dir/httpx_all.txt | cut -d ' ' -f1 > $output_dir/httpx_200.txt
grep -E '301|302' $output_dir/httpx_all.txt | cut -d ' ' -f1 > $output_dir/httpx_301_302.txt
grep -E '401' $output_dir/httpx_all.txt | cut -d ' ' -f1 > $output_dir/httpx_401.txt
grep -E '403' $output_dir/httpx_all.txt | cut -d ' ' -f1 > $output_dir/httpx_403.txt

httpx -silent -l $output_dir/all_subdomains.txt -title -tech-detect -status-code -location > $output_dir/httpx_detailed.txt

echo "[*] Step 4: Extracting URLs from live hosts..."
if [[ -s $output_dir/httpx_200.txt ]]; then
    cat $output_dir/httpx_200.txt | waybackurls > $output_dir/waybackurls.txt
    cat $output_dir/httpx_200.txt | gau > $output_dir/getallurls.txt
    katana -list $output_dir/httpx_200.txt $RATELIMIT -silent -o $output_dir/katana_urls.txt 2>/dev/null
    gospider -S $output_dir/httpx_200.txt -o $output_dir/gospider_output -d 2 $THREADS -c 10 &> /dev/null
else
    echo "[!] No live hosts with status 200 found. Skipping URL extraction..."
    touch $output_dir/waybackurls.txt $output_dir/getallurls.txt $output_dir/katana_urls.txt
fi

cat $output_dir/gospider_output/* > $output_dir/gospider_combined.txt 2>/dev/null
cat gospider_combined.txt | grep -oP '(http|https)://\S+' | sort -u > $output_dir/gospider_urls.txt

echo "[*] Step 5: Sorting and categorizing URLs..."
cat $output_dir/waybackurls.txt $output_dir/getallurls.txt $output_dir/katana_urls.txt $output_dir/gospider_urls.txt | sort -u > $output_dir/all_urls.txt

grep "\.js$" $output_dir/all_urls.txt > $output_dir/js_urls.txt
grep "\.php$" $output_dir/all_urls.txt > $output_dir/php_urls.txt
grep "\.jsp$" $output_dir/all_urls.txt > $output_dir/jsp_urls.txt
grep "\.aspx$" $output_dir/all_urls.txt > $output_dir/aspx_urls.txt
grep -Ei "admin|login|register|forgotpassword|signup" $output_dir/all_urls.txt > $output_dir/admin_urls.txt
grep "\?" $output_dir/all_urls.txt > $output_dir/urls_with_params.txt

# Track end time
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
HOURS=$((TOTAL_TIME / 3600))
MINUTES=$(((TOTAL_TIME % 3600) / 60))
SECONDS=$((TOTAL_TIME % 60))

# Count results

LIVE_HOST_COUNT=$(wc -l < $output_dir/httpx_all.txt)
HTTPX_200=$(wc -l < $output_dir/httpx_200.txt)
HTTPX_301_302=$(wc -l < $output_dir/httpx_301_302.txt)
HTTPX_401=$(wc -l < $output_dir/httpx_401.txt)
HTTPX_403=$(wc -l < $output_dir/httpx_403.txt)
TOTAL_URLS=$(wc -l < $output_dir/all_urls.txt)
JS_COUNT=$(wc -l < $output_dir/js_urls.txt)
PHP_COUNT=$(wc -l < $output_dir/php_urls.txt)
JSP_COUNT=$(wc -l < $output_dir/jsp_urls.txt)
ASPX_COUNT=$(wc -l < $output_dir/aspx_urls.txt)
ADMIN_COUNT=$(wc -l < $output_dir/admin_urls.txt)
PARAM_URL_COUNT=$(wc -l < $output_dir/urls_with_params.txt)

# Display summary
echo ""
echo -e "\e[32m================= LazyScout Summary =================\e[0m"
echo -e "\e[34m[*] Subdomains found: $SUBDOMAIN_COUNT\e[0m"
echo -e "\e[34m[*] Live hosts found: $LIVE_HOST_COUNT\e[0m"
echo -e "\e[33m   - Respond: 200: $HTTPX_200\e[0m"
echo -e "\e[33m   - Respond: 301-302: $HTTPX_301_302\e[0m"
echo -e "\e[33m   - Respond: 401: $HTTPX_401\e[0m"
echo -e "\e[33m   - Respond: 403: $HTTPX_403\e[0m"
echo -e "\e[34m[*] Total URLs extracted: $TOTAL_URLS\e[0m"
echo -e "\e[33m   - JavaScript URLs: $JS_COUNT\e[0m"
echo -e "\e[33m   - PHP URLs: $PHP_COUNT\e[0m"
echo -e "\e[33m   - JSP URLs: $JSP_COUNT\e[0m"
echo -e "\e[33m   - ASPX URLs: $ASPX_COUNT\e[0m"
echo -e "\e[33m   - Admin/Login URLs: $ADMIN_COUNT\e[0m"
echo -e "\e[33m   - URLs with Parameters: $PARAM_URL_COUNT\e[0m"
echo -e "\e[32m[*] Total execution time: ${HOURS}h ${MINUTES}m ${SECONDS}s\e[0m"
echo -e "\e[32m===================================================\e[0m"