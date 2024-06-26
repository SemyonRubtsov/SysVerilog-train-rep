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
    int G_RM_DATA_B = 4 // AXIL xDATA number of bytes (B)
)(

    input i_rst,
    input i_clk,
    output reg [31:0] o_lenght,
    output reg [31:0] o_err,
    input logic i_err_mtlast,i_err_crc,i_err_utlast,
    
    if_axil.s s_axi // AXI4-Lite slave interface

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
    logic q_wr_vld;
    logic q_sv_vld;
    //logic q__vld;
    t_xaddr q_rd_addr;
    t_xdata q_rd_data;
    logic q_rd_a_vld;
    logic q_rd_d_vld;
    
    logic q_err_save;
    logic q_err_vld;
    logic cur_err;
    
    always_comb begin
        
        //o_err=0;
	   //else o_err='0;
	   
    end
    
	always_ff @(posedge i_clk) begin
	   
	   if (q_wr_addr==='x) q_wr_addr<=5;
	   if (q_rd_addr==='x) q_rd_addr<=5;
	   //if (q_rd_addr==='x) q_wr_addr<=5;
	   
	   if (!i_rst) begin
	       s_axi.awready<='1; 
	       s_axi.arready<='1; 
	       s_axi.wready<='1;
	       
	       s_axi.rvalid<='0; 
	   end
	   
	   //------------------------------------write in regs---------------------------------
	   
	   if (s_axi.awvalid & s_axi.awready) begin
	       q_wr_addr<=s_axi.awaddr;
	       s_axi.awready<='0;
	       q_wr_vld<='1;
	       
	   end
	   
	   if (s_axi.wvalid & s_axi.wready) begin
	       q_wr_data<=s_axi.wdata;
	       s_axi.wready<=0;
	       q_wr_vld<='0;
	   end
	   
	   if (s_axi.wready & s_axi.wvalid & q_wr_vld) q_sv_vld<=1;
	   
	   if (q_sv_vld) begin
	       case(q_wr_addr)
	           LEN_ADDR: o_lenght<=q_wr_data;
	       endcase
	       q_sv_vld<=0;
	       s_axi.bvalid<='1;
	   end
	   
	   if (s_axi.bvalid & s_axi.bready) s_axi.bvalid<='0;
	   
	   //o_err <= {7'b0,i_err_mtlast,7'b0,i_err_crc,7'b0,i_err_utlast};
	     
	   
	   
	   //if (o_err>0) q_err_save<='1;
	   
	   //-----------------------------------------------------------------------------------
	   
	   //--------------------------------------read from regs----------------------------------
	   
	   if (s_axi.arvalid & s_axi.arready) begin
	       s_axi.arready<='0;
	       q_rd_addr<=s_axi.araddr;
	       q_rd_a_vld<=1;
	       s_axi.rready<=0;
	   end
	   //if (s_axi.rvalid & s_axi.rready) begin
	   //    q_wr_data<=s_axi.wdata;
	   //    s_axi.wready<=0;
	   //end
	   
	   o_err <= (o_err | {7'b0,i_err_mtlast,7'b0,i_err_crc,7'b0,i_err_utlast});
	   
	   if (cur_err) o_err <= {7'b0,i_err_mtlast,7'b0,i_err_crc,7'b0,i_err_utlast};
	   
	   if (o_err>0 & !cur_err) begin 
	       q_err_save <= '1;
	       //cur_err<=1;
	   end
	   
	   //cur_err<=(i_err_mtlast | i_err_crc | i_err_utlast);
	   //q_err_vld <= (!o_err>0 & (i_err_mtlast | i_err_crc | i_err_utlast));
	   
	   if (q_rd_a_vld) begin
	       //s_axil.wready<=0;
	       case(q_rd_addr)
	           LEN_ADDR: begin q_rd_data<=o_lenght; end
	           ERR_ADDR: begin
	               q_rd_data<=o_err;
	               o_err <= {7'b0,i_err_mtlast,7'b0,i_err_crc,7'b0,i_err_utlast};
	               cur_err<=0;
	               if (i_err_mtlast | i_err_crc | i_err_utlast) cur_err<=1;
	               //else o_err <= {7'b0,i_err_mtlast,7'b0,i_err_crc,7'b0,i_err_utlast};
	               q_err_save <= '0;
	               //cur_err<=0;
	           end
	       endcase
	       q_rd_a_vld<=0;
	       q_rd_d_vld<=1;
	   end
	   
	   if (q_rd_d_vld) begin
	       s_axi.rdata<=q_rd_data;
	       s_axi.rvalid<='1;
	       q_rd_d_vld<=0;
	       //s_axi.rresp<='1;
	       //s_axi.rvalid<=s_axi.rready;
	       //s_axi.rvalid <= 0;
	   end
	   
	   if (s_axi.rvalid & s_axi.rready) s_axi.rvalid<='0;
	   s_axi.rresp<=0;
	   //if (s_axi.rready & s_axi.rvalid) begin
	       //s_axi.rvalid<='0;
	   //end
	   
	   //s_axi.rvalid<=s_axi.rready;
	   //if (s_axi.rready) s_axi.rvalid<=1;
	   
	   //o_err<={6'b0,i_err_mtlast,6'b0,i_err_crc,6'b0,i_err_utlast};
	   
	   //------------------------------------------------------------------------------------
	   
	   if (i_rst) begin
	       s_axi.rvalid<='0; 
	       q_wr_vld<='0;
	       q_err_save<=0;
	       o_err<=0;
	       //q_wr_data<=0;
	       //q_wr_addr<=0;
	       //q_rd_addr
	       //q_rd_add
	       q_sv_vld<=0;
	       o_lenght<=10;
	       S<=S0_ADDR_READY;
	       //q_wr_addr<=0;
	   end
	   
	end	
    
    
endmodule
