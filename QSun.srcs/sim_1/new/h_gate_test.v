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
    reg [ QULEN - 1: 0] n;
    reg [63:0] amp;
    wire [63:0] newamp;
    initial forever #5 clk = ~clk;
    genvar i;
    generate

endgenerate
    initial begin
    clk = 1'b0;
    n = 0;
    #5 rst = 1'b1;
    #10 rst = 1'b0;
    
    validin = 1'b1;
    @(posedge clk)

    amp = 64'h3f80000000000000;    
    @(posedge clk)
    amp = 64'h0;
    @(posedge clk)    
    amp = 64'h0;
    @(posedge clk)    
    amp = 64'h0;  
    #2 validin = 1'b0;
end

    h_gate #(.QULEN(2)) HGATE(
    .clk(clk), .rst(rst), .validin(validin),
    .amplitude(amp),
    .n(n),
    .newamplitude(newamp),
    .validout(validout)
);
endmodule
