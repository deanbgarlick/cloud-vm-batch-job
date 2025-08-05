from google.cloud import compute_v1

compute_client = None


def get_compute_client():
    global compute_client
    if compute_client is None:
        compute_client = compute_v1.InstancesClient()
    return compute_client
