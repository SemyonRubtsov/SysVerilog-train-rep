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
	
//	logic         tready;
//	logic         tvalid;
//	logic         tlast ;
//	logic [W-1:0] tdata ;
	
//	modport m (input tready, output tvalid, tlast, tdata);
//	modport s (output tready, input tvalid, tlast, tdata);
	
//endinterface

module lab4_top
#(
parameter G_BYT = 1
)
(
    input i_clk,
    input [2:0] i_rst
);
    
    if_axis #(.N(G_BYT)) src_fifo();
    //if_axis #(.N(G_BYT)) fifo();
    if_axis #(.N(G_BYT)) fifo_dst();
    
    lab4_source u_src(
        .i_clk(i_clk),
        .i_rst(i_rst[0]),
        
        .m_axis_tvalid(src_fifo.tvalid),            // output wire m_axis_tvalid
        .m_axis_tready(src_fifo.tready),            // input wire m_axis_tready
        .m_axis_tdata(src_fifo.tdata),              // output wire [7 : 0] m_axis_tdata
        .m_axis_tlast(src_fifo.tlast)              // output wire m_axis_tlast
    );
    
    axis_data_fifo_0 u_fifo (
        .s_axis_aresetn(i_rst[1]),          // input wire s_axis_aresetn
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
    
    lab4_dest u_dst(
        .i_clk(i_clk),   
        .i_rst(i_rst[2]),
        
        .s_axis_tvalid(fifo_dst.tvalid),            // input wire s_axis_tvalid
        .s_axis_tready(fifo_dst.tready),            // output wire s_axis_tready
        .s_axis_tdata(fifo_dst.tdata),              // input wire [7 : 0] s_axis_tdata
        .s_axis_tlast(fifo_dst.tlast)              // input wire s_axis_tlast
    );
endmodule
