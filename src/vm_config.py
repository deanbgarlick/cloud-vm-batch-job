from dataclasses import dataclass
import dotenv
import os

dotenv.load_dotenv()

@dataclass
class VMConfig:
    name: str = "vm-runner"
    branch: str = "main"
    project_id: str = os.getenv("GCLOUD_PROJECT_ID", "")
    zone: str = os.getenv("DEFAULT_ZONE", "us-central1-a") 
    repo_url: str = os.getenv("REPO_URL", "")
    machine_type: str = os.getenv("DEFAULT_MACHINE_TYPE", "n1-standard-1")
    service_account: str = os.getenv("VM_RUNNER_SERVICE_ACCOUNT", "") + "@" + os.getenv("PROJECT_ID", "") + ".iam.gserviceaccount.com"
    startup_script: str = "vm_shell_scripts/main-run-script.sh"
    source_image: str = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    disk_size_gb: int = 50
    preemptible: bool = True
    auto_shutdown: bool = True
    # New field for ML pipeline mode
    example_custom_param: str = "single"  # "single", "suite", or "dispatcher"
    
    # Network configuration
    network_name: str = os.getenv("NETWORK_NAME", "vm-runner-network")
    subnet_name: str = os.getenv("SUBNET_NAME", "vm-runner-subnet")
    region: str = os.getenv("REGION", "us-central1")
    subnet_range: str = os.getenv("SUBNET_RANGE", "10.0.0.0/24")
