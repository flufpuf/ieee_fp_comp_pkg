import sys
sys.path.append("../scripts")

from vunit import VUnit
from post_checks import check_ieee_fp_a_gt_b, check_ieee_fp_a_lt_b, check_ieee_fp_a_ge_b, check_ieee_fp_a_le_b

vu = VUnit.from_argv()

vu.add_osvvm()
vu.add_verification_components()
vu.add_json4vhdl()

lib = vu.add_library("lib")
lib.add_source_file("fp_comp_pkg_tb_vunit.vhd")
lib.add_source_file("../hdl/fp_comp_pkg.vhd")

tb = lib.test_bench("fp_comp_pkg_tb_vunit")

test = tb.test("ieee_fp_a_gt_b_fixed")
test.add_config("check", post_check=check_ieee_fp_a_gt_b)

test = tb.test("ieee_fp_a_lt_b_fixed")
test.add_config("check", post_check=check_ieee_fp_a_lt_b)

test = tb.test("ieee_fp_a_ge_b_fixed")
test.add_config("check", post_check=check_ieee_fp_a_ge_b)

test = tb.test("ieee_fp_a_le_b_fixed")
test.add_config("check", post_check=check_ieee_fp_a_le_b)

test = tb.test("ieee_fp_a_gt_b_random")
test.add_config("check", post_check=check_ieee_fp_a_gt_b)

test = tb.test("ieee_fp_a_lt_b_random")
test.add_config("check", post_check=check_ieee_fp_a_lt_b)

test = tb.test("ieee_fp_a_ge_b_random")
test.add_config("check", post_check=check_ieee_fp_a_ge_b)

test = tb.test("ieee_fp_a_le_b_random")
test.add_config("check", post_check=check_ieee_fp_a_le_b)

vu.main()