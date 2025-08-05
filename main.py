import argparse
import sys

from src.vm_config import VMConfig
from src.deploy import Deployer
from src.monitor import get_logs, monitor_vm, stream_logs
from src.compute_client import get_compute_client

def main():
    
    parser = argparse.ArgumentParser(description='Deploy ML training to GCP VM')
    parser.add_argument('--action', choices=['deploy', 'logs', 'monitor', 'stream'], default='deploy', help='Action to perform (default: deploy)')
    parser.add_argument('--name', default=None, help='VM name (auto-generated if not provided)')
    parser.add_argument('--machine-type', default='n1-standard-1', help='Machine type (default: n1-standard-1)')
    parser.add_argument('--startup-script', default='vm_shell_scripts/test-run-script.sh', help='Startup script (default: vm_shell_scripts/test-run-script.sh)')
    parser.add_argument('--service-account', default=None, help='Service account email (default: uses environment ML_SERVICE_ACCOUNT or VM default)')
    parser.add_argument('--no-preemptible', action='store_true', help='Disable preemptible instances (default: False)')
    parser.add_argument('--no-auto-shutdown', action='store_true', help='Disable auto-shutdown (default: False)')
    # New argument for example custom param
    parser.add_argument('--example-custom-param', choices=['foo', 'bar'], default='foo', 
                       help='Example custom param: foo, bar (default: foo)')
    
    args = parser.parse_args()
    
    config = VMConfig(
        machine_type=args.machine_type,
        preemptible=not args.no_preemptible,
        auto_shutdown=not args.no_auto_shutdown,
        service_account=getattr(args, 'service_account', None),
        startup_script=args.startup_script,
        example_custom_param=args.example_custom_param
    )
    
    deployer = Deployer(config, get_compute_client())
    
    if args.action == 'deploy':
        vm_name = deployer.deploy_vm(args.name)
        print(f"Stream logs with: python deploy.py --action stream --name {vm_name}")
        print(f"Monitor with: python deploy.py --action monitor --name {vm_name}")
        print(f"Get logs with: python deploy.py --action logs --name {vm_name}")

        # Show mode-specific usage examples
        # print("\n🚀 Deployment Examples:")
        # print("  Single experiment:    python deploy.py --example-custom-param foo")
        # print("  Experiment suite:     python deploy.py --example-custom-param bar") 
        
    elif args.action == 'logs':
        if not args.name:
            print("--name required for logs")
            sys.exit(1)
        logs = get_logs(args.name, config.zone)
        print(logs)
        
    elif args.action == 'monitor':
        if not args.name:
            print("--name required for monitor")
            sys.exit(1)
        monitor_vm(config.project_id, config.zone, args.name, get_compute_client())
        
    elif args.action == 'stream':
        if not args.name:
            print("--name required for stream")
            sys.exit(1)
        stream_logs(args.name, config.zone)

if __name__ == "__main__":
    main() 