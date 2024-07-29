`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/013/2024 10:03:59 AM
// Design Name: 
// Module Name: s_gate
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


module s_gate #(parameter QULEN = 18, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] n,
    output [63 : 0] newamplitude,
    output reg validout
);
    wire exe, readmem, write, valid_done; 
    reg [31:0] _real, _imag;
    wire [63:0] amp, newamp;
    wire [ QULEN-1:0] state;
    reg [ QULEN-1:0] state_d1, addr;
    assign newamplitude = (validout) ? newamp : 0;
    assign valid_done = validout & (~readmem);
    
    always @(state_d1 or state or rst or valid_done) begin
        if (rst) begin 
            addr = 0;
        end
        else if (valid_done) begin
            addr = 0;
        end
        else if (exe) begin
            addr = state_d1;
        end
        else if (readmem) begin 
            addr = state_d1;
        end
        else addr = 0;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_d1 <= state;
            validout <= readmem;
        end
        else if (valid_done) begin
            state_d1 <= state;
            validout <= readmem;
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
            if (state_d1[ QULEN-n-1] == 1'b0) begin
                _real <= amp[63:32];
                _imag <= amp[31:0];
            end
            else begin
                if (amp[31:0] !== 31'b0) _real <= {~amp[31], amp[30:0]};
                else _real <= 31'b0;
                _imag <= amp[64:32];
            end
        end
        else begin
            _real <= 0;
            _imag <= 0;
        end
    end
endmodule