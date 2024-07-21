`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2024 10:43:51 AM
// Design Name: 
// Module Name: control
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


module control #(parameter QULEN = 2, QUDEEP = 2**QULEN)(
    input clk, rst, validin, validout,
    input [ QULEN-1:0] n, state_d1,
    output reg [QULEN-1:0] state, 
    output reg exe, readmem, write    
    );
    
    reg write0;
    reg [ QULEN-1:0] next_state, previous_state;
    wire [ QULEN-1:0] cut = 1<<( QULEN-n-1);
    wire [ QULEN-1:0] thres = QUDEEP-cut;
    wire [ QULEN-1:0] pass = previous_state + 1'b1;
    always @(state or rst or exe or readmem or validin or validout) begin
        if (rst) begin
            next_state = 0;
        end
        else if ((readmem) || (validin) || (validout)) begin
            next_state = state + 1'b1;
        end
        else if (state ===  (QUDEEP - 1)) next_state = state;
        else if ((exe) && (state<=thres)) begin
            if (state[ QULEN-n-1] === 1'b0) begin 
                next_state = state + cut;
            end
            else begin 
                if (pass[ QULEN-n-1] === 1'b1) next_state = pass + cut;
                else next_state = pass; //state[ QULEN-n-1] === 1'b1
            end
        end
        else state = 0;
    end
    always @(negedge clk) write <= write0;
    always @(posedge clk) begin
        if (rst) begin
            previous_state <= state;
            state <= 0;
            readmem <= 1'b0;
            exe <= 1'b0;
            write0 <= 1'b0;
        end
        else if ((exe) && (state_d1 === state) && (state_d1 === (QUDEEP-1))) begin
            previous_state <= state;
            readmem <= 1'b1;
            state <= 0;
            exe <= 1'b0;
            write0 <= 1'b0;
        end
        else if ((!exe) && (!readmem) && (state === (QUDEEP-1))) begin
            previous_state <= state;
            state <= next_state;
            readmem <= 1'b0;
            exe <= 1'b1;
            write0 <= 1'b0;
        end
        else if ((state != QUDEEP - 1) && (validin)) begin
            previous_state <= state;
            state <= next_state;
            readmem <= 1'b0;
            exe <= exe;
            write0 <= 1'b0;
        end        
        else if ((state_d1 != QUDEEP - 1) && (exe)) begin
            if ((!write0) && (state[ QULEN-n-1] === 1'b1)) begin
                write0 <= 1'b1;
            end         
            else begin
                write0 <= 1'b0;
            end
            previous_state <= state;
            state <= next_state;
            readmem <= 1'b0;
            exe <= exe;
        end          
        else if (readmem) begin
            state <= next_state;
            if (state == QUDEEP-1) readmem <= 1'b0;
            else readmem <= 1'b1;
            exe <= 1'b0;
            write0 <= 1'b0;
            previous_state <= state;
        end
        else begin
            previous_state <= state;
            state <= state;
            readmem <= 1'b0;
            exe <= exe;
            write0 <= 1'b0;
        end
    end
    
endmodule
