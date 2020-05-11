import numpy as np
import struct

def unpack_float_bytes(fp_bytes):
    int_bytes = struct.unpack('>I', fp_bytes)[0]
    sign = (int_bytes & 1 << 31) > 0
    uint = int_bytes
    if sign:
        uint -= 2**31
    
    characteristic = (int_bytes & (2**8-1) << 23) >> 23
    mantisse = int_bytes & (2**23-1)

    return sign, characteristic, mantisse, uint

def fp_comp_a_gt_b(fp_a_bytes, fp_b_bytes):
    sign_a, char_a, man_a, uint_a = unpack_float_bytes(fp_a_bytes)
    sign_b, char_b, man_b, uint_b = unpack_float_bytes(fp_b_bytes)

    if char_a == 2**8-1 and man_a > 0: # fp_a is NaN
        result = False
    elif char_b == 2**8-1 and man_b > 0: # fp_b is NaN
        result = False
    elif uint_a == 0 and uint_b == 0: # both zero
        result = False
    elif sign_a != sign_b:
        if sign_b:
            result = True
        else:
            result = False
    else:
        if char_a == 2**8-1 and char_b == 2**8-1: # both are infinite with same sign
            result = False
        elif sign_a: # both negative
            result = uint_a < uint_b
        else: # both positive
            result = uint_a > uint_b
    
    return result

def fp_comp_a_lt_b(fp_a_bytes, fp_b_bytes):
    sign_a, char_a, man_a, uint_a = unpack_float_bytes(fp_a_bytes)
    sign_b, char_b, man_b, uint_b = unpack_float_bytes(fp_b_bytes)

    if char_a == 2**8-1 and man_a > 0: # fp_a is NaN
        result = False
    elif char_b == 2**8-1 and man_b > 0: # fp_b is NaN
        result = False
    elif uint_a == 0 and uint_b == 0: # both zero
        result = False
    elif sign_a != sign_b:
        if sign_a:
            result = True
        else:
            result = False
    else:
        if char_a == 2**8-1 and char_b == 2**8-1: # both are infinite with same sign
            result = False
        elif sign_a: # both negative
            result = uint_a > uint_b
        else: # both positive
            result = uint_a < uint_b
    
    return result

def fp_comp_a_ge_b(fp_a_bytes, fp_b_bytes):
    sign_a, char_a, man_a, uint_a = unpack_float_bytes(fp_a_bytes)
    sign_b, char_b, man_b, uint_b = unpack_float_bytes(fp_b_bytes)

    if char_a == 2**8-1 and man_a > 0: # fp_a is NaN
        result = False
    elif char_b == 2**8-1 and man_b > 0: # fp_b is NaN
        result = False
    elif uint_a == 0 and uint_b == 0: # both zero
        result = True
    elif sign_a != sign_b:
        if sign_b:
            result = True
        else:
            result = False
    else:
        if char_a == 2**8-1 and char_b == 2**8-1: # both are infinite with same sign
            result = False
        elif sign_a: # both negative
            result = uint_a <= uint_b
        else: # both positive
            result = uint_a >= uint_b
    
    return result

def fp_comp_a_le_b(fp_a_bytes, fp_b_bytes):
    sign_a, char_a, man_a, uint_a = unpack_float_bytes(fp_a_bytes)
    sign_b, char_b, man_b, uint_b = unpack_float_bytes(fp_b_bytes)

    if char_a == 2**8-1 and man_a > 0: # fp_a is NaN
        result = False
    elif char_b == 2**8-1 and man_b > 0: # fp_b is NaN
        result = False
    elif uint_a == 0 and uint_b == 0: # both zero
        result = True
    elif sign_a != sign_b:
        if sign_a:
            result = True
        else:
            result = False
    else:
        if char_a == 2**8-1 and char_b == 2**8-1: # both are infinite with same sign
            result = False
        elif sign_a: # both negative
            result = uint_a >= uint_b
        else: # both positive
            result = uint_a <= uint_b
    
    return result



fp_b_bytes = np.random.bytes(4)

for idx in range(25000000):
    fp_a_bytes = fp_b_bytes
    fp_b_bytes = np.random.bytes(4)

    fp_a = struct.unpack('>f', fp_a_bytes)[0]
    fp_b = struct.unpack('>f', fp_b_bytes)[0]

    sign_a, char_a, man_a, uint_a = unpack_float_bytes(fp_a_bytes)
    sign_b, char_b, man_b, uint_b = unpack_float_bytes(fp_b_bytes)

    if fp_comp_a_gt_b(fp_a_bytes, fp_b_bytes) != (fp_a > fp_b):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("B: {}: {} {} {} {}".format(fp_b, sign_b, char_b, man_b, uint_b))
        print("A > B: {}".format(fp_comp_a_gt_b(fp_a_bytes, fp_b_bytes)))
    
    if fp_comp_a_gt_b(fp_a_bytes, fp_a_bytes) != (fp_a > fp_a):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("A > A: {}".format(fp_comp_a_gt_b(fp_a_bytes, fp_a_bytes)))
    
    if fp_comp_a_lt_b(fp_a_bytes, fp_b_bytes) != (fp_a < fp_b):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("B: {}: {} {} {} {}".format(fp_b, sign_b, char_b, man_b, uint_b))
        print("A < B: {}".format(fp_comp_a_lt_b(fp_a_bytes, fp_b_bytes)))
    
    if fp_comp_a_lt_b(fp_a_bytes, fp_a_bytes) != (fp_a < fp_a):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("A < A: {}".format(fp_comp_a_lt_b(fp_a_bytes, fp_a_bytes)))
    
    if fp_comp_a_ge_b(fp_a_bytes, fp_b_bytes) != (fp_a >= fp_b):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("B: {}: {} {} {} {}".format(fp_b, sign_b, char_b, man_b, uint_b))
        print("A >= B: {}".format(fp_comp_a_ge_b(fp_a_bytes, fp_b_bytes)))

    if fp_comp_a_ge_b(fp_a_bytes, fp_a_bytes) != (fp_a >= fp_a):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("A >= A: {}".format(fp_comp_a_ge_b(fp_a_bytes, fp_a_bytes)))
    
    if fp_comp_a_le_b(fp_a_bytes, fp_b_bytes) != (fp_a <= fp_b):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("B: {}: {} {} {} {}".format(fp_b, sign_b, char_b, man_b, uint_b))
        print("A <= B: {}".format(fp_comp_a_le_b(fp_a_bytes, fp_b_bytes)))
    
    if fp_comp_a_le_b(fp_a_bytes, fp_a_bytes) != (fp_a <= fp_a):
        print("error at index {}".format(idx))
        print("A: {}: {} {} {} {}".format(fp_a, sign_a, char_a, man_a, uint_a))
        print("A <= A: {}".format(fp_comp_a_le_b(fp_a_bytes, fp_a_bytes)))
