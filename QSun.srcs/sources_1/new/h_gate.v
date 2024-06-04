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


module h_gate #(parameter QULEN = 2, QUDEEP = 2**QULEN)(
    input clk, rst, validin,
    input [63 : 0] amplitude,
    input [ QULEN - 1 : 0] n,
    output [63 : 0] newamplitude,
    output reg validout
);
    parameter [31:0] inverse_sqrt_2 = 32'h3f3504f3;
    wire [63:0] amp;
    wire [63:0] newamp;
    wire [ QULEN : 0] cut = 1<<( QULEN-n-1);
    reg [ QULEN : 0] state, state_d1, state_d2, state_d3, state_d4;
    reg exe, readmem, validout_d1;
    assign newamplitude = (validout) ? newamp : 0;
    blk_mem_gen_0 AMPMEM(
        .clka(clk),
        .ena((exe | validin)),
        .wea(validin),
        .addra({{1'b0},state}),
        .dina(amplitude),
        .douta(amp)
    );
    wire [31:0] sreal_0, simag_0, sreal_1, simal_1;
    reg [QULEN-1:0] addr_b;
    wire [63:0] newamp_cut;
    blk_mem_gen_1 NEWAMPMEM(
        .clka(clk),
        .ena(exe | readmem | validout_d1),
        .wea((state == state_d4)&&(exe)),
        .addra({{1'b0},state}),
        .dina({ sreal_0, simag_0}),
        .douta(newamp),
        .clkb(clk),
        .enb(exe | readmem | validout_d1),
        .web((state == state_d4)&&(exe)),
        .addrb({{2'b0},addr_b}),
        .dinb({ sreal_1, simal_1}),
        .doutb(newamp_cut)
    );
    //    always @(posedge clk) begin
    //        state <= state_n;
    //        exe <= exe_n;
    //        validout <= validout_n;
    //    end
    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
            readmem <= 1'b0;
            exe <= 1'b0;
        end
        else if (exe && (state_d4 === (QUDEEP-1))) begin
            readmem <= 1'b1;
            state <= 0;
            exe <= 1'b0;
        end
        else if (validin && (state === (QUDEEP-1))) begin
            state <= 0;
            readmem <= 1'b0;
            exe <= 1'b1;
        end
        else if ((state != QUDEEP - 1) && (validin) || (exe && (state == state_d4))) begin
            state <= state + 1;
            readmem <= 1'b0;
            exe <= exe;
        end
        else if (readmem) begin
            if (state < QUDEEP-1) state <= state + 1;
            else state <= state;
            if (state == QUDEEP-1) readmem <= 1'b0;
            else readmem <= 1'b1;
            exe <= 1'b0;
        end
        else begin
            state <= state;
            readmem <= 1'b0;
            exe <= exe;
        end
    end
    wire [31:0] p_real, p_imag;
    reg [31:0] min_real, min_imag, asin_real_0, asin_imag_0, asin_real_1, asin_imag_1;
    reg add;
    always @(state) begin
        if (state[ QULEN-n-1] == 1'b0) begin
            addr_b = state + cut;
        end
        else addr_b = state - cut;
    end
    always @(posedge clk) begin
        if (exe) begin
            if (state_d2[ QULEN-n-1] == 1'b0) begin
                //                newamp[ state] <= newamp[ state] + amp[ state] * 0.707;
                //                newamp[ state + cut] <= newamp[ state + cut] + amp[ state] * 0.707; 
                min_real <= amp[63:32];
                min_imag <= amp[31:0];
                asin_real_0 <= newamp[63:32];
                asin_imag_0 <= newamp[31:0];
                asin_real_1 <= newamp_cut[63:32];
                asin_imag_1 <= newamp_cut[31:0];
                add <= 1'b1;
            end
            else if ( state_d2[ QULEN-n-1] == 1'b1) begin
                //                newamp[ state] <= newamp[ state] - amp[ state] * 0.707; 
                //                newamp[ state - cut] <= newamp[ state - cut] + amp[ state] * 0.707;
                min_real <= amp[63:32];
                min_imag <= amp[31:0];
                asin_real_0 <= newamp[63:32];
                asin_imag_0 <= newamp[31:0];
                asin_real_1 <= newamp_cut[63:32];
                asin_imag_1 <= newamp_cut[31:0];
                add <= 1'b0;
            end
            state_d1 <= state;
            state_d2 <= state_d1;
            state_d3 <= state_d2;
            state_d4 <= state_d3;
        end
        validout_d1 <= readmem;
        validout <= validout_d1;
    end
    mult_float32 mult_real(
        .clk(clk),
        .a(min_real), .b(inverse_sqrt_2),
        .p(p_real)
    );

    mult_float32 mult2_imag(
        .clk(clk),
        .a(min_imag), .b(inverse_sqrt_2),
        .p(p_imag)
    );


    add_sub_float32 add_sub_real_0(
        .clk(clk), .add(add),
        .a(asin_real_0), .b(p_real),
        .s(sreal_0)
    );

    add_sub_float32 add_sub_imag_0(
        .clk(clk), .add(add),
        .a(asin_imag_0), .b(p_imag),
        .s(simag_0)
    );

    add_sub_float32 add_sub_real_1(
        .clk(clk), .add(1'b1),
        .a(asin_real_1), .b(p_real),
        .s(sreal_1)
    );

    add_sub_float32 add_sub_imag_1(
        .clk(clk), .add(1'b1),
        .a(asin_imag_1), .b(p_imag),
        .s(simal_1)
    );
endmodule
