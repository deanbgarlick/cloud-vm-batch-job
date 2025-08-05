import subprocess
import time
from src.vm_config import VMConfig

from src.compute_client import get_compute_client


def get_logs(name: str, zone: str) -> str:
    """Get VM serial console output"""
    result = subprocess.run([
        "gcloud", "compute", "instances", "get-serial-port-output", 
        name, f"--zone={zone}"
    ], capture_output=True, text=True)
    return result.stdout


def monitor_vm(project_id: str, zone: str, name: str):
    """Monitor VM until completion"""
    while True:
        try:
            instance = get_compute_client().get(
                project=project_id,
                zone=zone,
                instance=name
            )
            status = instance.status
            print(f"VM Status: {status} ({time.strftime('%H:%M:%S')})")
            
            if status == "TERMINATED":
                print("✓ VM has terminated")
                break
                
            time.sleep(30)
            
        except Exception as e:
            print(f"✗ VM not found: {e}")
            break


def stream_logs(name: str, zone: str):
    """Stream VM logs in real-time"""
    print(f"🔄 Streaming logs from {name}... (Ctrl+C to stop)")
    try:
        subprocess.run([
            "gcloud", "compute", "instances", "tail-serial-port-output",
            name, f"--zone={zone}"
        ])
    except KeyboardInterrupt:
        print("\n📋 Log streaming stopped")
