#!/usr/bin/env python3
import json, os, shutil, socket, subprocess, time
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
ROOT=Path("/usr/share/ayvatech-dashboard")
CATALOG=json.loads((ROOT/"catalog.json").read_text())
def run(*args):
    try:return subprocess.run(args,text=True,capture_output=True,timeout=4).stdout.strip()
    except Exception:return ""
def memory():
    values={}
    try:
        for line in Path("/proc/meminfo").read_text().splitlines():
            key,val=line.split(":",1); values[key]=int(val.strip().split()[0])
        total=values.get("MemTotal",0); used=total-values.get("MemAvailable",0)
        return {"used":used*1024,"total":total*1024,"percent":round(used*100/total) if total else 0}
    except Exception:return {"used":0,"total":0,"percent":0}
def temperature():
    readings=[]
    for p in Path("/sys/class/thermal").glob("thermal_zone*/temp"):
        try:
            v=float(p.read_text().strip()); readings.append(v/1000 if v>1000 else v)
        except Exception:pass
    return round(max(readings),1) if readings else None
def containers():
    raw=run("docker","ps","-a","--format","{{.Names}}|{{.Status}}|{{.State}}")
    found={}
    for line in raw.splitlines():
        parts=line.split("|",2)
        if len(parts)==3:found[parts[0]]={"status":parts[1],"state":parts[2]}
    return found
def status():
    host=socket.gethostname(); ip=run("hostname","-I").split(" ")[0] or "unknown"; disk=shutil.disk_usage("/")
    active=containers(); apps=[]
    for app in CATALOG:
        names=[n for n in active if app["id"] in n or app["id"].replace("-","") in n.replace("-","")]
        if app["id"]=="homepage": state="running"
        elif app["id"]=="samba": state="running" if run("systemctl","is-active","smbd")=="active" else "not installed"
        elif names: state="running" if any(active[n]["state"]=="running" for n in names) else "stopped"
        else: state="not installed"
        item=dict(app); item["state"]=state; item["url"]=f'{app["scheme"]}://{ip}:{app["port"]}' if app.get("port") else None; apps.append(item)
    try:up=float(Path("/proc/uptime").read_text().split()[0])
    except Exception:up=0
    load=os.getloadavg()[0] if hasattr(os,"getloadavg") else 0
    return {"hostname":host,"localName":"homeserver.local","ip":ip,"uptimeSeconds":round(up),"cpuLoad":round(load,2),"memory":memory(),"temperature":temperature(),"disk":{"used":disk.used,"total":disk.total,"percent":round(disk.used*100/disk.total)},"docker":run("systemctl","is-active","docker") or "unknown","ssh":run("systemctl","is-active","ssh") or "unknown","apps":apps,"updatedAt":int(time.time())}
class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path=="/api/status":
            body=json.dumps(status()).encode(); self.send_response(200); self.send_header("Content-Type","application/json"); self.send_header("Cache-Control","no-store"); self.send_header("Content-Length",str(len(body))); self.end_headers(); self.wfile.write(body); return
        if self.path=="/health": self.send_response(204); self.end_headers(); return
        return super().do_GET()
    def translate_path(self,path):
        clean=path.split("?",1)[0].split("#",1)[0].lstrip("/") or "index.html"
        target=(ROOT/clean).resolve()
        return str(target if str(target).startswith(str(ROOT.resolve())) else ROOT/"index.html")
    def log_message(self,format,*args):pass
ThreadingHTTPServer(("127.0.0.1",8088),Handler).serve_forever()
