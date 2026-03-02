import nmap
import csv
import sys
import socket
from datetime import datetime

def get_dns_hostname(ip):
    """Equivalent to the 'host' command for reverse DNS lookup."""
    try:
        return socket.gethostbyaddr(ip)[0]
    except (socket.herror, socket.gaierror):
        return "No DNS Record"

def scan_vlan_comprehensive(vlan_cidr):
    """Uses Nmap for OS/Services and Socket for DNS Resolution."""
    nm = nmap.PortScanner()
    
    print(f"--- Starting Deep Scan on {vlan_cidr} ---")
    
    try:
        # -O: OS Detection, -sV: Services, -F: Fast Port Scan
        nm.scan(hosts=vlan_cidr, arguments='-O -sV -F')
    except nmap.PortScannerError as e:
        print(f"Error: {e}. (Ensure you are running as Root/Admin)")
        sys.exit(1)
    
    inventory_list = []
    
    for host in nm.all_hosts():
        print(f"Analyzing {host}...")
        dns_name = get_dns_hostname(host)
        
        host_info = {
            "IP": host,
            "DNS_Hostname": dns_name,
            "Nmap_Hostname": nm[host].hostname() if nm[host].hostname() else "Unknown",
            "State": nm[host].state(),
            "OS_Name": "Unknown",
            "OS_Accuracy": "0%",
            "Open_Ports": "",
            "Scan_Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        
        # OS details
        if 'osmatch' in nm[host] and len(nm[host]['osmatch']) > 0:
            top_match = nm[host]['osmatch'][0]
            host_info["OS_Name"] = top_match.get('name', 'N/A')
            host_info["OS_Accuracy"] = top_match.get('accuracy', '0') + "%"
        
        # Port details
        ports = []
        for proto in nm[host].all_protocols():
            lport = nm[host][proto].keys()
            for port in lport:
                service = nm[host][proto][port]['name']
                ports.append(f"{port}/{service}")
        
        host_info["Open_Ports"] = ", ".join(ports)
        inventory_list.append(host_info)
        
    return inventory_list

def main():
    target = input("Enter the VLAN/Subnet (e.g., 192.168.1.0/24): ")
    
    results = scan_vlan_comprehensive(target)
    
    if results:
        # Create a unique filename with the current date and time
        current_time = datetime.now().strftime("%Y-%m-%d_%H%M")
        filename = f"inventory_{current_time}.csv"
        
        keys = results[0].keys()
        with open(filename, 'w', newline='') as f:
            dict_writer = csv.DictWriter(f, fieldnames=keys)
            dict_writer.writeheader()
            dict_writer.writerows(results)
            
        print(f"\n--- Scan Complete ---")
        print(f"Results exported to: {filename}")
    else:
        print("No hosts found. Verify your network connection and permissions.")

if __name__ == "__main__":
    main()
