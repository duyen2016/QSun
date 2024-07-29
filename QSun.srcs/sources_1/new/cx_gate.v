`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 02:26:39 AM
// Design Name: 
// Module Name: cx_gate
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


module cx_gate #(parameter QULEN = 18, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] control, n,
    output [63 : 0] newamplitude,
    output reg validout
    );
    wire exe, readmem, valid_done; 
    reg [31:0] _real, _imag;
    wire [63:0] amp, newamp;
    wire [ QULEN-1:0] state, cut;
    reg [ QULEN-1:0] state_d1, addr;

    assign cut = 1<<( QULEN-n-1);

    assign newamplitude = (validout) ? newamp : 0;
    assign valid_done = validout & (~readmem);

    always @(state_d1 or state or valid_done or rst) begin
        if (rst) begin
            addr = 0;
        end
        else if (valid_done) begin
            addr = 0;
        end
        else if (exe) begin
            if (state_d1[ QULEN-control-1] == 1'b0) addr = state_d1;
            else if (state_d1 [ QULEN-n-1] == 1'b0) addr = state_d1 + cut;
            else addr = state_d1 - cut;
        end
        else if (readmem) begin 
            addr = state_d1;
        end
        else addr = 0;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            state_d1 <= 0;
            validout <= 0;
        end
        else if (valid_done) begin
            state_d1 <= 0;
            validout <= 0;
        end
        else begin 
            state_d1 <= state;
            validout <= readmem;
        end
    end
    
    blk_mem_gen_0 S_AMPMEM(
        .clka(clk),
        .ena((exe | validin)),
        .wea(validin),
        .addra(state),
        .dina(amplitude),
        .douta(amp)
    );
    
    blk_mem_gen_0 S_NEWAMPMEM(
        .clka(clk),
        .ena(exe | readmem | validout),
        .wea(exe),
        .addra(addr),
        .dina({_real, _imag}),
        .douta(newamp)
    );
    
    control #(.QULEN(QULEN), .QUDEEP(QUDEEP)) S_CONTROL (
        .clk(clk), 
        .rst(rst), 
        .validin(validin),
        .n(n),
        .state_d1(state_d1),
        .state(state), 
        .exe(exe), 
        .readmem(readmem), 
        .validout(validout), 
        .write(write)    
    );
 
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            _real <= 0;
            _imag <= 0;
        end
        else if (valid_done) begin
            _real <= 0;
            _imag <= 0;
        end
        else if (exe) begin
            _real <= amp[63:32];
            _imag <= amp[31:0];
        end
    end
endmodule
