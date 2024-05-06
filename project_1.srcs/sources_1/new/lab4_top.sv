`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 07:34:06 PM
// Design Name: 
// Module Name: lab4_top
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

//interface if_axis #(parameter int N = 1) ();
//	localparam W = 8 * N; // TDATA bit width (N - number of bytes)
//	
//	logic         tready;
//	logic         tvalid;
//	logic         tlast ;
//	logic [W-1:0] tdata ;
//	
//	modport m (input tready, output tvalid, tlast, tdata);
//	modport s (output tready, input tvalid, tlast, tdata);
//	
//endinterface

module lab4_top
#(
parameter G_BYT = 1
)
(
    input i_clk,
    input [2:0] i_rst,
    input logic i_ready
);
    
    if_axis #(.N(G_BYT)) src_fifo();
    //if_axis #(.N(G_BYT)) fifo();
    if_axis #(.N(G_BYT)) fifo_dst();
    
    lab4_source u_src(
        .i_clk(i_clk),
        .i_rst(i_rst[0]),
        .i_fifo_progfull(prog_full),
        .m_axis(src_fifo)             // output wire m_axis_tlast
    );
    
    lab4_dest u_dst(
        .i_clk(i_clk),
        .i_rst(i_rst[2]),
        .i_ready(i_ready),
        .s_axis(fifo_dst)
    );
    
//    axis_fifo_w #(
//    .DEPTH(64), // Depth of fifo, minimum is 16, actual depth will be displayed in the information of module
//    .PACKET_MODE("True"), // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
//    .MEM_STYLE("Distributed"), // Memory style: "Distributed" or "Block"
//    .DUAL_CLOCK("False"), // Dual clock fifo: "True" or "False"
//    .SYNC_STAGES(2), // Number of synchronization stages in dual clock mode: [2, 3, 4]
//    .RESET_SYNC("False"), // Asynchronous reset synchronization: "True" or "False"
//    .FEATURES('0), // Advanced features: [ reserved, read count, prog. empty flag, almost empty, reserved, write count, prog. full flag, almost full flag ] 
//    .PROG_FULL(12), // Programmable full threshold
//    .PROG_EMPTY(4) // Programmable empty threshold
//    //localparam  int       CW = $clog2(DEPTH)+1 // Count width
//  ) u_fifo (
    
//    //.i_fifo_a_rst_n, // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

//    .s_axis_a_clk_p(i_clk),
//    .s_axis_a_rst_n(!i_rst[2]),

//    .s_axis_tvalid(src_fifo.tvalid),
//    .s_axis_tready(src_fifo.tready),
//    .s_axis_tdata(src_fifo.tdata),
//    //.s_axis_tstrb,
//    //.s_axis_tkeep,
//    .s_axis_tlast(src_fifo.tlast),
//    //.s_axis_tid,
//    //.s_axis_tdest,
//    //.s_axis_tuser,

//    .m_axis_a_clk_p(i_rst),
//    .m_axis_a_rst_n(i_clk),

//    .m_axis_tvalid(fifo_dst.tvalid),
//    .m_axis_tready(fifo_dst.tready),
//    .m_axis_tdata(fifo_dst.tdata),
//    //.m_axis_tstrb,
//    //.m_axis_tkeep,
//    .m_axis_tlast(fifo_dst.tlast)
//    //.m_axis_tid,
//    //.m_axis_tdest,
//    //.m_axis_tuser,

//    //.o_fifo_a_tfull, // Almost full flag
//    //.o_fifo_p_tfull, // Programmable full flag
//    //.o_fifo_w_count, // Write data count
//    //
//    //.o_fifo_a_empty, // Almost empty flag
//    //.o_fifo_p_empty, // Programmable empty flag
//    //.o_fifo_r_count  // Read data count, if dual clock mode is false - output count is the same with write data count
    
//    );
    
    axis_data_fifo_0 u_fifo (
        .s_axis_aresetn(~i_rst[1]),          // input wire s_axis_aresetn
        .s_axis_aclk(i_clk),                // input wire s_axis_aclk
        
        .s_axis_tvalid(src_fifo.tvalid),            // input wire s_axis_tvalid
        .s_axis_tready(src_fifo.tready),            // output wire s_axis_tready
        .s_axis_tdata(src_fifo.tdata),              // input wire [7 : 0] s_axis_tdata
        .s_axis_tlast(src_fifo.tlast),              // input wire s_axis_tlast
        
        .m_axis_tvalid(fifo_dst.tvalid),            // output wire m_axis_tvalid
        .m_axis_tready(fifo_dst.tready),            // input wire m_axis_tready
        .m_axis_tdata(fifo_dst.tdata),              // output wire [7 : 0] m_axis_tdata
        .m_axis_tlast(fifo_dst.tlast),              // output wire m_axis_tlast
        
        .axis_wr_data_count(axis_wr_data_count),  // output wire [31 : 0] axis_wr_data_count
        .axis_rd_data_count(axis_rd_data_count),  // output wire [31 : 0] axis_rd_data_count
        .prog_empty(prog_empty),                  // output wire prog_empty
        .prog_full(prog_full)                    // output wire prog_full
    );
    
endmodule
