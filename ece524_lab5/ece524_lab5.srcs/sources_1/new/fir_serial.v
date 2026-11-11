`timescale 1ns/1ps
// One multiplier and adder; accepts one input every 21 clocks.
module fir_serial (
    input wire clk, rst,
    input wire in_valid,
    output wire in_ready,
    input wire signed [15:0] x,
    output reg out_valid,
    output reg signed [36:0] y
);
    `include "fir_defs.vh"
    reg signed [15:0] history [0:TAPS-1];
    reg busy = 0;
    reg [4:0] tap_index = 0;
    reg signed [36:0] accumulator = 0;
    wire signed [15:0] operand;
    wire signed [31:0] product;
    wire signed [36:0] addend, mac;
    integer j;
    initial begin
        for (j=0; j<TAPS; j=j+1) history[j] = 0;
    end
    assign in_ready = ~busy & ~rst;
    assign operand = busy ? history[tap_index] : x;
    assign product = operand * coeff(tap_index);
    assign addend = busy ? accumulator : 37'sd0;
    assign mac = addend + {{5{product[31]}}, product};
    always @(posedge clk) begin
        if (rst) begin
            for (j=0; j<TAPS; j=j+1) history[j] <= 0;
            accumulator <= 0;
            y <= 0;
            busy <= 0;
            tap_index <= 0;
            out_valid <= 0;
        end else begin
            out_valid <= 0;
            if (!busy) begin
                if (in_valid) begin
                    history[0] <= x;
                    for (j=1; j<TAPS; j=j+1) history[j] <= history[j-1];
                    accumulator <= mac;
                    tap_index <= 1;
                    busy <= 1;
                end
            end else begin
                accumulator <= mac;
                if (tap_index == TAPS-1) begin
                    y <= mac;
                    out_valid <= 1;
                    busy <= 0;
                    tap_index <= 0;
                end else tap_index <= tap_index + 1'b1;
            end
        end
    end
endmodule
