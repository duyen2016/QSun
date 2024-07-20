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
    reg [ QULEN - 1: 0] n, control;
    reg [31:0] theta;
    reg [63:0] amp;
    wire [63:0] newamp;
    initial forever #5 clk = ~clk;

    initial begin
    clk = 1'b0;
    n = 0;
    control = 1;
    theta = 32'h323d70a4;
    #5 rst = 1'b1;
    #15 rst = 1'b0;
    
    @(posedge clk)

    amp = 64'h4000000000000000;    
    validin = 1'b1;
    @(posedge clk)
    amp = 64'h4000000000000000;
    @(posedge clk)    
    amp = 64'h4000000000000000;
    @(posedge clk)    
    amp = 64'h0000000000000000;  
    @(posedge clk)
    validin = 1'b0;
end

    rx_gate #(.QULEN(2)) SGATE(
    .clk(clk), .rst(rst), .validin(validin),
    .amplitude(amp),
    .theta(theta), .n(n),
    .newamplitude(newamp),
    .validout(validout)
);
endmodule
