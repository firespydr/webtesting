#!/bin/bash

# Output file
OUTPUT_FILE="caddy_diagnostics.txt"
echo "Caddy Diagnostic Report - $(date)" > "$OUTPUT_FILE"

echo "============================================" >> "$OUTPUT_FILE"
echo "Step 1: Checking Public IP of Server" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
PUBLIC_IP=$(curl -s -4 ifconfig.me)
echo "Public IP: $PUBLIC_IP" | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 2: Checking DNS A Record for p.space" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
DNS_IP=$(dig +short p.space)
echo "DNS A Record: $DNS_IP" | tee -a "$OUTPUT_FILE"

if [[ "$PUBLIC_IP" != "$DNS_IP" ]]; then
    echo "⚠️  WARNING: Public IP and DNS A record do not match!" | tee -a "$OUTPUT_FILE"
else
    echo "✅ DNS and Public IP match." | tee -a "$OUTPUT_FILE"
fi

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 3: Checking if Caddy is Listening on Ports 80 and 443" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
sudo ss -tulpn | grep -E ':80|:443' | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 4: Testing Local HTTP Connectivity" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
curl -I http://localhost 2>&1 | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 5: Testing External HTTP Connectivity" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
curl -Iv http://$PUBLIC_IP 2>&1 | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 6: Checking UFW Firewall Rules" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
sudo ufw status | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 7: Checking Linode Network Restrictions (Manual Check Required)" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
echo "Go to Linode Cloud Manager → Networking → Firewall & Restrictions and verify that ports 80 and 443 are open." | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 8: Checking Caddy Logs for TLS Issues" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
podman logs caddy | grep -i "certificate" | tee -a "$OUTPUT_FILE"

echo -e "\n============================================" >> "$OUTPUT_FILE"
echo "Step 9: Checking Podman Caddy Container Details" >> "$OUTPUT_FILE"
echo "============================================" >> "$OUTPUT_FILE"
podman inspect caddy | grep -E '"IPAddress|HostConfig|Mounts|Ports' | tee -a "$OUTPUT_FILE"

echo -e "\n🚀 Diagnostic Report Completed! Saved as: $OUTPUT_FILE" | tee -a "$OUTPUT_FILE"
