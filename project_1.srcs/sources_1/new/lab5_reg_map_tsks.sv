`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2024 08:59:34 PM
// Design Name: 
// Module Name: lab5_reg_map_tsks
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


module lab5_reg_map_tsks#(
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
    
//    `define MACRO_AXIL_HSK(miso, mosi) \
//		s_axil.``mosi``= '1; \
//		do begin \
//			#1; \
//			//s_axil.``mosi``= '1; \
//		end while (!(s_axil.``miso`` && s_axil.``mosi``)); \
//		s_axil.``mosi`` = '0; \
    
    task t_axil_init;
		begin

			s_axil.awvalid = '0;
			s_axil.awaddr  = '0;
			s_axil.wvalid  = '0;
			s_axil.wdata   = '0;
			s_axil.wstrb   = '0;
			s_axil.bready  = '0;
			s_axil.arvalid = '0;
			s_axil.araddr  = '0;
			s_axil.rready  = '0;
			s_axil.rresp   = '0;
			
		end
	endtask : t_axil_init
    
    `define MACRO_AXIL_HSK(miso, mosi) \
		//s_axil.``mosi``= '1; \
		if ((s_axil.``miso`` && s_axil.``mosi``)) s_axil.``miso`` = '0; \
		else s_axil.``miso`` = '1; \
    
    task t_axil_hw;
		output t_xaddr ADDR;
		output t_xdata DATA;
		begin
		// write address
			ADDR=s_axil.awaddr;
			`MACRO_AXIL_HSK(awready, awvalid);
		// write data
			DATA=s_axil.wdata;
			//s_axil.wstrb = '1;
			`MACRO_AXIL_HSK(wready, wvalid);
		// write response
			//`MACRO_AXIL_HSK(bvalid, bready);
		end
	endtask : t_axil_hw
    
	always_ff @(posedge i_clk) begin

	   t_axil_hw(.ADDR(q_wr_addr),.DATA(q_wr_data));
	   
	   case(q_wr_addr)
	       LEN_ADDR: begin
	           o_lenght=q_wr_data;
	       end
	   endcase
	   
	   if (i_rst) t_axil_init;
	   
	end	
    
    
endmodule
