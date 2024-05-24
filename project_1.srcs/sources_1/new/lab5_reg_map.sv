`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2024 11:04:05 PM
// Design Name: 
// Module Name: lab5_reg_map
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


module lab5_reg_map #(
    int G_RM_ADDR_W = 4, // AXIL xADDR bit width
    int G_RM_DATA_B = 8 // AXIL xDATA number of bytes (B)
)(

    input i_rst,
    input i_clk,
    output reg [31:0] o_lenght,
    output reg [31:0] o_err,
    input i_err_mtlast,i_err_crc,i_err_utlast,
    
    if_axil.s s_axi, // AXI4-Lite slave interface
    if_axil.m m_axi // AXI4-Lite master interface
    
    );
    
    localparam C_RM_DATA_W = 8 * G_RM_DATA_B;

    typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
    typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;

    localparam t_xaddr LEN_ADDR    = 'h00; 
    localparam t_xdata ERR_ADDR = 'h04; 
    
    enum {S0_ADDR_READY,
              S1_RD_ADDR,
              S2_RD_DATA,
              S3_SAVE_DATA
              } S;
    
    t_xaddr q_wr_addr;
    t_xdata q_wr_data;
    
	always_ff @(posedge i_clk) begin
	
	   if (s_axil.awvalid & s_axil.awready) q_wr_addr=s_axil.awaddr;
	   
	   if (s_axil.wvalid & s_axil.wready) q_wr_data=s_axil.wdata;
	   
	   if (s_axil.wvalid) begin
	       case(s_axil.awaddr)
	           LEN_ADDR:o_lenght<=q_wr_data;
	       endcase
	   end
	   
	   if (i_rst) begin
	       S<=S0_ADDR_READY;
	       q_wr_addr<=0;
	   end
	   
	   if (!i_rst) begin
	       s_axi.awready='1; 
	       s_axi.wready='1; 
	   end
	   
	end	
    
    
endmodule
