`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2024 10:37:14 AM
// Design Name: 
// Module Name: rz_gate
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


module rz_gate #(parameter QULEN = 18, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] n,
    input [31 : 0] theta,
    output [63 : 0] newamplitude,
    output reg validout
    );
    
    wire exe, readmem, write, valid_done;
    wire [63:0] amp, newamp;
    wire [ QULEN-1:0] state;
    reg [ QULEN-1:0] state_d1, addr;
    wire [31:0] costheta, sintheta, cpm_sintheta, thetadiv2;
    reg [63:0] A_CM_0, B_CM_0;
    wire [63:0] _real_0, _imag_0;
        
    assign newamplitude = validout? newamp : 0;
    assign cpm_sintheta = ~sintheta + 1'b1;
    assign valid_done = validout & (~readmem);
    
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
        .dina({_real_0[60:29], _imag_0[60:29]}),
        .douta(newamp)
    );

    always @(state_d1 or  state or rst or validout) begin
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
        else begin 
            addr = state;
        end
    end

    control #(.QULEN(QULEN), .QUDEEP(QUDEEP)) CONTROL (
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
    
    assign thetadiv2 = theta >> 1'b1;
    
    wire cordic_out, cm0_out, cm1_out;
    
    cordic_0 CORDIC (
    .s_axis_phase_tvalid(exe),
    .s_axis_phase_tdata(thetadiv2),
    .m_axis_dout_tvalid(cordic_out),
    .m_axis_dout_tdata({sintheta, costheta})
    );
    
    cmpy_0 COMPLEX_MUL_0 (
        .s_axis_a_tvalid(exe), ///{imag[32], real[32]}
        .s_axis_a_tdata(A_CM_0),
        .s_axis_b_tvalid(exe),
        .s_axis_b_tdata(B_CM_0),
        .m_axis_dout_tvalid(cm0_out), ///{64 imag, 64 real}
        .m_axis_dout_tdata({_imag_0, _real_0})
    );
    
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            A_CM_0 <= 0;
            B_CM_0 <= 0;
        end
        else if (valid_done) begin
            A_CM_0 <= 0;
            B_CM_0 <= 0;
        end
        else if (exe) begin
            if (state_d1[ QULEN-n-1] == 1'b0) begin
                A_CM_0 <= {cpm_sintheta, costheta};
                B_CM_0 <= {amp[31:0], amp[63:32]};
            end
            else begin
                A_CM_0 <= {sintheta, costheta};
                B_CM_0 <= {amp[31:0], amp[63:32]};
            end
        end
        else begin
            A_CM_0 <= 0;
            B_CM_0 <= 0;
        end
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
endmodule
