// Include inside each module; deliberately no global include guard.
localparam TAPS = 21;
localparam DATA_WIDTH = 16;
localparam ACC_WIDTH = 37;
function signed [15:0] coeff;
    input integer index;
    begin
        case (index)
            0: coeff = 16'sd0;
            1: coeff = 16'sd113;
            2: coeff = 16'sd0;
            3: coeff = -16'sd389;
            4: coeff = 16'sd0;
            5: coeff = 16'sd1107;
            6: coeff = 16'sd0;
            7: coeff = -16'sd2797;
            8: coeff = 16'sd0;
            9: coeff = 16'sd10172;
            10: coeff = 16'sd16356;
            11: coeff = 16'sd10172;
            12: coeff = 16'sd0;
            13: coeff = -16'sd2797;
            14: coeff = 16'sd0;
            15: coeff = 16'sd1107;
            16: coeff = 16'sd0;
            17: coeff = -16'sd389;
            18: coeff = 16'sd0;
            19: coeff = 16'sd113;
            20: coeff = 16'sd0;
            default: coeff = 16'sd0;
        endcase
    end
endfunction
