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


module cx_gate #(parameter QULEN = 2, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] control, n,
    output [63 : 0] newamplitude,
    output reg validout
    );
    wire exe, readmem; 
    reg [31:0] _real, _imag;
    wire [63:0] amp, newamp;
    wire [ QULEN-1:0] state, cut;
    reg [ QULEN-1:0] state_d1, addr;

    assign cut = 1<<( QULEN-n-1);

    assign newamplitude = (validout) ? newamp : 0;
    
    always @(state_d1, state) begin
        if (exe) begin
            if (state_d1[ QULEN-control-1] == 1'b0) addr = state_d1;
            else if (state_d1 [ QULEN-n-1] == 1'b0) addr = state_d1 + cut;
            else addr = state_d1 - cut;
        end
        else begin 
            addr = state;
        end
    end
    
    always @(posedge clk) begin
        state_d1 <= state;
        validout <= readmem;
    end
    
    blk_mem_gen_0 S_AMPMEM(
        .clka(clk),
        .ena((exe | validin)),
        .wea(validin),
        .addra({{2'b0},state}),
        .dina(amplitude),
        .douta(amp)
    );
    
    blk_mem_gen_0 S_NEWAMPMEM(
        .clka(clk),
        .ena(exe | readmem | validout),
        .wea(exe),
        .addra({{2'b0},addr}),
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

//    cmpy_0 COMPLEX_MUL (
//        .s_axis_a_tvalid(),
//        .s_axis_a_tdata(),
//        .s_axis_b_tvalid(),
//        .s_axis_b_tdata(),
//        .m_axis_dout_tvalid(),
//        .m_axis_dout_tdata()
//    );
//    cordic_0 CORDIC (
//        .s_axis_phase_tvalid(),
//        .s_axis_phase_tdata() : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
//        m_axis_dout_tvalid : OUT STD_LOGIC;
//        m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
//      );    
    always @(negedge clk) begin
        if (exe) begin
            _real <= amp[63:32];
            _imag <= amp[31:0];


        end
    end
endmodule
