`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nickolay A. Sysoev
// 
// Create Date: 22/07/2019 16:54:27 PM
// Module Name: fifo_axis
// Tool Versions: Verilog
// Description: AXI4-Stream FIFO Verilog Wrapper
// 
// Dependencies:
// 
// Revision:
// Revision 0.6.0 - fifo with axis interface
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////

(* KEEP_HIERARCHY = "Yes" *)
module fifo_axis #(
    parameter integer         TDATA_W = 2, // AXI4-Stream TDATA width in bytes
    parameter integer         TID_W = 0, // AXI4-Stream TID width
    parameter integer         TDEST_W = 0, // AXI4-Stream TDEST width
    parameter integer         TUSER_W = 0, // AXI4-Stream TUSER width
    parameter integer         DEPTH = 16, // Depth of fifo, minimum is 16, actual depth will be displayed in the information of module
    parameter                 PACKET_MODE = "False", // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
    parameter                 MEM_STYLE = "Distributed", // Memory style: "Distributed" or "Block"
    parameter                 DUAL_CLOCK = "False", // Dual clock fifo: "True" or "False"
    parameter integer         SYNC_STAGES = 2, // Number of synchronization stages in dual clock mode: [2, 3, 4]
    parameter                 RESET_SYNC = "False", // Asynchronous reset synchronization: "True" or "False"
    parameter integer         PROG_FULL = 12, // Programmable full threshold
    parameter integer         PROG_EMPTY = 4, // Programmable empty threshold
    parameter reg       [0:3] PAYLOAD_MASK = 4'b1111, // Mask in which each bit, when zero removes the data from the payload: [6 - tuser | 5 - tdest | 4 - tid | 3 - tlast | 2 - tkeep | 1 - tstrb | 0 - tdata]
    parameter reg       [7:0] FEATURES = 8'b0000_0000, // Use advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ] 
    parameter integer         CW = $clog2(DEPTH)+1 // Count width
  )  (
    input   wire                 i_fifo_a_rst_n, // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

    // AXI4-Stream slave interface
    input   wire                 s_axis_a_clk_p,
    input   wire                 s_axis_a_rst_n,

    input   wire                 s_axis_tvalid,
    output  wire                 s_axis_tready,
    input   wire [8*TDATA_W-1:0] s_axis_tdata,
    input   wire [  TDATA_W-1:0] s_axis_tstrb,
    input   wire [  TDATA_W-1:0] s_axis_tkeep,
    input   wire                 s_axis_tlast,
    input   wire [    TID_W-1:0] s_axis_tid,
    input   wire [  TDEST_W-1:0] s_axis_tdest,
    input   wire [  TUSER_W-1:0] s_axis_tuser,

    // AXI4-Stream master interface
    input   wire                 m_axis_a_clk_p,
    input   wire                 m_axis_a_rst_n,

    output  wire                 m_axis_tvalid,
    input   wire                 m_axis_tready,
    output  wire [8*TDATA_W-1:0] m_axis_tdata,
    output  wire [  TDATA_W-1:0] m_axis_tstrb,
    output  wire [  TDATA_W-1:0] m_axis_tkeep,
    output  wire                 m_axis_tlast,
    output  wire [    TID_W-1:0] m_axis_tid,
    output  wire [  TDEST_W-1:0] m_axis_tdest,
    output  wire [  TUSER_W-1:0] m_axis_tuser,

    output  wire                 o_fifo_a_tfull, // Almost full flag
    output  wire                 o_fifo_p_tfull, // Programmable full flag
    output  wire [       CW-1:0] o_fifo_w_count, // Write data count

    output  wire                 o_fifo_a_empty, // Almost empty flag
    output  wire                 o_fifo_p_empty, // Programmable empty flag
    output  wire [       CW-1:0] o_fifo_r_count  // Read data count, if dual clock mode is false - output count is the same with write data count
  );

  axis_fifo_w #(
    .TDATA_W        ( TDATA_W ), // AXI4-Stream TDATA width in bytes
    .TID_W          ( TID_W ), // AXI4-Stream TID width
    .TDEST_W        ( TDEST_W ), // AXI4-Stream TDEST width
    .TUSER_W        ( TUSER_W ), // AXI4-Stream TUSER width
    .DEPTH          ( DEPTH ), // Depth of fifo, minimum is 16, actual depth will be displayed in the information of module
    .PACKET_MODE    ( PACKET_MODE ), // Packet mode, when true the FIFO outputs data only when a tlast is received or the FIFO has filled
    .MEM_STYLE      ( MEM_STYLE ), // Memory style: "Distributed" or "Block"
    .DUAL_CLOCK     ( DUAL_CLOCK ), // Dual clock fifo: "True" or "False"
    .SYNC_STAGES    ( SYNC_STAGES ), // Number of synchronization stages in dual clock mode: [2, 3, 4]
    .RESET_SYNC     ( RESET_SYNC ), // Asynchronous reset synchronization: "True" or "False"
    .PROG_FULL      ( PROG_FULL ), // Programmable full threshold
    .PROG_EMPTY     ( PROG_EMPTY ), // Programmable empty threshold
    .PAYLOAD_MASK   ( PAYLOAD_MASK ), // Mask in which each bit, when zero removes the data from the payload: [6 - tuser | 5 - tdest | 4 - tid | 3 - tlast | 2 - tkeep | 1 - tstrb | 0 - tdata]
    .FEATURES       ( FEATURES ) // Use advanced features: [ 6 - read count | 5 - prog. empty flag | 4 - almost empty | 2 - write count | 1 - prog. full flag | 0 - almost full flag ]
  ) axis_fifo_w_inst (
    .i_fifo_a_rst_n ( i_fifo_a_rst_n  ), // Asynchronous reset, connect only when reset synchronization is true, active low, must be asserted at least 2 slowest clock cycles

    // AXI4-Stream slave interface
    .s_axis_a_clk_p ( s_axis_a_clk_p  ),
    .s_axis_a_rst_n ( s_axis_a_rst_n  ),

    .s_axis_tvalid  ( s_axis_tvalid   ),
    .s_axis_tready  ( s_axis_tready   ),
    .s_axis_tdata   ( s_axis_tdata    ),
    .s_axis_tstrb   ( s_axis_tstrb    ),
    .s_axis_tkeep   ( s_axis_tkeep    ),
    .s_axis_tlast   ( s_axis_tlast    ),
    .s_axis_tid     ( s_axis_tid      ),
    .s_axis_tdest   ( s_axis_tdest    ),
    .s_axis_tuser   ( s_axis_tuser    ),

    // AXI4-Stream master interface
    .m_axis_a_clk_p ( m_axis_a_clk_p  ),
    .m_axis_a_rst_n ( m_axis_a_rst_n  ),

    .m_axis_tvalid  ( m_axis_tvalid   ),
    .m_axis_tready  ( m_axis_tready   ),
    .m_axis_tdata   ( m_axis_tdata    ),
    .m_axis_tstrb   ( m_axis_tstrb    ),
    .m_axis_tkeep   ( m_axis_tkeep    ),
    .m_axis_tlast   ( m_axis_tlast    ),
    .m_axis_tid     ( m_axis_tid      ),
    .m_axis_tdest   ( m_axis_tdest    ),
    .m_axis_tuser   ( m_axis_tuser    ),

    .o_fifo_a_tfull ( o_fifo_a_tfull  ), // Almost full flag
    .o_fifo_p_tfull ( o_fifo_p_tfull  ), // Programmable full flag
    .o_fifo_w_count ( o_fifo_w_count  ), // Write data count

    .o_fifo_a_empty ( o_fifo_a_empty  ), // Almost empty flag
    .o_fifo_p_empty ( o_fifo_p_empty  ), // Programmable empty flag
    .o_fifo_r_count ( o_fifo_r_count  )  // Read data count, if dual clock mode is false - output count is the same with write data count
  );

endmodule : fifo_axis