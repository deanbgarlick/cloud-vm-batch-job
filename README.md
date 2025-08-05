## What is this repo

This repo provides functionality for the following sequence of events:
1. Configuring GCP for batch jobs (service account creation, bucket creation, network creation)
2. Launch VMs on GCP
3. Have the VMs run a script that clones a public git repo, runs pip install -r requirements.txt and then python -m main
4. Have the VM upload logs to a bucket
5. Have the VM shut down once finished running python -m main and

The VM can be monitored and have its logs streamed or fetched to the local user using the command line interface for main.py


## How to run this repo

Do the following in order:
1. Create a GCP account and enable the required services (cloud engine, buckets, etc)
2. Set your choices for git repo url, regions, names of buckets, etc are in the project's .env file
3. Run sh setup.sh
4. Uncomment the line GOOGLE_APPLICATION_CREDENTIALS=./secrets/vm-orchestrator-sa-key.json in the .env file
5. Run python -m main
