`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2024 08:58:01 AM
// Design Name: 
// Module Name: mult_float32
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


module mult_float32(
    input clk,
    input [31:0] a, b,
    output [31:0] p
    );
    
    wire sign_a, sign_b, sign_p;
    wire [7:0] exp_a, exp_b, exp_p, exp_p_t;
    wire [22:0] manti_a, manti_b, manti_p;
    wire [23:0] ext_manti_a, ext_manti_b;
    wire [24:0] ext_manti_p;
    assign sign_a = a[31];
    assign sign_b = b[31];
    assign exp_a = a[30:23];
    assign exp_b = b[30:23];
    assign manti_a = a[22:0];
    assign manti_b = b[22:0];
    assign ext_manti_a = {1'b1, manti_a};
    assign ext_manti_b = {1'b1, manti_b};
    assign sign_p = sign_a ^ sign_b;
    assign exp_p_t = exp_a + exp_b;
    mult_gen_0 mult(
    .CLK(clk),
    .A(ext_manti_a),
    .B(ext_manti_b),
    .P(ext_manti_p));
    
    assign manti_p = (ext_manti_p[24])? ext_manti_p[23:1]: ext_manti_p[22:0];
    assign exp_p = (ext_manti_p[24])? exp_p_t - 8'd126 : exp_p_t - 8'd127;
    assign p = ((a == 32'b0) || (b == 32'b0))? 0:{ sign_p, exp_p, manti_p};
endmodule
