import functions_framework

from datetime import datetime
from googleapiclient.discovery import build


@functions_framework.cloud_event
def create_dataflow_job(cloudevent):
    # Getting payload data from the Cloud Storage event
    payload = cloudevent.data.get("protoPayload")
    resource_name = payload.get("resourceName")

    # Extract the GCS bucket and object details
    gcs_file_location = resource_name.split("/", maxsplit=3)[-1].replace(
        "/objects/", "/"
    )

    gcs_file_path = f"gs://{gcs_file_location}"
    print(f"File uploaded: {gcs_file_path}")

    gcs_template_location = "gs://dataflow-bucket-gcp-practice-project-aman/templates/excel-in-gcs-to-bq-v2.json"

    job_name = f"gcs-to-bq-via-dataflow-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

    # Creating the Dataflow job
    service = build("dataflow", "v1b3", cache_discovery=False)

    request = (
        service.projects()
        .locations()
        .flexTemplates()
        .launch(
            projectId="gcp-practice-project-aman",
            location="us-central1",
            body={
                "launchParameter": {
                    "jobName": job_name,
                    "environment": {
                        "tempLocation": "gs://dataflow-bucket-gcp-practice-project-aman/temp",
                        "stagingLocation": "gs://dataflow-bucket-gcp-practice-project-aman/staging",
                        "enableStreamingEngine": False,
                    },
                    "containerSpecGcsPath": gcs_template_location,
                    "parameters": {
                        "gcs_file_path": gcs_file_path,
                        "custom_gcs_temp_location": "gs://dataflow-bucket-gcp-practice-project-aman/temp",
                        "output_table": "gcp-practice-project-aman:raw_layer.test_table",
                    },
                }
            },
        )
    )

    response = request.execute()

    return print(str(response))
