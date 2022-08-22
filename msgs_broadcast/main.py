#! /usr/bin/python

from operator import index
from textwrap import indent
import pandas as pd
import os
import sys
import json
import argparse
import datetime

gas_default = 0
message = {
    "body": {
        "messages": [
        ],
        "memo": "",
        "timeout_height": "0",
        "extension_options": [],
        "non_critical_extension_options": []
    },
    "auth_info": {
        "signer_infos": [],
        "fee": {
            "amount": [],
            "gas_limit": "108997",
            "payer": "",
            "granter": ""
        }
    },
    "signatures": []
}


# READ sample csv
def read_csv(file_path):
    if not os.path.exists(file_path):
        print(f"File is not found %s", file_path)
        sys.exit(0)

    return pd.read_csv(file_path)


def write_file(file_path, data):
    with open(file_path, "w") as f:
        json.dump(data, f)
    print(f"[!] file writed successfully %s", file_path)


def gen_unsig_mesg_delegate(args):
    from_addr = args.from_addr
    granter_addr = args.granter

    df = read_csv(args.infile)
    row_count, _ = df.shape
    # automate gas calculation for delegaiton is 108997
    gas_default = row_count * 108997
    for row_index in range(0, row_count):
        msg_dict = dict(
            {
                "@type": "/cosmos.staking.v1beta1.MsgDelegate",
                "delegator_address": from_addr,
                "validator_address":  df["validator_address"][row_index],
                "amount": {
                    "denom": "stake",
                    "amount": str(df["amount"][row_index])
                }
            }
        )
        message["body"]["messages"].append(msg_dict)

    if granter_addr is not None:
        message["auth_info"]["fee"]["granter"] = granter_addr

    if args.memo is not None:
        message["body"]["memo"] = args.memo

    message["auth_info"]["fee"]["gas_limit"] = str(gas_default)

    output_file = "unsigned_sign_{}.json".format(
        datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
    if args.output is not None:
        output_file = args.output
    # Write ouput to ...
    write_file(output_file, message)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("infile", help="input csv file", type=str)
    parser.add_argument("--from_addr", help="from address", type=str)
    parser.add_argument("--granter", help="granter address", type=str)
    parser.add_argument("--memo", help="memo", type=str)
    parser.add_argument("--output", help="output file", type=str)

    args = parser.parse_args()
    if args.infile is None:
        print("[X] input csv file is required")
        sys.exit(1)
    if args.from_addr is None:
        print("[X] from address is required")
        sys.exit(1)
    gen_unsig_mesg_delegate(args)
