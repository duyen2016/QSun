`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2024 06:07:26 PM
// Design Name: 
// Module Name: h_gate_test
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


module h_gate_test();
    parameter QULEN = 2;
    parameter QUDEEP = 2**QULEN;
    reg clk, rst, validin;
    wire validout;
    wire [64 * QUDEEP -1: 0] amplitude, newamplitude;
    reg [ QULEN - 1: 0] n;
    reg [63:0] amp [ QUDEEP-1:0];
    wire [63:0] newamp [ QUDEEP-1:0];
    initial forever #5 clk = ~clk;
    genvar i;
    generate
    for (i = 0; i< QUDEEP; i = i+1) begin
        assign amplitude[ 64*(i+1)-1 : 64*i] = amp[i];
        assign newamp[i] = newamplitude[ 64*(i+1)-1 : 64*i];
    end
    endgenerate
    initial begin
        clk = 1'b0;
        amp[0] = 64'h3f80000000000000;
        amp[1] = 0;
        amp[2] = 0;
        amp[3] = 0;
        n = 0;
        #5 rst = 1'b1;
        #10 rst = 1'b0;
        #15 validin = 1'b1;
        #20 validin = 1'b0;
    end
    
    h_gate #(.QULEN(2)) HGATE(
    .clk(clk), .rst(rst), .validin(validin),
    .amplitude(amplitude),
    .n(n),
    .newamplitude(newamplitude),
    .validout(validout)
    );
endmodule
