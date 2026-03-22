# 1. Install IIS Role
Install-WindowsFeature -name Web-Server

# 2. Collect Real-Time Instance Metadata
$hostname  = hostname
$privateIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Ethernet*').IPv4Address | Select-Object -First 1
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss") + " UTC"
$requestID = [guid]::NewGuid().ToString().Substring(0,8).ToUpper()

# 3. Create the High-End Dashboard HTML
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Azure VMSS Dashboard</title>
    <style>
        :root {
            --azure-blue: #0078d4; 
            --azure-glow: #2899f5;
            --bg: #080c12; 
            --card: #0d1620;
            --text: #e6eff8; 
            --secondary: #7fa0be; 
            --green: #3dd68c;
            --demo-bg: rgba(0, 120, 212, 0.15);
        }
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: var(--bg); color: var(--text); display: flex; justify-content: center; padding: 40px 20px; margin: 0; }
        .wrapper { width: 100%; max-width: 700px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .badge { background: rgba(0,120,212,0.2); color: var(--azure-glow); padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: bold; border: 1px solid var(--azure-blue); text-transform: uppercase; }
        .card { background: var(--card); border: 1px solid rgba(0,120,212,0.2); border-radius: 12px; padding: 30px; box-shadow: 0 15px 35px rgba(0,0,0,0.5); position: relative; }
        .status { position: absolute; top: 20px; right: 20px; display: flex; align-items: center; gap: 8px; color: var(--green); font-size: 0.8rem; font-weight: bold; }
        .dot { width: 8px; height: 8px; background: var(--green); border-radius: 50%; box-shadow: 0 0 10px var(--green); animation: pulse 2s infinite; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.4; } 100% { opacity: 1; } }
        h1 { margin: 0; font-size: 1.5rem; letter-spacing: -0.5px; }
        p.subtitle { color: var(--secondary); margin: 5px 0 25px 0; font-size: 0.9rem; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; }
        .item { background: rgba(255,255,255,0.03); padding: 15px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.05); }
        .label { font-size: 0.65rem; color: var(--secondary); text-transform: uppercase; margin-bottom: 5px; display: flex; align-items: center; gap: 8px; }
        .val { font-family: 'Consolas', 'Courier New', monospace; font-size: 1rem; color: var(--azure-glow); font-weight: bold; }
        .metrics-header { display: flex; align-items: center; gap: 10px; margin-bottom: 15px; font-weight: bold; font-size: 0.9rem; }
        .metrics-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px; }
        .m-card { background: #132030; padding: 12px; border-radius: 8px; text-align: center; border: 1px solid rgba(255,255,255,0.03); }
        .m-val { font-size: 1.1rem; font-weight: bold; display: block; margin-top: 5px; color: var(--text); }
        
        /* IMPROVED COLOR FOR DEMO BOX */
        .demo-box { 
            margin-top: 30px; 
            padding: 20px; 
            background: var(--demo-bg); 
            border: 1px solid var(--azure-blue);
            border-left: 5px solid var(--azure-glow); 
            border-radius: 8px;
            font-size: 0.9rem; 
            color: #ffffff; 
            line-height: 1.6; 
        }
        .demo-title { color: var(--azure-glow); font-weight: 800; text-transform: uppercase; display: block; margin-bottom: 5px; font-size: 0.75rem; }
        
        footer { margin-top: 30px; text-align: center; font-size: 0.75rem; color: var(--secondary); opacity: 0.6; line-height: 1.5; }
    </style>
</head>
<body>
    <div class="wrapper">
        <div class="header">
            <div style="font-size: 0.9rem; letter-spacing: 1px;"><strong>MICROSOFT AZURE</strong></div>
            <div class="badge">Production Environment</div>
        </div>

        <div class="card">
            <div class="status"><div class="dot"></div> HEALTHY</div>
            <h1>Production Web App</h1>
            <p class="subtitle">VMSS Instance Dashboard — Stateless Node</p>

            <div class="grid">
                <div class="item"><div class="label">🖥 Instance Name</div><div class="val">$hostname</div></div>
                <div class="item"><div class="label">🌐 Private IP Address</div><div class="val">$privateIP</div></div>
                <div class="item"><div class="label">🕐 Timestamp (UTC)</div><div class="val">$timestamp</div></div>
                <div class="item"><div class="label">🔑 Request ID</div><div class="val">$requestID</div></div>
            </div>

            <div class="metrics-header">📊 System Metrics <span style="color:var(--green); font-size:0.7rem; margin-left:10px;">● LIVE</span></div>
            <div class="metrics-grid">
                <div class="m-card"><span class="label">⚙️ CPU</span><span class="m-val">12%</span></div>
                <div class="m-card"><span class="label">🧠 Memory</span><span class="m-val">34%</span></div>
                <div class="m-card"><span class="label">💾 Disk I/O</span><span class="m-val">2%</span></div>
            </div>

            <div class="demo-box">
                <span class="demo-title">⚡ Load Balancer Demo</span>
                Each refresh may route to a different VMSS instance. 
                Observe the <strong>Instance Name</strong> and <strong>Private IP</strong> change to confirm 
                stateless distribution across the scale set.
            </div>
        </div>

        <footer>
            Powered by Azure Virtual Machine Scale Sets<br>
            IIS on Windows Server | Azure Load Balancer | Health Endpoint: /health.html
        </footer>
    </div>
</body>
</html>
"@

# 4. Write Dashboard File with UTF8 Encoding (Fixes the "?" issue)
Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value $htmlContent -Encoding UTF8 -Force

# 5. Final Step: Create Health Probe File
Set-Content -Path "C:\inetpub\wwwroot\health.html" -Value "Healthy" -Encoding UTF8 -Force
