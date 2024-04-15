`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2024 05:40:16 PM
// Design Name: 
// Module Name: lab3_top
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



module lab3_top(
    input i_clk,
    input i_rst,
    input i_Ta,
    input i_Tb,
    output reg [1:0] i_La,
    output reg [1:0] i_Lb
    );
    
    enum logic [3:0] {S0 = 4'b0001,
                     S1 = 4'b0010,
                     S2 = 4'b0100,
                     S3 = 4'b1000} S;

    always @(posedge i_clk)
        if (i_rst) begin
            S <= S0;
            i_La <= 2'b00;
            i_Lb <= 2'b10;
        end
        else
            case (S)
                S0 : begin
                    if (~i_Ta)
                       S <= S1;
//                    else if (<condition>)
//                       <state> <= <next_state>;
//                    else
//                       <state> <= <next_state>;
                    i_La <= 2'b00;
                    i_Lb <= 2'b10;
                end
                S1 : begin
                    S<=S2;
//                    if (<condition>)
//                       <state> <= <next_state>;
//                    else if (<condition>)
//                       <state> <= <next_state>;
//                    else
//                       <state> <= <next_state>;
                    i_La <= 2'b01;
                    i_Lb <= 2'b10;
                end
                S2 : begin
                    if (~i_Tb)
                       S <= S3;
//                    else if (<condition>)
//                       <state> <= <next_state>;
//                    else
//                       <state> <= <next_state>;
                    i_La <= 2'b10;
                    i_Lb <= 2'b00;
                end
                S3: begin
                    S <= S0;
//                    if (<condition>)
//                       <state> <= <next_state>;
//                    else if (<condition>)
//                       <state> <= <next_state>;
//                    else
//                       <state> <= <next_state>;
                    i_La <= 2'b10;
                    i_Lb <= 2'b01;
                end
            endcase
        
endmodule
