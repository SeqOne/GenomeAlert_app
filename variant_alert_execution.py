import argparse
from variant_alert_function import execute_variant_alert_pipeline

parser = argparse.ArgumentParser(
    description="execute variant_alert on VCF target and gather output in a summary dataframe"
)
parser.add_argument(
    "--vcf-path",
    action="store",
    dest="path_input",
    help="path of directory containing target VCF for variant-alert.",
    required=True,
)
parser.add_argument(
    "--VA-output-path",
    action="store",
    dest="path_output",
    required=True,
    help="path containing output of variant-alert : tsv files.",
)

args = parser.parse_args()

execute_variant_alert_pipeline(args.path_input, args.path_output)
