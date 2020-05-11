library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library osvvm;
use osvvm.RandomPkg.all;

library work;
use work.fp_comp_pkg.all;

entity fp_comp_pkg_tb_vunit is
	generic (
        runner_cfg : string;
        output_path : string;
        C_NUM_TEST_INPUTS : positive := 100
        );
end entity;

architecture tb of fp_comp_pkg_tb_vunit is

    constant c_random_seed: string := tb'instance_name & "4";

    subtype mantisse_t is std_logic_vector(22 downto 0);
    subtype charakteristik_t is std_logic_vector(7 downto 0);
    subtype sign_t is std_logic_vector(0 downto 0);

    type mantisse_array_t is array (natural range <>) of std_logic_vector(22 downto 0);
    type charakteristik_array_t is array (natural range <>) of std_logic_vector(7 downto 0);
    type sign_array_t is array (natural range <>) of std_logic_vector(0 downto 0);
    type ieee_fp_array_t is array (natural range<>) of std_logic_vector(31 downto 0);
    
    constant c_man_values : mantisse_array_t := (
        b"000_0000_0000_0000_0000_0000",
        b"000_0000_0000_0000_0000_0001",
        b"111_1111_1111_1111_1111_1110",
        b"111_1111_1111_1111_1111_1111");
    constant c_char_values : charakteristik_array_t := (
        b"0000_0000",
        b"0000_0001",
        b"0111_1110",
        b"0111_1111",
        b"1000_0000",
        b"1111_1110",
        b"1111_1111");
    constant c_sign_values : sign_array_t := ("1", "0");

    impure function gen_fixed_float_list (
        sign_list : sign_array_t;
        char_list : charakteristik_array_t;
        man_list : mantisse_array_t
    ) return ieee_fp_array_t is

        constant c_res_array_len : positive := man_list'length * char_list'length * sign_list'length;
        variable v_result : ieee_fp_array_t(0 to c_res_array_len - 1);
        variable v_fp_idx : natural;

    begin
        v_fp_idx := 0;
        for sign_idx in 0 to sign_list'length - 1 loop
            for char_idx in 0 to char_list'length - 1 loop
                for man_idx in 0 to man_list'length - 1 loop                   
                    v_result(v_fp_idx) := sign_list(sign_idx) & char_list(char_idx) & man_list(man_idx);
                    v_fp_idx := v_fp_idx + 1;
                end loop;
            end loop;
        end loop;

        return v_result;
    end function;

    constant c_ieee_fp_fixed_list : ieee_fp_array_t := gen_fixed_float_list(c_sign_values, c_char_values, c_man_values);



	-- testbench config
 
    -- DUT config

	-- DUT inputs

    -- DUT outputs

    -- testbench

