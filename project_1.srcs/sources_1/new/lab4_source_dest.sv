`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2024 09:51:16 PM
// Design Name: 
// Module Name: lab4_source_dest
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2024 09:44:01 PM
// Design Name: 
// Module Name: tb_lav4_source_dest
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


module lab4_source_dest
#(
parameter G_BYT = 1
)
(
    input i_clk,
    input [2:0] i_rst,
    input reg[5:0] i_p_len,
    input logic i_ready
    //output reg[5:0] o_p_len_sync
);
    
    //reg[5:0] o_p_len_sync;
    
    if_axis #(.N(G_BYT), .I(0), .D(0), .U(0), .PAYMASK(7'b000_1001) ) src_fifo();
    //if_axis #(.N(G_BYT)) fifo();
    if_axis #(.N(G_BYT), .I(0), .D(0), .U(0), .PAYMASK(7'b000_1001) ) fifo_dst();
    
    //assign o_p_len_sync = (src_fifo.tlast | i_rst==7) ? i_p_len : o_p_len_sync;
    
    lab4_source_divided_FSM u_src(
        .i_clk(i_clk),
        .i_rst(i_rst[0]),
        .i_p_len(i_p_len),
        //.i_fifo_progfull(prog_full),
        .m_axis(src_fifo)             // output wire m_axis_tlast
    );
    
    lab4_dest_v2 u_dst(
        .i_clk(i_clk),
        .i_rst(i_rst[2]),
        .i_ready(i_ready),
        .s_axis(src_fifo)
    );
    
endmodule
