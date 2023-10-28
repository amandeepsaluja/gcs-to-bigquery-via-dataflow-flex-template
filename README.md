# Dataflow Flex Template for GCS to BigQuery via Cloud Function

In this project, we are building a Dataflow Flex Template (Python) to load data from GCS to BigQuery via Cloud Function.

As we know, we already have a [Google Provided template](https://cloud.google.com/dataflow/docs/guides/templates/provided/cloud-storage-to-bigquery) which already does that. So, what's the point here? Well, it does not provide as funtionality to read Excel files. So, we are going to add that functionality in this template.

## Project Steps

1. Writing the Dataflow Pipeline in Python
2. Setup Infrastructure in Terraform
3. Push the Docker Image to Google Container Registry via Terraform
4. Generate Flex Template Spec
5. Develop Cloud Function to trigger the Dataflow Job based on Excel file uploaded to GCS Bucket
6. Deploy the Cloud Function via Terraform
7. Test the Dataflow Job

## Refrences

- https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates
- https://cloud.google.com/dataflow/docs/guides/templates/configuring-flex-templates
- https://cloud.google.com/dataflow/docs/reference/rest/v1b3/projects.locations.flexTemplates/launch
- https://cloud.google.com/dataflow/docs/guides/templates/running-templates
- https://stackoverflow.com/questions/52388627/using-python-to-run-a-google-dataflow-template
- https://xebia.com/blog/a-declarative-approach-for-dataflow-flex-templates/
- https://cloud.google.com/dataflow/docs/guides/common-errors
- https://cloud.google.com/dataflow/docs/guides/troubleshoot-templates
- https://cloud.google.com/dataflow/docs/guides/using-custom-containers#prebuild
- https://github.com/google/dataflow-ml-starter/tree/main
- https://github.com/BVK23/Beam_ETL_UKProp/blob/main/ETL%202/ETL_2_Dataflow_job.py
