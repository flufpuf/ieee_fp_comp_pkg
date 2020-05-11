import numpy as np
import struct
import os
import csv

def hex_to_ieee_fp(hex_str):

    hex_str = hex_str.strip()
    
    if hex_str[0:2] in ["0x", "0X"]:
        hex_str = hex_str[2:]

    return struct.unpack(">f", bytes.fromhex(hex_str))[0]

def str_to_bool(bool_str):
    if bool_str.strip() in ["true", "True", "1", "0x1"]:
        return True
    elif bool_str.strip() in ["false", "False", "0", "0x0"]:
        return False

def check_ieee_fp_a_gt_b(output_path):

    test_successful = True

    with open(os.path.join(output_path, "results.dat"), 'r') as res_file:
        results_data = csv.reader(res_file)
    
        next(results_data, None) # skip header

        for row in results_data:
            idx = int(row[0].strip())

            fp_a = hex_to_ieee_fp(row[1])
            fp_b = hex_to_ieee_fp(row[2])

            result = str_to_bool(row[3])
            
            if (fp_a > fp_b) != result:
                test_successful = False
                print("index={}: {} > {} = {} not correct!".format(idx, fp_a, fp_b, result))
            
            result = str_to_bool(row[4])

            if (fp_a > fp_a) != result:
                test_successful = False
                print("index={}: {} > {} = {} not correct!".format(idx, fp_a, fp_a, result))
            

    return test_successful

def check_ieee_fp_a_lt_b(output_path):

    test_successful = True

    with open(os.path.join(output_path, "results.dat"), 'r') as res_file:
        results_data = csv.reader(res_file)
    
        next(results_data, None) # skip header

        for row in results_data:
            idx = int(row[0].strip())

            fp_a = hex_to_ieee_fp(row[1])
            fp_b = hex_to_ieee_fp(row[2])

            result = str_to_bool(row[3])
            
            if (fp_a < fp_b) != result:
                test_successful = False
                print("index={}: {} < {} = {} not correct!".format(idx, fp_a, fp_b, result))
            
            result = str_to_bool(row[4])

            if (fp_a < fp_a) != result:
                test_successful = False
                print("index={}: {} < {} = {} not correct!".format(idx, fp_a, fp_a, result))
            

    return test_successful

def check_ieee_fp_a_ge_b(output_path):

    test_successful = True

    with open(os.path.join(output_path, "results.dat"), 'r') as res_file:
        results_data = csv.reader(res_file)
    
        next(results_data, None) # skip header

        for row in results_data:
            idx = int(row[0].strip())

            fp_a = hex_to_ieee_fp(row[1])
            fp_b = hex_to_ieee_fp(row[2])

            result = str_to_bool(row[3])
            
            if (fp_a >= fp_b) != result:
                test_successful = False
                print("index={}: {} >= {} = {} not correct!".format(idx, fp_a, fp_b, result))
            
            result = str_to_bool(row[4])

            if (fp_a >= fp_a) != result:
                test_successful = False
                print("index={}: {} >= {} = {} not correct!".format(idx, fp_a, fp_a, result))

    return test_successful

def check_ieee_fp_a_le_b(output_path):

    test_successful = True

    with open(os.path.join(output_path, "results.dat"), 'r') as res_file:
        results_data = csv.reader(res_file)
    
        next(results_data, None) # skip header

        for row in results_data:
            idx = int(row[0].strip())

            fp_a = hex_to_ieee_fp(row[1])
            fp_b = hex_to_ieee_fp(row[2])

            result = str_to_bool(row[3])
            
            if (fp_a <= fp_b) != result:
                test_successful = False
                print("index={}: {} <= {} = {} not correct!".format(idx, fp_a, fp_b, result))
            
            result = str_to_bool(row[4])

            if (fp_a <= fp_a) != result:
                test_successful = False
                print("index={}: {} <= {} = {} not correct!".format(idx, fp_a, fp_a, result))

    return test_successful