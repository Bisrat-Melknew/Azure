# 🚀 Azure VMSS Auto-Scaling & Self-Healing Web App

This project demonstrates a **production-style cloud architecture** built on Azure using Virtual Machine Scale Sets (VMSS).  
It showcases **auto-scaling, self-healing, load balancing, and full automation** under real traffic conditions.

---

# 📌 Architecture Overview

A stateless web application deployed behind a Load Balancer with:

- Horizontal scaling (VMSS)
- Health-based traffic routing
- Automated VM provisioning
- Self-healing via health probes

---

# 🏗️ Architecture Diagram (Simplified)




---

# 🎯 Problem Solved

Traditional deployments:
- Require manual scaling
- Fail under load spikes
- Lack automatic recovery

This solution provides:

✔ Automatic scaling based on demand  
✔ Self-healing when instances fail  
✔ Zero manual configuration for new VMs  
✔ Health-driven traffic routing  

---

# ⚙️ Key Features

### 🔹 Load Balancing
- Azure Load Balancer distributes traffic across VM instances
- Uses **Layer 4 (TCP) rules on Port 80**

---

### 🔹 Auto-Scaling
- Trigger:  
  `Network In > 8 MB for 5 minutes`
- Scale-Out: Adds new VM instances  
- Scale-In: Removes instances when traffic drops  

---

### 🔹 Self-Healing
- Health Probe checks:  
  `/health.html`
- If probe fails:
  → VM marked unhealthy  
  → Automatically replaced  

---

### 🔹 Custom Script Automation
Each VM runs a script that:

- Installs IIS
- Generates a dynamic webpage
- Creates `/health.html` for health validation

---

### 🔹 Security (NSG Rules)

| Rule | Port | Purpose |
|------|------|--------|
| HTTP | 80   | Public access |
| iPerf3 | 5201 | Load testing |
| RDP | 3389 | Admin access (restricted IP) |

---

# 🧪 Demo Scenarios

## 1️⃣ Load Balancing
- Multiple requests hit different VM instances  
- Each response shows unique hostname  

---

## 2️⃣ Chaos Test (Self-Healing)
- Simulate failure (break IIS or delete file)
- Result:
  - Instance becomes unhealthy  
  - Automatically replaced  

---

## 3️⃣ Load Test (Auto-Scaling)

Traffic generated using:




### Result:
- Scale-Out triggered
- New VM created automatically
- Script runs → IIS installed → becomes healthy

---

## 4️⃣ Scale-In (Recovery)

- Stop traffic
- System detects low demand
- Extra VM is deleted
- Returns to minimum capacity

---

# ⚠️ Key Engineering Insight

### 🔥 Custom Health Logic (Critical Fix)

The system only marks a VM as **Healthy** when:


✔ Prevents premature health detection  
✔ Avoids VM deletion during setup  
✔ Fixes "boot loop" issue  

---

# 🛠️ Deployment Steps

## 1. Deploy Infrastructure
- Use ARM Template (included in repo)
- Deploy:
  - VMSS
  - Load Balancer
  - NSG
  - Autoscale rules

---

## 2. Configure Script (Custom Script Extension)

PowerShell script:

```powershell
Install-WindowsFeature -name Web-Server

$hostname = hostname

$html = "<html><body style='font-family:Arial;text-align:center;margin-top:50px;'>
<h1>Azure VMSS Demo</h1>
<h2>Instance: $hostname</h2>
<p>Auto-Scaling & Self-Healing Active</p>
</body></html>"

Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value $html -Force

Set-Content -Path "C:\inetpub\wwwroot\health.html" -Value "OK" -Force