`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2026 01:46:46 PM
// Design Name: 
// Module Name: main_partII
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_partII( 

    );
    
    // Create an n-input adder
    // h[n]: stored constants
    // x[n]: shift register
    // one multiplier tap
    
// Create a list of stored constants
parameter N = 20; // Amount of samples
reg [7:0] h [N-1:0]; // Twenty different constants up to 8 bits
reg [8:0] x; // Shift register

initial begin
    h[0]    = 8'h01;
    h[1]    = 8'h02;
    h[2]    = 8'h04;
    h[3]    = 8'h08;
    h[4]    = 8'h0F;
    h[5]    = 8'hF0;
    
    h[6]    = 8'h10;
    h[7]    = 8'h20;
    h[8]    = 8'h40;
    h[9]    = 8'h80;
    h[10]   = 8'hF0;
    
    h[11]   = 8'h11;
    h[12]   = 8'h22;
    h[13]   = 8'h44;
    h[14]   = 8'h88;
    h[15]   = 8'hFF;
    
    h[16]   = 8'h01;
    h[17]   = 8'h03;
    h[18]   = 8'h0A;
    h[19]   = 8'h0C;
end
endmodule


module mux_4to1_assign (
  input  [3:0] a,     // Data input, selected when sel = 2'b00
  input  [3:0] b,     // Data input, selected when sel = 2'b01
  input  [3:0] c,     // Data input, selected when sel = 2'b10
  input  [3:0] d,     // Data input, selected when sel = 2'b11
  input  [1:0] sel,   // 2-bit select: 4 combinations for 4 inputs
  output [3:0] out    // Selected data; a wire because assign drives it
);

  // Outer ternary: sel[1] chooses the upper pair (c/d) or the lower pair (a/b)
  // Inner ternaries: sel[0] chooses one input within the chosen pair
  assign out = sel[1] ? (sel[0] ? d : c)
                      : (sel[0] ? b : a);

endmodule

// Shift register logic
//    always @(posedge clk) begin
//        if (rst)
//            q <= 4'b0000;
//        else
//            q <= {q[2:0], serial_in};
//    end