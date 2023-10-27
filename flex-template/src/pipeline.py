import argparse
import logging

import apache_beam as beam
import pandas as pd

from apache_beam.options.pipeline_options import GoogleCloudOptions
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from datetime import datetime
from google.cloud import storage


class CustomPipelineOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        # Set the required arguments
        parser.add_value_provider_argument(
            "--gcs_file_path", help="GCS File Path", required=True
        )
        parser.add_value_provider_argument(
            "--custom_gcs_temp_location",
            help="GCS Temp location for Dataflow",
            required=True,
        )
        parser.add_value_provider_argument(
            "--output_table", help="BigQuery Table", required=True
        )


class ProcessExcel(beam.DoFn):
    def process(self, element):
        transformed_element = {key: str(value) for key, value in element.items()}

        yield transformed_element


# Function to clean and format column names
def clean_column_name(col_name):
    # Make all lowercase
    col_name = col_name.lower()

    # Remove special characters and replace spaces with underscores
    col_name = "".join(e for e in col_name if e.isalnum() or e.isspace()).replace(
        " ", "_"
    )

    # Remove extra spaces
    col_name = "_".join(col_name.split())

    return col_name


def run(argv=None, save_main_session=True):
    # pipeline options
    parser = argparse.ArgumentParser()
    known_args, pipeline_args = parser.parse_known_args(argv)

    # We use the save_main_session option because one or more DoFn's in this
    # workflow rely on global context (e.g., a module imported at module level).
    pipeline_options = PipelineOptions(pipeline_args)
    custom_options = pipeline_options.view_as(CustomPipelineOptions)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session

    # Class to add some metadata to the target table
    class AddMetadata(beam.DoFn):
        def process(self, element):
            new_element = dict(element)  # Create a copy of the original dictionary

            # adding source
            new_element["pipeline_source"] = "Dataflow Flex Template"
            new_element["file_path"] = custom_options.gcs_file_path.get()

            # Add a DATETIME column with the current timestamp
            current_time = datetime.now()
            new_element["load_datetime"] = current_time
            new_element["load_date"] = current_time.date()

            yield new_element  # Emit the new dictionary with the added columns

    # The pipeline will be run on exiting the with block.
    with beam.Pipeline(options=pipeline_options) as p:
        # extracting information about the file
        gcs_file_path = custom_options.gcs_file_path.get()
        bucket_name = gcs_file_path.split("/")[2]
        file_name = gcs_file_path.split("/")[-1]
        file_path = gcs_file_path.split("//")[-1].split("/", 1)[-1]

        # getting the file from GCS
        storage_client = storage.Client()
        storage_bucket = storage_client.get_bucket(bucket_name)
        blob = storage_bucket.blob(file_path)
        data_bytes = blob.download_as_bytes()

        # converting the bytes to a pandas dataframe
        df = pd.read_excel(data_bytes)

        # updating column names
        df.columns = [clean_column_name(col) for col in df.columns]
        data = df.to_dict(orient="records")

        process_data = (
            p
            | "Read Excel" >> beam.Create(data)
            | "Convert to String" >> beam.ParDo(ProcessExcel())
            | "Add Metadata" >> beam.ParDo(AddMetadata())
            | "Write to BigQuery"
            >> beam.io.WriteToBigQuery(
                table=custom_options.output_table.get(),
                schema="SCHEMA_AUTODETECT",
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                custom_gcs_temp_location=custom_options.custom_gcs_temp_location.get(),
            )
        )


if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    run()
