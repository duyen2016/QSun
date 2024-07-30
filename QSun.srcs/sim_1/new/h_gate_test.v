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
    parameter QULEN = 18;
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
        repeat (2**18) begin
            @(posedge clk)
            amp = 64'h0000000000000000;
        end
        validin = 1'b0;
    end
    
    wire validout_g1;
    wire [63:0] amp_g1;
    
    s_gate #(.QULEN(18)) SGATE(
        .clk(clk), .rst(rst), .validin(validin),
        .amplitude(amp),
        .n(n),
        .newamplitude(amp_g1),
        .validout(validout_g1)
    );
    
    wire validout_g2;
    wire [63:0] amp_g2;
    
    h_gate #(.QULEN(18)) HGATE(
        .clk(clk), .rst(rst), .validin(validout_g1),
        .amplitude(amp_g1),
        .n(n),
        .newamplitude(amp_g2),
        .validout(validout_g2)
    );

    wire validout_g3;
    wire [63:0] amp_g3;
    
    ry_gate #(.QULEN(18)) RYGATE(
        .clk(clk), .rst(rst), .validin(validout_g2),
        .amplitude(amp_g2),
        .n(n), .theta(theta),
        .newamplitude(amp_g3),
        .validout(validout_g3)
    );
        
    wire validout_g4;
    wire [63:0] amp_g4;
    
    rz_gate #(.QULEN(18)) RZGATE(
        .clk(clk), .rst(rst), .validin(validout_g3),
        .amplitude(amp_g3),
        .theta(theta),.n(n),
        .newamplitude(amp_g4),
        .validout(validout_g4)
    );
    
    wire validout_g5;
    wire [63:0] amp_g5;
    
    rx_gate #(.QULEN(18)) RXGATE(
        .clk(clk), .rst(rst), .validin(validout_g4),
        .amplitude(amp_g4),
        .theta(theta),.n(n),
        .newamplitude(amp_g5),
        .validout(validout_g5)
    );
    
    cx_gate #(.QULEN(18)) CXGATE(
        .clk(clk), .rst(rst), .validin(validout_g5),
        .amplitude(amp_g5),
        .control(n), .n(control),
        .newamplitude(newamp),
        .validout(validout)
    );
    
endmodule
