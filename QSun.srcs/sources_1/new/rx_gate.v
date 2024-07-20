`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2024 07:25:59 AM
// Design Name: 
// Module Name: rx_gate
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


module rx_gate #(parameter QULEN = 2, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] n,
    input [31 : 0] theta,
    output [63 : 0] newamplitude,
    output reg validout
    );
    
    wire exe, readmem, write;
    wire [63:0] amp, newamp, newamp_cut;
    wire [ QULEN-1:0] state;
    reg [ QULEN-1:0] state_d1, addr_a, addr_b_temp;
    wire [31:0] costheta, sintheta, thetadiv2, store_real_0, store_imag_0, store_real_1, store_imag_1;
    reg [63:0] A_CM_0, B_CM_0, A_CM_1, B_CM_1, A_AS_0, B_AS_0, A_AS_1, B_AS_1;
    wire [63:0] _real_0, _imag_0, _real_1, _imag_1;
    wire [ QULEN-1:0] cut = 1<<( QULEN-n-1);
        
    assign newamplitude = validout? newamp : 0;
    
    blk_mem_gen_0 S_AMPMEM(
        .clka(clk),
        .ena((exe | validin)),
        .wea(validin),
        .addra({{2'b0},state}),
        .dina(amplitude),
        .douta(amp)
    );    
    
    blk_mem_gen_1 TEMPAMPMEM(
        .clka(clk),
        .ena(exe | readmem | validout),
        .wea(write),
        .addra({{2'b0},addr_a}),
        .dina({ store_real_1, store_imag_1}),
        .douta(newamp),
        .clkb(clk),
        .enb(exe),
        .web(write),
        .addrb({{2'b0},addr_b_temp}),
        .dinb({ store_real_0, store_imag_0}),
        .doutb(newamp_cut)
    );

    always @(state_d1, state) begin
        if (readmem) begin
            addr_a = state;
        end
        else if (state_d1[ QULEN-n-1] == 1'b1) begin
            addr_b_temp = state_d1 + cut;
            addr_a = state_d1;
        end
        else begin 
            addr_b_temp = state - cut;
            addr_a = state;
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
    
    cmpy_0 COMPLEX_MUL_1 (
        .s_axis_a_tvalid(exe),
        .s_axis_a_tdata(A_CM_1),
        .s_axis_b_tvalid(exe),
        .s_axis_b_tdata(B_CM_1),
        .m_axis_dout_tvalid(cm1_out),
        .m_axis_dout_tdata({_imag_1, _real_1})
    );
    
    c_addsub_1 add_sub_real_0(
        .A(A_AS_0[31:0]),
        .B(_real_1[60:29]),
        .S(store_real_0)
     );    
    
    c_addsub_1 add_sub_real_1(
        .A(_real_0[60:29]),
        .B(B_AS_1[31:0]),
        .S(store_real_1)
     );  

    c_addsub_1 add_sub_imag_0(
        .A(A_AS_0[63:32]),
        .B(_imag_1[60:29]),
        .S(store_imag_0)
     );    
    
    c_addsub_1 add_sub_imag_1(
        .A(_imag_0[60:29]),
        .B(B_AS_1[63:32]),
        .S(store_imag_1)
     );  

    always @(negedge clk) begin
        if (exe) begin
//            if (state_d1[ QULEN-n-1] == 1'b0) begin
                //                newamp[ state] <= newamp[ state] + amp[ state] * 0.707;
                //                newamp[ state + cut] <= newamp[ state + cut] + amp[ state] * 0.707; 
            A_CM_0 <= {32'b0, costheta};
            B_CM_0 <= {amp[31:0], amp[63:32]};
            A_CM_1 <= {sintheta, 32'b0};
            B_CM_1 <= {amp[31:0], amp[63:32]};
            
            A_AS_0 <= {_imag_0[60:29], _real_0[60:29]};
            B_AS_1 <= {_imag_1[60:29], _real_1[60:29]};
        end
        else begin

        end
    end    
    
    always @(posedge clk) begin
        state_d1 <= state;
        validout <= readmem;
    end    
endmodule
