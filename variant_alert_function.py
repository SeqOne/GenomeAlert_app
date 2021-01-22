#!/usr/bin/env python3

import os
import os.path
import subprocess
import pandas as pd


def get_list_file(path_input, extension, command):
    """
    Return the file list of a directory.##chercher command dans le nom des tsv
    """
    path = path_input
    os.chdir(path_input)
    ls = os.listdir(path)
    file = []
    for f in ls:
        if (f.endswith(extension) is True) & (command.split("-")[-1] in f):
            file.append(path + "/" + f)
    file.sort()
    return file


def execute_variant_alert(list_vcf_file, command, path_output):
    """
    Execute variant-alert on a list of VCF file.
    Command enable to chose between compare-gene,
    compare-variant and clinvarome.
    """
    for k in range(len(list_vcf_file) - 1):
        subprocess.run(
            [
                "variant-alert",
                "-o",
                path_output,
                list_vcf_file[k],
                list_vcf_file[k + 1],
                command,
            ]
        )
    return


def concate_dataframe(list_tsv_VA_output):
    """
    Concatenate all tsv file, output of variant alert,
    into a summary dataframe.
    """
    df_total_variant_alert = pd.DataFrame()
    for k in list_tsv_VA_output:
        df_variant_alert = pd.read_csv(k, sep="\t")
        df_total_variant_alert = pd.concat([df_total_variant_alert, df_variant_alert])
    return df_total_variant_alert


def execute_variant_alert_pipeline(path_input, path_output):
    """
    Execute variant alert and gather output.
    Fill NaN with points, in order to simply parsing in Shiny App.
    Remove variantalert_command_total.tsv file if already exists.
    """

    input_end_file = ".vcf.gz"
    output_end_file = "tsv"
    list_vcf_file = get_list_file(path_input, input_end_file, "clinvar")
    for command in ["compare-variant", "compare-gene", "clinvarome"]:
        execute_variant_alert(list_vcf_file, command, path_output)
        if os.path.exists(path_output + command + "_total.tsv"):
            os.remove(path_output + command + "_total.tsv")
        list_tsv_VA_output = get_list_file(path_output, output_end_file, command)
        dataframe_VA_total = concate_dataframe(list_tsv_VA_output)
        dataframe_VA_total.to_csv(
            path_output + command + "_total.tsv", index=False, sep="\t", na_rep=".."
        )
    return
