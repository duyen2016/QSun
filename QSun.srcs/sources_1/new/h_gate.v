`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2024 10:03:59 AM
// Design Name: 
// Module Name: h_gate
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


module h_gate #(parameter QULEN = 2, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [64 * QUDEEP - 1 : 0] amplitude,
    input [ QULEN - 1 : 0] n,
    output [64 * QUDEEP - 1 : 0] newamplitude,
    output reg validout
    );
    parameter [31:0] inverse_sqrt_2 = 32'h3f3504f3;
    reg [63:0] amp [ QUDEEP-1:0];
    reg [63:0] newamp [ QUDEEP-1:0];
    wire [ QULEN - 1 : 0] cut = 1<<( QULEN-n-1);
    genvar i;
    generate
    for (i = 0; i< QUDEEP; i = i+1) begin
//        assign amp[i] = (validin)? :0;
        always @(validin, rst) begin
            if (validin) begin
                amp[i] <= amplitude[ 64*(i+1)-1 : 64*i];
            end
            else if (rst) amp[i] <= 0; 
            else amp[i] <= amp[i];
        end
        assign newamplitude[ 64*(i+1)-1 : 64*i] =  (validout) ? newamp[i]:0;
    end
    endgenerate
    generate
    for (i = 0; i< QUDEEP; i = i+1) begin
        always @(rst) begin
            if (rst) newamp[i] <= 0;
        end
    end
    endgenerate
    reg [ QULEN - 1 : 0] state, state_n, state_d1, state_d2, state_cut, state_cut_d1, state_d3, state_cut_d2;
    always @(posedge clk) begin
        state <= state_n;
    end
    always @(validin, state) begin
        if (validin) state_n = 0;
        else if (state < QUDEEP - 1) state_n = state + 1;
        else state_n = state;
        if (state == QUDEEP-1) validout <= 1'b1;
    end
    wire [31:0] p_real, p_imag;
    reg [31:0] min_real, min_imag, asin_real_0, asin_imag_0, asin_real_1, asin_imag_1;
    reg add;
    wire [31:0] sreal_0, simag_0, sreal_1, simal_1;
    always @(posedge clk) begin
        if (amp[ state] != 0 ) begin
            if (state[ QULEN-n-1] == 1'b0) begin
//                newamp[ state] <= newamp[ state] + amp[ state] * 0.707;
//                newamp[ state + cut] <= newamp[ state + cut] + amp[ state] * 0.707; 
                min_real <= amp[ state][63:32];
                min_imag <= amp[ state][31:0];
                asin_real_0 <= newamp[ state][63:32];
                asin_imag_0 <= newamp[ state][31:0];
                asin_real_1 <= newamp[ state + cut][63:32];
                asin_imag_1 <= newamp[ state + cut][31:0];
                add <= 1'b1;
                state_cut <= state + cut;
            end
            else if ( state[ QULEN-n-1] == 1'b1) begin
//                newamp[ state] <= newamp[ state] - amp[ state] * 0.707; 
//                newamp[ state - cut] <= newamp[ state - cut] + amp[ state] * 0.707;
                min_real <= amp[ state][63:32];
                min_imag <= amp[ state][31:0];
                asin_real_0 <= newamp[ state][63:32];
                asin_imag_0 <= newamp[ state][31:0];
                asin_real_1 <= newamp[ state - cut][63:32];
                asin_imag_1 <= newamp[ state - cut][31:0];
                add <= 1'b0;
                state_cut <= state - cut;                
            end 
        end
        state_d1 <= state;
        state_d2 <= state_d1;
        state_d3 <= state_d2;
        state_cut_d1 <= state_cut;
        state_cut_d2 <= state_cut_d1;
        newamp[ state_d3] <= { sreal_0, simag_0};
        newamp[ state_cut_d2] <= { sreal_1, simal_1};
    end
    mult_float32 mult_real(
    .clk(clk),
    .a(min_real), .b(inverse_sqrt_2),
    .p(p_real)
    );
 
    mult_float32 mult2_imag(
    .clk(clk),
    .a(min_imag), .b(inverse_sqrt_2),
    .p(p_imag)
    );
    

    add_sub_float32 add_sub_real_0(
    .clk(clk), .add(add),
    .a(asin_real_0), .b(p_real),
    .s(sreal_0)
    );
  
    add_sub_float32 add_sub_imag_0(
    .clk(clk), .add(add),
    .a(asin_imag_0), .b(p_imag),
    .s(simag_0)
    );
    
    add_sub_float32 add_sub_real_1(
    .clk(clk), .add(1'b1),
    .a(asin_real_1), .b(p_real),
    .s(sreal_1)
    );

    add_sub_float32 add_sub_imag_1(
    .clk(clk), .add(1'b1),
    .a(asin_imag_1), .b(p_imag),
    .s(simal_1)
    );
endmodule
