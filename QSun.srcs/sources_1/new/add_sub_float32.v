`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2024 10:10:20 AM
// Design Name: 
// Module Name: add_sub_float32
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


module add_sub_float32(
    input clk, add,
    input [31:0] a, b,
    output [31:0] s
    );
    wire sign_a, sign_b, sign_s;
    wire [7:0] exp_a, exp_b, exp_s, exp_s_t;
    wire [22:0] manti_a, manti_b, manti_s;
    wire [25:0] ext_manti_a, ext_manti_b, ext_manti_s;
    assign sign_a = a[31];
    assign sign_b = b[31];
    assign ext_manti_a = {3'b001, manti_a};
    assign ext_manti_b = {3'b001, manti_b};
    assign exp_a = a[30:23];
    assign exp_b = b[30:23];
    assign manti_a = a[22:0];
    assign manti_b = b[22:0];
    wire signed [7:0] align = exp_a - exp_b;
    wire [25:0] align_manti_a, align_manti_b;
    assign align_manti_b = (align > 0) ? ext_manti_b >> align : ext_manti_b;
    assign align_manti_a = (align < 0) ? ext_manti_a >> (~(align-1'b1)) : ext_manti_a;
    wire [25:0] sign_manti_a, sign_manti_b, nor_manti_s;
    assign sign_manti_a = (sign_a) ? 26'b0 - align_manti_a : align_manti_a;
    assign sign_manti_b = (sign_b) ? 26'b0 - align_manti_b : align_manti_b;    
    c_addsub_0 add_sub(
    .A(sign_manti_a),
    .B(sign_manti_b),
    .CLK(clk),
    .ADD(add),
    .S(ext_manti_s)
     );
     assign sign_s = ext_manti_s[25];
     assign nor_manti_s = (sign_s)? 26'b0 - ext_manti_s : ext_manti_s;
     assign manti_s = (nor_manti_s[24]) ? nor_manti_s[23:1]: nor_manti_s[22:0];
     assign exp_s_t = (align > 0) ? exp_a : exp_b;
     assign exp_s = (nor_manti_s[24]) ? exp_s_t + 1'b1: exp_s_t;
     assign s = ((a == 32'b0) || (b == 32'b0))? a | b :{ sign_s, exp_s, manti_s};
endmodule
