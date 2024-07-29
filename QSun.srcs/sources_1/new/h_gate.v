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


module h_gate #(parameter QULEN = 18, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] n,
    output [63 : 0] newamplitude,
    output reg validout
);
    parameter [31:0] inverse_sqrt_2 = 32'h2d413ccd;
    wire [63:0] amp;
    wire [63:0] newamp, _real_0, _imag_0;
    wire [ QULEN-1 : 0] state;
    wire [ QULEN-1 : 0] cut = 1<<( QULEN-n-1);
    reg [ QULEN-1 : 0] state_d1;
    wire exe, readmem, write, cm0_out, valid_done;
    reg [63:0] A_CM_0, B_CM_0, A_AS_0;
    wire [31:0] store_real_0, store_imag_0, store_real_1, store_imag_1;
    reg [QULEN-1:0] addr_a, addr_b_temp;
    wire [63:0] tempamp_cut;    
    
    assign newamplitude = (validout) ? newamp : 0;
    assign valid_done = validout & (~readmem);
    
    blk_mem_gen_0 AMPMEM(
        .clka(clk),
        .ena((exe | validin)),
        .wea(validin),
        .addra(state),
        .dina(amplitude),
        .douta(amp)
    );

    blk_mem_gen_1 TEMPAMPMEM(
        .clka(clk),
        .ena(exe | readmem | validout),
        .wea(write),
        .addra(addr_a),
        .dina({ store_real_1, store_imag_1}),
        .douta(newamp),
        .clkb(clk),
        .enb(exe),
        .web(write),
        .addrb(addr_b_temp),
        .dinb({ store_real_0, store_imag_0}),
        .doutb(tempamp_cut));
    
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
    
    cmpy_0 COMPLEX_MUL_0 (
        .s_axis_a_tvalid(exe), ///{imag[32], real[32]}
        .s_axis_a_tdata(A_CM_0),
        .s_axis_b_tvalid(exe),
        .s_axis_b_tdata(B_CM_0),
        .m_axis_dout_tvalid(cm0_out), ///{64 imag, 64 real}
        .m_axis_dout_tdata({_imag_0, _real_0})
    );
   
    c_addsub_1 add_sub_real_0( //subtract
        .A(A_AS_0[31:0]),
        .B(_real_0[60:29]),
        .S(store_real_1)
     );    
    
    c_addsub_2 add_sub_real_1( //add
        .A(A_AS_0[31:0]),
        .B(_real_0[60:29]),
        .S(store_real_0)
     );  

    c_addsub_1 add_sub_imag_0(
        .A(A_AS_0[63:32]),
        .B(_imag_0[60:29]),
        .S(store_imag_1)
     );    
    
    c_addsub_2 add_sub_imag_1(
        .A(A_AS_0[63:32]),
        .B(_imag_0[60:29]),
        .S(store_imag_0)
     );  
              
    always @(state_d1 or state or rst or valid_done) begin
        if (rst) begin 
            addr_a = 0;
            addr_b_temp = 0;
        end
        else if (valid_done) begin
            addr_a = 0;
            addr_b_temp = 0;
        end
        else if (readmem) begin
            addr_a = state_d1;
            addr_b_temp = 0;
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
    
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            A_CM_0 <= 0;
            B_CM_0 <= 0; 
            A_AS_0 <= 0;
        end
        else if (valid_done) begin
            A_CM_0 <= 0;
            B_CM_0 <= 0; 
            A_AS_0 <= 0;
        end
        else if (exe) begin
            A_CM_0 <= {amp[31:0], amp[63:32]};
            B_CM_0 <= {32'b0, inverse_sqrt_2}; //inverse square root
            A_AS_0 <= {_imag_0[60:29], _real_0[60:29]};
        end
        else begin
            A_CM_0 <= 0;
            B_CM_0 <= 0; 
            A_AS_0 <= 0;
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
