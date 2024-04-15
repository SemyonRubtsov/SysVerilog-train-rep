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
    output reg [2:0] o_La,
    output reg [2:0] o_Lb
    );
    
    logic dir=1;
    
    localparam N=32;//1*200_000_000;
    reg [int'($ceil($clog2(N +1)))-1:0] cnt ='0;
    
    enum logic [1:0] {S0 = 4'b0,
                     S1 = 4'b1} S;

    always @(posedge i_clk) begin
        if (cnt<N)
            cnt<=cnt + 1;
        if (i_rst) begin
            S <= S0;
            o_La = 3'b001;
            o_Lb = 3'b100;
        end
        else
            case (S)
                S0 : begin
                    if ((i_Ta & !o_La[0] | i_Tb & !o_Lb[0]) & cnt>=N-1) begin
                       S <= S1;
                       cnt <= 0;
                       if (dir) begin
                       o_La=o_La<<<1;
                       o_Lb=o_Lb>>>1;end
                       else begin
                       o_La=o_La>>>1;
                       o_Lb=o_Lb<<<1;end
                    end
                end
                S1 : begin
                    S<=S0;
                    if (dir) begin
                       o_La=o_La<<<1;
                       o_Lb=o_Lb>>>1;end
                       else begin
                       o_La=o_La>>>1;
                       o_Lb=o_Lb<<<1;end
                    dir=!dir;
                end
            endcase
        end
endmodule