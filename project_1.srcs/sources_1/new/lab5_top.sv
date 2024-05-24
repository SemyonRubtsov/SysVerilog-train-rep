`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2024 08:36:16 PM
// Design Name: 
// Module Name: lab5_top
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


module lab5_top #(
	int G_RM_ADDR_W = 12, // AXIL xADDR bit width
	int G_RM_DATA_B = 8 // AXIL xDATA number of bytes (B)
	
	//int G_CG_L      = 39 * 8, // codogram length (L), bytes
	//int G_USER_W    = 1, // sync-pulse-as-TUSER bit width (W)
	//int G_CG_DATA_B = 1, // codogram TDATA number of bytes (B)
	//int G_DG_DATA_B = 32, // datagram TDATA number of bytes (B)
	
	//T_CLK = 1.0, 
	//real dt = 1.0 // clock period ns);
) (
    input i_clk,
    input i_rst,
    
    if_axil.s                 s_axi, // AXI4-Lite slave interface
    if_axil.m                 m_axi // AXI4-Lite master interface
);
    
    wire [31:0] q_p_len;
    logic q_err_mtlast;
    logic q_err_crc;
    logic q_err_utlast;
    logic [2:0] i_rst_lb4;
    
    //assign i_rst_lb4={3{i_rst}};
    
    lab5_reg_map u_reg_map(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .o_lenght(q_p_len),
        .i_err_mtlast(q_err_mtlast),
        .i_err_crc(q_err_crc),
        .i_err_utlast(q_err_utlast),
        
        .s_axi				(s_axi),
		.m_axi				(m_axi)
    );
    
    lab4_top u_lab4(
        .i_clk(i_clk),
        .i_rst({3{i_rst}}),
        .i_p_len(q_p_len[7:0]),
        .o_err_mlast(q_err_mtlast),
        .o_err_crc(q_err_crc),
        .o_err_ulast(q_err_utlast)
    );
endmodule
