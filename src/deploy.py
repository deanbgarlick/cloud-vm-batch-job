#!/usr/bin/env python3
"""VM Runner Deployment Script in Python"""

import dotenv
import os
import time
from typing import Optional
from google.cloud import compute_v1
from src.vm_config import VMConfig

dotenv.load_dotenv()


class Deployer:
    def __init__(self, config: VMConfig):
        self.config = config
        self.compute_client = compute_v1.InstancesClient()
        
    def deploy_vm(self, vm_name: Optional[str] = None) -> str:
        """Deploy VM and return instance name"""

        if not vm_name:
            vm_name = f"vm-runner-{self.config.example_custom_param}-{int(time.time())}"
            
        instance_config = self._create_instance_config(vm_name, self.config)
        self._create_instance(instance_config)
        self._log_success(vm_name)

        return vm_name
    
    def _create_instance(self, instance_config: compute_v1.Instance):
        instance = compute_v1.Instance(instance_config)
        operation = self.compute_client.insert(
            project=self.config.project_id,
            zone=self.config.zone,
            instance_resource=instance
        )
        return

    def _create_instance_config(self, vm_name: str, config: VMConfig) -> compute_v1.Instance:
        # Configure instance

        # Read startup script
        with open('startup-script-local.sh', 'r') as f:
            startup_script = f.read()

        return {
            "name": vm_name,
            "machine_type": f"zones/{self.config.zone}/machineTypes/{self.config.machine_type}",
            "scheduling": {"preemptible": self.config.preemptible},
            "disks": [{
                "boot": True,
                "auto_delete": True,
                "initialize_params": {
                    "source_image": "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts",
                    "disk_size_gb": 50,
                    "disk_type": f"zones/{self.config.zone}/diskTypes/pd-ssd"
                }
            }],
            "network_interfaces": [{
                "network": f"projects/{self.config.project_id}/global/networks/default"
            }],
            "metadata": {
                "items": [
                    {"key": "startup-script", "value": startup_script},
                    {"key": "repo-url", "value": self.config.repo_url},
                    {"key": "branch", "value": self.config.branch},
                    {"key": "auto-shutdown", "value": str(self.config.auto_shutdown).lower()},
                    {"key": "example-custom-param", "value": self.config.example_custom_param}
                ]
            },
            "service_accounts": [{
                "email": self.config.service_account if self.config.service_account else "default",
                "scopes": ["https://www.googleapis.com/auth/cloud-platform"]
            }],
            "tags": {"items": ["vm-runner", "example-custom-tag"]}
        }
        
    def _log_success(self, vm_name: str):
   
        print(f"✓ VM {vm_name} deployed successfully!")
        print(f"🎯 Example Custom Param Value: {self.config.example_custom_param}")
        
        # Show mode-specific info
        if self.config.example_custom_param == "foo":
            print(f"📄 Running: python main.py")
        elif self.config.example_custom_param == "bar":
            print(f"📊 Running: python main.py")
        else:
            print(f"🚀 Running: python main.py")
        
        print(f"📊 Logs will be saved to: gs://{os.getenv('VM_RUNNER_LOGS_BUCKET_NAME')}/{vm_name}_<timestamp>/")
        print(f"🔄 Stream logs: python main.py --action stream --name {vm_name}")
        print(f"📋 Monitor VM: python main.py --action monitor --name {vm_name}")
        print(f"📜 Get logs: python main.py --action logs --name {vm_name}")
