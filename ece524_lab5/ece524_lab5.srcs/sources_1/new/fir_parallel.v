`timescale 1ns/1ps
// One product per tap, balanced adder tree, registered output.
module fir_parallel (
    input wire clk, rst,
    input wire in_valid,
    output wire in_ready,
    input wire signed [15:0] x,
    output reg out_valid,
    output reg signed [36:0] y
);
    `include "fir_defs.vh"
    reg signed [15:0] history [0:TAPS-2];
    wire signed [36:0] tree [1:63];
    wire signed [31:0] product [0:TAPS-1];
    integer j;
    initial begin
        for (j=0; j<TAPS-1; j=j+1) history[j] = 0;
    end
    assign in_ready = ~rst;
    assign product[0] = x * coeff(0);
    assign tree[32] = {{5{product[0][31]}}, product[0]};
    genvar i;
    generate
        for (i=1; i<TAPS; i=i+1) begin: products
            assign product[i] = history[i-1] * coeff(i);
            assign tree[32+i] = {{5{product[i][31]}}, product[i]};
        end
        for (i=TAPS; i<32; i=i+1) begin: padding
            assign tree[32+i] = 37'sd0;
        end
        for (i=1; i<32; i=i+1) begin: sums
            assign tree[i] = tree[2*i] + tree[2*i+1];
        end
    endgenerate
    always @(posedge clk) begin
        if (rst) begin
            for (j=0; j<TAPS-1; j=j+1) history[j] <= 0;
            out_valid <= 0;
            y <= 0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                history[0] <= x;
                for (j=1; j<TAPS-1; j=j+1) history[j] <= history[j-1];
                y <= tree[1];
            end
        end
    end
endmodule