begin
    p_main : process

        variable v_RV : RandomPType;

        file f_results_file     : text;
        variable v_row          : line;

        variable v_result : boolean;

        variable v_flopoco_fp_a_slv  : std_logic_vector(31 downto 0);
        variable v_flopoco_fp_b_slv  : std_logic_vector(31 downto 0);
        variable v_ieee_fp_a_slv     : std_logic_vector(31 downto 0);
        variable v_ieee_fp_b_slv     : std_logic_vector(31 downto 0);

        variable v_fp_idx         : natural;

	begin
        test_runner_setup(runner, runner_cfg);

        v_RV.InitSeed(c_random_seed);

        while test_suite loop
            if run("ieee_fp_a_gt_b_fixed") then
                --------------------------------------------------
                -- Test description 
                --------------------------------------------------
                file_open(f_results_file, output_path & "results.dat", write_mode);

                write(v_row, string'("index, float A, float B, A > B, A > A"));
                writeline(f_results_file, v_row);

                v_fp_idx := 0;
                for fp_idx_a in 0 to c_ieee_fp_fixed_list'length - 1 loop
                    for fp_idx_b in 0 to c_ieee_fp_fixed_list'length - 1 loop
                        write(v_row, integer'image(v_fp_idx));
                        write(v_row, string'(", "));

                        v_ieee_fp_a_slv := c_ieee_fp_fixed_list(fp_idx_a);
                        v_ieee_fp_b_slv := c_ieee_fp_fixed_list(fp_idx_b);

                        write(v_row, string'("0x"));
                        hwrite(v_row, v_ieee_fp_a_slv);
                        write(v_row, string'(", 0x"));
                        hwrite(v_row, v_ieee_fp_b_slv);
                        write(v_row, string'(", "));

                        v_result := ieee_fp_a_gt_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                        write(v_row, boolean'image(v_result));

                        v_result := ieee_fp_a_gt_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                        write(v_row, string'(", "));
                        write(v_row, boolean'image(v_result));

                        writeline(f_results_file, v_row);

                        v_fp_idx := v_fp_idx + 1;
                    end loop;
                end loop;

                file_close(f_results_file);
            
            elsif run("ieee_fp_a_lt_b_fixed") then
                --------------------------------------------------
                -- Test description 
                --------------------------------------------------
                file_open(f_results_file, output_path & "results.dat", write_mode);

                write(v_row, string'("index, float A, float B, A < B, A < A"));
                writeline(f_results_file, v_row);

                v_fp_idx := 0;
                for fp_idx_a in 0 to c_ieee_fp_fixed_list'length - 1 loop
                    for fp_idx_b in 0 to c_ieee_fp_fixed_list'length - 1 loop
                        write(v_row, integer'image(v_fp_idx));
                        write(v_row, string'(", "));

                        v_ieee_fp_a_slv := c_ieee_fp_fixed_list(fp_idx_a);
                        v_ieee_fp_b_slv := c_ieee_fp_fixed_list(fp_idx_b);

                        write(v_row, string'("0x"));
                        hwrite(v_row, v_ieee_fp_a_slv);
                        write(v_row, string'(", 0x"));
                        hwrite(v_row, v_ieee_fp_b_slv);
                        write(v_row, string'(", "));

                        v_result := ieee_fp_a_lt_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                        write(v_row, boolean'image(v_result));

                        v_result := ieee_fp_a_lt_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                        write(v_row, string'(", "));
                        write(v_row, boolean'image(v_result));

                        writeline(f_results_file, v_row);

                        v_fp_idx := v_fp_idx + 1;
                    end loop;
                end loop;

                file_close(f_results_file);

            elsif run("ieee_fp_a_ge_b_fixed") then
                --------------------------------------------------
                -- Test description 
                --------------------------------------------------
                file_open(f_results_file, output_path & "results.dat", write_mode);

                write(v_row, string'("index, float A, float B, A >= B, A >= A"));
                writeline(f_results_file, v_row);

                v_fp_idx := 0;
                for fp_idx_a in 0 to c_ieee_fp_fixed_list'length - 1 loop
                    for fp_idx_b in 0 to c_ieee_fp_fixed_list'length - 1 loop
                        write(v_row, integer'image(v_fp_idx));
                        write(v_row, string'(", "));

                        v_ieee_fp_a_slv := c_ieee_fp_fixed_list(fp_idx_a);
                        v_ieee_fp_b_slv := c_ieee_fp_fixed_list(fp_idx_b);

                        write(v_row, string'("0x"));
                        hwrite(v_row, v_ieee_fp_a_slv);
                        write(v_row, string'(", 0x"));
                        hwrite(v_row, v_ieee_fp_b_slv);
                        write(v_row, string'(", "));

                        v_result := ieee_fp_a_ge_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                        write(v_row, boolean'image(v_result));

                        v_result := ieee_fp_a_ge_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                        write(v_row, string'(", "));
                        write(v_row, boolean'image(v_result));

                        writeline(f_results_file, v_row);

                        v_fp_idx := v_fp_idx + 1;
                    end loop;
                end loop;

                file_close(f_results_file);
            
            elsif run("ieee_fp_a_le_b_fixed") then
                --------------------------------------------------
                -- Test description 
                --------------------------------------------------
                file_open(f_results_file, output_path & "results.dat", write_mode);

                write(v_row, string'("index, float A, float B, A <= B, A <= A"));
                writeline(f_results_file, v_row);

                v_fp_idx := 0;
                for fp_idx_a in 0 to c_ieee_fp_fixed_list'length - 1 loop
                    for fp_idx_b in 0 to c_ieee_fp_fixed_list'length - 1 loop
                        write(v_row, integer'image(v_fp_idx));
                        write(v_row, string'(", "));

                        v_ieee_fp_a_slv := c_ieee_fp_fixed_list(fp_idx_a);
                        v_ieee_fp_b_slv := c_ieee_fp_fixed_list(fp_idx_b);

                        write(v_row, string'("0x"));
                        hwrite(v_row, v_ieee_fp_a_slv);
                        write(v_row, string'(", 0x"));
                        hwrite(v_row, v_ieee_fp_b_slv);
                        write(v_row, string'(", "));

                        v_result := ieee_fp_a_le_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                        write(v_row, boolean'image(v_result));

                        v_result := ieee_fp_a_le_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                        write(v_row, string'(", "));
                        write(v_row, boolean'image(v_result));

                        writeline(f_results_file, v_row);

                        v_fp_idx := v_fp_idx + 1;
                    end loop;
                end loop;

                file_close(f_results_file);

            elsif run("ieee_fp_a_gt_b_random") then

                file_open(f_results_file, output_path & "results.dat", write_mode);

                v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                write(v_row, string'("index, float A, float B, A > B, A > A"));
                writeline(f_results_file, v_row);
                for fp_idx in 0 to C_NUM_TEST_INPUTS-1 loop
                    write(v_row, integer'image(fp_idx));
                    write(v_row, string'(", "));

                    v_ieee_fp_a_slv := v_ieee_fp_b_slv;
                    v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                    write(v_row, string'("0x"));
                    hwrite(v_row, v_ieee_fp_a_slv);
                    write(v_row, string'(", 0x"));
                    hwrite(v_row, v_ieee_fp_b_slv);
                    write(v_row, string'(", "));

                    v_result := ieee_fp_a_gt_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                    write(v_row, boolean'image(v_result));

                    v_result := ieee_fp_a_gt_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                    write(v_row, string'(", "));
                    write(v_row, boolean'image(v_result));

                    writeline(f_results_file, v_row);

                end loop;

                file_close(f_results_file);

            elsif run("ieee_fp_a_lt_b_random") then

                file_open(f_results_file, output_path & "results.dat", write_mode);

                v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                write(v_row, string'("index, float A, float B, A < B, A < A"));
                writeline(f_results_file, v_row);

                for fp_idx in 0 to C_NUM_TEST_INPUTS-1 loop
                    write(v_row, integer'image(fp_idx));
                    write(v_row, string'(", "));

                    v_ieee_fp_a_slv := v_ieee_fp_b_slv;
                    v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                    write(v_row, string'("0x"));
                    hwrite(v_row, v_ieee_fp_a_slv);
                    write(v_row, string'(", 0x"));
                    hwrite(v_row, v_ieee_fp_b_slv);
                    write(v_row, string'(", "));

                    v_result := ieee_fp_a_lt_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                    write(v_row, boolean'image(v_result));

                    v_result := ieee_fp_a_lt_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                    write(v_row, string'(", "));
                    write(v_row, boolean'image(v_result));

                    writeline(f_results_file, v_row);

                end loop;

                file_close(f_results_file);

            elsif run("ieee_fp_a_ge_b_random") then

                file_open(f_results_file, output_path & "results.dat", write_mode);

                v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                write(v_row, string'("index, float A, float B, A >= B, A >= A"));
                writeline(f_results_file, v_row);

                for fp_idx in 0 to C_NUM_TEST_INPUTS-1 loop
                    write(v_row, integer'image(fp_idx));
                    write(v_row, string'(", "));

                    v_ieee_fp_a_slv := v_ieee_fp_b_slv;
                    v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                    write(v_row, string'("0x"));
                    hwrite(v_row, v_ieee_fp_a_slv);
                    write(v_row, string'(", 0x"));
                    hwrite(v_row, v_ieee_fp_b_slv);
                    write(v_row, string'(", "));

                    v_result := ieee_fp_a_ge_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                    write(v_row, boolean'image(v_result));

                    v_result := ieee_fp_a_ge_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                    write(v_row, string'(", "));
                    write(v_row, boolean'image(v_result));

                    writeline(f_results_file, v_row);

                end loop;

                file_close(f_results_file);

            elsif run("ieee_fp_a_le_b_random") then

                file_open(f_results_file, output_path & "results.dat", write_mode);

                v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                write(v_row, string'("index, float A, float B, A <= B, A <= A"));
                writeline(f_results_file, v_row);

                for fp_idx in 0 to C_NUM_TEST_INPUTS-1 loop
                    write(v_row, integer'image(fp_idx));
                    write(v_row, string'(", "));

                    v_ieee_fp_a_slv := v_ieee_fp_b_slv;
                    v_ieee_fp_b_slv := v_RV.RandSlv(std_logic_vector'(x"FFFF_FFFF"));

                    write(v_row, string'("0x"));
                    hwrite(v_row, v_ieee_fp_a_slv);
                    write(v_row, string'(", 0x"));
                    hwrite(v_row, v_ieee_fp_b_slv);
                    write(v_row, string'(", "));

                    v_result := ieee_fp_a_le_b(v_ieee_fp_a_slv, v_ieee_fp_b_slv);
                    write(v_row, boolean'image(v_result));

                    v_result := ieee_fp_a_le_b(v_ieee_fp_a_slv, v_ieee_fp_a_slv);
                    write(v_row, string'(", "));
                    write(v_row, boolean'image(v_result));

                    writeline(f_results_file, v_row);

                end loop;

                file_close(f_results_file);

            end if;
		end loop;

		test_runner_cleanup(runner); -- Simulation ends here

    end process p_main;

    p_timeout : process
    begin
        wait for 1 ms;
        check(false, "Whatchdog timeout");
    end process;


end architecture;

