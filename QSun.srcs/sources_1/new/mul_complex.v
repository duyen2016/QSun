`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2024 09:57:44 PM
// Design Name: 
// Module Name: mul_complex
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


module mul_complex(
    input clk,
    input [63:0] a, b,
    output [63:0] p
    );
    
    mult_gen_0 mult(
        .CLK(clk),
        .A(ext_manti_a),
        .B(ext_manti_b),
        .P(ext_manti_p)
    );    
    
    
endmodule
