`timescale 1ns/1ps
// ARCH: 0 = parallel, 1 = serial MAC, 2 = Xilinx FIR Compiler.
module main #(parameter ARCH = 0) (
    input wire clk, rst,
    input wire in_valid,
    output wire in_ready,
    input wire signed [15:0] x,
    output wire out_valid,
    output wire signed [36:0] y
);
    generate
        if (ARCH == 0) begin: parallel_design
            fir_parallel dut (clk, rst, in_valid, in_ready, x, out_valid, y);
        end else if (ARCH == 1) begin: serial_design
            fir_serial dut (clk, rst, in_valid, in_ready, x, out_valid, y);
        end else if (ARCH == 2) begin: systolic_design
            fir_vendor dut (clk, rst, in_valid, in_ready, x, out_valid, y);
        end
    endgenerate
endmodule
