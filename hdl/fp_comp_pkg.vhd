library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fp_comp_pkg is

    function ieee_fp_a_gt_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean;
    
    function ieee_fp_a_lt_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean;
    
    function ieee_fp_a_ge_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean;
                            
    function ieee_fp_a_le_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean;

    function ieee_fp_is_nan  (fp : std_logic_vector(31 downto 0)) return boolean;
    function ieee_fp_is_zero (fp : std_logic_vector(31 downto 0)) return boolean;
    function ieee_fp_is_inf  (fp : std_logic_vector(31 downto 0)) return boolean;
    function ieee_fp_is_pos  (fp : std_logic_vector(31 downto 0)) return boolean;
    function ieee_fp_is_neg  (fp : std_logic_vector(31 downto 0)) return boolean;

end package;

package body fp_comp_pkg is
    type ieee_fp_32_fields_t is record
        sign    : std_logic_vector(0 downto 0);
        char    : std_logic_vector(7 downto 0);
        man     : std_logic_vector(22 downto 0);
    end record;

    type ieee_fp_32_t is record
        sign            : std_logic_vector(0 downto 0);
        char            : std_logic_vector(7 downto 0);
        man             : std_logic_vector(22 downto 0);
        as_unsigned     : unsigned(30 downto 0);
        is_nan          : boolean;
        is_zero         : boolean;
        is_inf          : boolean;
        is_neg          : boolean;
        is_pos          : boolean;
    end record;

    function ieee_fp_32_fields (slv : std_logic_vector(31 downto 0)) return ieee_fp_32_fields_t is
        variable v_result    : ieee_fp_32_fields_t;
    begin
        v_result.sign     := slv(31 downto 31);
        v_result.char     := slv(30 downto 23);
        v_result.man      := slv(22 downto 0);

        return v_result;
    end function;

    function ieee_fp_is_nan (fp : std_logic_vector(31 downto 0)) return boolean is
        constant c_fp          : ieee_fp_32_fields_t := ieee_fp_32_fields(fp);
        constant c_man_zero    : std_logic_vector(22 downto 0) := (others=>'0');

        variable v_result : boolean;
    begin
        if c_fp.char = "11111111" and c_fp.man /= c_man_zero then
            v_result := true;
        else
            v_result := false;
        end if;

        return v_result;

    end function;

    function ieee_fp_is_zero (fp : std_logic_vector(31 downto 0)) return boolean is
        constant c_fp          : ieee_fp_32_fields_t := ieee_fp_32_fields(fp);
        constant c_man_zero    : std_logic_vector(22 downto 0) := (others=>'0');

        variable v_result : boolean;
    begin
        if c_fp.char = "00000000" and c_fp.man = c_man_zero then
            v_result := true;
        else
            v_result := false;
        end if;

        return v_result;

    end function;

    function ieee_fp_is_inf (fp : std_logic_vector(31 downto 0)) return boolean is
        constant c_fp          : ieee_fp_32_fields_t := ieee_fp_32_fields(fp);
        constant c_man_zero    : std_logic_vector(22 downto 0) := (others=>'0');

        variable v_result : boolean;
    begin
        if c_fp.char = "11111111" and c_fp.man = c_man_zero then
            v_result := true;
        else
            v_result := false;
        end if;

        return v_result;

    end function;

    function ieee_fp_is_neg (fp : std_logic_vector(31 downto 0)) return boolean is
        constant c_fp          : ieee_fp_32_fields_t := ieee_fp_32_fields(fp);

        variable v_result : boolean;
    begin
        v_result := c_fp.sign = "1";

        return v_result;

    end function;

    function ieee_fp_is_pos (fp : std_logic_vector(31 downto 0)) return boolean is
        constant c_fp          : ieee_fp_32_fields_t := ieee_fp_32_fields(fp);

        variable v_result : boolean;
    begin
        v_result := c_fp.sign = "0";

        return v_result;

    end function;

    function slv_to_ieee_fp_32 (slv : std_logic_vector(31 downto 0)) return ieee_fp_32_t is

        constant v_fp_fields : ieee_fp_32_fields_t := ieee_fp_32_fields(slv);

        variable v_result    : ieee_fp_32_t;
    begin
        v_result.sign        := v_fp_fields.sign;
        v_result.char        := v_fp_fields.char;
        v_result.man         := v_fp_fields.man;
        v_result.as_unsigned := unsigned(v_fp_fields.char & v_fp_fields.man);
        v_result.is_nan      := ieee_fp_is_nan(slv);
        v_result.is_zero     := ieee_fp_is_zero(slv);
        v_result.is_inf      := ieee_fp_is_inf(slv);
        v_result.is_pos      := ieee_fp_is_pos(slv);
        v_result.is_neg      := ieee_fp_is_neg(slv);

        return v_result;
    end function;

    function ieee_fp_a_gt_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean is
        
        constant c_fp_a          : ieee_fp_32_t := slv_to_ieee_fp_32(fp_a);
        constant c_fp_b          : ieee_fp_32_t := slv_to_ieee_fp_32(fp_b);

        variable v_result        : boolean := false;
    begin

        if c_fp_a.is_nan then
            v_result := false;
        elsif c_fp_b.is_nan then
            v_result := false;
        elsif c_fp_a.is_zero and c_fp_b.is_zero then
            v_result := false;
        elsif c_fp_a.sign /= c_fp_b.sign then
            if c_fp_b.is_neg then
                v_result := true;
            else
                v_result := false;
            end if;
        else
            if c_fp_a.is_inf and c_fp_b.is_inf then -- both are infinite with same sign
                v_result := false;
            elsif c_fp_a.is_neg then -- both negative
                v_result := c_fp_a.as_unsigned < c_fp_b.as_unsigned;
            else -- both positive
                v_result := c_fp_a.as_unsigned > c_fp_b.as_unsigned;
            end if;
        end if;

        return v_result;

    end function;

    function ieee_fp_a_lt_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean is
        variable v_fp_a_sign     : std_logic;
        variable v_fp_a_char     : std_logic_vector(7 downto 0); -- charakteristik
        variable v_fp_a_man      : std_logic_vector(22 downto 0); -- mantisse
        variable v_fp_a_uint     : unsigned(30 downto 0); -- float interpreted as unsigned int

        variable v_fp_b_sign     : std_logic;
        variable v_fp_b_char     : std_logic_vector(7 downto 0); -- charakteristik
        variable v_fp_b_man      : std_logic_vector(22 downto 0); -- mantisse
        variable v_fp_b_uint     : unsigned(30 downto 0); -- float interpreted as unsigned int

        variable v_result        : boolean := false;

        constant c_man_zero    : std_logic_vector(22 downto 0) := (others=>'0');

    begin

        v_fp_a_sign  := fp_a(31);
        v_fp_a_char  := fp_a(30 downto 23);
        v_fp_a_man   := fp_a(22 downto 0);
        v_fp_a_uint  := unsigned(fp_a(30 downto 0));

        v_fp_b_sign  := fp_b(31);
        v_fp_b_char  := fp_b(30 downto 23);
        v_fp_b_man   := fp_b(22 downto 0);
        v_fp_b_uint  := unsigned(fp_b(30 downto 0));

        if v_fp_a_char = "11111111" and v_fp_a_man /= c_man_zero then -- fp_a is NaN
            v_result := false;
        elsif v_fp_b_char = "11111111" and v_fp_b_man /= c_man_zero then -- fp_b is NaN
            v_result := false;
        elsif v_fp_a_uint = 0 and v_fp_b_uint = 0 then -- both zero
            v_result := false;
        elsif v_fp_a_sign /= v_fp_b_sign then
            if v_fp_b_sign = '1' then -- fp_b is negative
                v_result := false;
            else -- fp_a is negative
                v_result := true;
            end if;
        else
            if v_fp_a_char = "11111111" and v_fp_b_char = "11111111" then -- both are infinite with same sign
                v_result := false;
            elsif v_fp_a_sign = '1' then -- both negative
                v_result := v_fp_a_uint > v_fp_b_uint;
            else -- both positive
                v_result := v_fp_a_uint < v_fp_b_uint;
            end if;
        end if;

        return v_result;

    end function;

    function ieee_fp_a_ge_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean is
        variable v_fp_a_sign     : std_logic;
        variable v_fp_a_char     : std_logic_vector(7 downto 0); -- charakteristik
        variable v_fp_a_man      : std_logic_vector(22 downto 0); -- mantisse
        variable v_fp_a_uint     : unsigned(30 downto 0); -- float interpreted as unsigned int

        variable v_fp_b_sign     : std_logic;
        variable v_fp_b_char     : std_logic_vector(7 downto 0); -- charakteristik
        variable v_fp_b_man      : std_logic_vector(22 downto 0); -- mantisse
        variable v_fp_b_uint     : unsigned(30 downto 0); -- float interpreted as unsigned int

        variable v_result        : boolean := false;

        constant c_man_zero    : std_logic_vector(22 downto 0) := (others=>'0');

    begin

        v_fp_a_sign  := fp_a(31);
        v_fp_a_char  := fp_a(30 downto 23);
        v_fp_a_man   := fp_a(22 downto 0);
        v_fp_a_uint  := unsigned(fp_a(30 downto 0));

        v_fp_b_sign  := fp_b(31);
        v_fp_b_char  := fp_b(30 downto 23);
        v_fp_b_man   := fp_b(22 downto 0);
        v_fp_b_uint  := unsigned(fp_b(30 downto 0));

        if v_fp_a_char = "11111111" and v_fp_a_man /= c_man_zero then -- fp_a is NaN
            v_result := false;
        elsif v_fp_b_char = "11111111" and v_fp_b_man /= c_man_zero then -- fp_b is NaN
            v_result := false;
        elsif v_fp_a_uint = 0 and v_fp_b_uint = 0 then -- both zero
            v_result := true;
        elsif v_fp_a_sign /= v_fp_b_sign then
            if v_fp_b_sign = '1' then -- fp_b is negative
                v_result := true;
            else -- fp_a is negative
                v_result := false;
            end if;
        else
            if v_fp_a_char = "11111111" and v_fp_b_char = "11111111" then -- both are infinite with same sign
                v_result := true;
            elsif v_fp_a_sign = '1' then -- both negative
                v_result := v_fp_a_uint <= v_fp_b_uint;
            else -- both positive
                v_result := v_fp_a_uint >= v_fp_b_uint;
            end if;
        end if;

        return v_result;

    end function;

    function ieee_fp_a_le_b (fp_a : std_logic_vector(31 downto 0);
                             fp_b : std_logic_vector(31 downto 0))
                             return boolean is
        variable v_fp_a_sign     : std_logic;
        variable v_fp_a_char     : std_logic_vector(7 downto 0); -- charakteristik
        variable v_fp_a_man      : std_logic_vector(22 downto 0); -- mantisse
        variable v_fp_a_uint     : unsigned(30 downto 0); -- float interpreted as unsigned int

        variable v_fp_b_sign     : std_logic;
        variable v_fp_b_char     : std_logic_vector(7 downto 0); -- charakteristik
        variable v_fp_b_man      : std_logic_vector(22 downto 0); -- mantisse
        variable v_fp_b_uint     : unsigned(30 downto 0); -- float interpreted as unsigned int

        variable v_result        : boolean := false;

        constant c_man_zero    : std_logic_vector(22 downto 0) := (others=>'0');

    begin

        v_fp_a_sign  := fp_a(31);
        v_fp_a_char  := fp_a(30 downto 23);
        v_fp_a_man   := fp_a(22 downto 0);
        v_fp_a_uint  := unsigned(fp_a(30 downto 0));

        v_fp_b_sign  := fp_b(31);
        v_fp_b_char  := fp_b(30 downto 23);
        v_fp_b_man   := fp_b(22 downto 0);
        v_fp_b_uint  := unsigned(fp_b(30 downto 0));

        if v_fp_a_char = "11111111" and v_fp_a_man /= c_man_zero then -- fp_a is NaN
            v_result := false;
        elsif v_fp_b_char = "11111111" and v_fp_b_man /= c_man_zero then -- fp_b is NaN
            v_result := false;
        elsif v_fp_a_uint = 0 and v_fp_b_uint = 0 then -- both zero
            v_result := true;
        elsif v_fp_a_sign /= v_fp_b_sign then
            if v_fp_b_sign = '1' then -- fp_b is negative
                v_result := false;
            else -- fp_a is negative
                v_result := true;
            end if;
        else
            if v_fp_a_char = "11111111" and v_fp_b_char = "11111111" then -- both are infinite with same sign
                v_result := true;
            elsif v_fp_a_sign = '1' then -- both negative
                v_result := v_fp_a_uint >= v_fp_b_uint;
            else -- both positive
                v_result := v_fp_a_uint <= v_fp_b_uint;
            end if;
        end if;

        return v_result;

    end function;

end package body;
