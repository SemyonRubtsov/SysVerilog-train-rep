`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 07:50:02 PM
// Design Name: 
// Module Name: lab4_dest
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


module lab4_dest#(
    parameter G_BYT = 1
    //parameter P_LEN = 10,
    //parameter CRC_WAIT=1
) (

    input i_clk,
    input i_rst,
    input logic i_ready,
   
    output logic o_err,
    output logic o_succes,
    
    if_axis.s s_axis              // input wire s_axis_tlast
    
);
    
    logic [G_BYT*8-1:0] o_crc_res_dat;
    logic [G_BYT*8-1:0] i_crc_wrd_dat='0;
    logic m_wrd_vld='0;
    logic m_crc_rst='0;
    logic m_receive;
    logic S;
    logic o_crc_res_vld;
    logic m_cor_len;
    int m_pkt_len;
    int m_byte_counter;
    logic m_crc_wrd_vld=0;
    
    reg [8:0] R_CRC='0;
    reg [8:0] C_CRC='0;
    
    crc #(
        .POLY_WIDTH (8), // Size of The Polynomial Vector
		.WORD_WIDTH (8), // Size of The Input Words Vector
		.WORD_COUNT (0), // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5), // Polynomial Bit Vector
		.INIT_VALUE ('h01), // Initial Value
		//.CRC_REF_IN ('0), // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		//.CRC_REFOUT ('0), // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		//.BYTES_RVRS ('0) // Input Word Byte Reverse
		.XOR_VECTOR ('0), // CRC Final Xor Vector
		.NUM_STAGES (1)  // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3..NUM_STAGES(1) // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
    ) g_crc (
        .i_crc_a_clk_p(i_clk),
        .i_crc_s_rst_p(m_crc_rst),
        .i_crc_ini_vld('0),
        .i_crc_wrd_vld(s_axis.tready & s_axis.tvalid & S),//m_receive),
        //.i_crc_wrd_vld(m_crc_wrd_vld),
        .i_crc_ini_dat('0),
        .i_crc_wrd_dat(s_axis.tdata),
        .o_crc_wrd_rdy (),
        .o_crc_res_vld (o_crc_res_vld),
        .o_crc_res_dat(o_crc_res_dat)
    );
    
    //assign m_receive = s_axis.tvalid & !s_axis.tlast;
    
    //always_ff @(posedge i_rst) begin
        //s_axis.tready = '1;
        //S<=0;
    //end
    
    //assign s_axis.tready=i_ready;
    
    
    always_ff @(negedge S) begin
       C_CRC<=o_crc_res_dat;
       //m_crc_rst<=';
    end;
    
    always_ff @(posedge s_axis.tlast) begin
       R_CRC<=s_axis.tdata;
       //m_crc_rst<=';
    end;
    
    //always_ff @(posedge s_axis.tready & S) begin
        //m_crc_rst<=1;
    //end
    
    always_comb begin
    if (m_byte_counter==0)
        m_crc_rst='1;
    else
        m_crc_rst='0;
    end
    
    always_ff @(posedge i_clk) begin
        
        //.if (s_axis.tlast) R_CRC<=s_axis.tdata;
        s_axis.tready<=i_ready;
        //if (o_crc_res_vld) C_CRC<=o_crc_res_dat;
        //m_crc_rst<='0;
        //if (s_axis.tready & S)
        
        case(S)
            0: begin
                if(!i_rst) begin
                    if (C_CRC==R_CRC) begin 
                        o_err<='0;
                        o_succes<='1;
                    end
                    else if (o_crc_res_vld) begin
                        o_err<='1;
                        o_succes<='0;
                    end
                    
                    //m_crc_rst<='1;
                    
                    if (s_axis.tvalid & s_axis.tready) begin
                       S <= 1;
                       //m_pkt_len<=s_axis.tdata;
                       m_byte_counter<=0;
                       //if (s_axis.tready)
                       //m_crc_rst<='1;
                       
                       m_cor_len<='0;
                    end
                end
            end
            1: begin
                //m_crc_rst<='0;
                //m_crc_rst='0;
                
                
                
                m_receive<=(s_axis.tready & s_axis.tvalid & !s_axis.tlast);
                
                //if (m_receive) m_pkt_len<=s_axis.tdata;
                if (m_byte_counter<m_pkt_len & s_axis.tready)
                    m_byte_counter<=m_byte_counter+1;
                
                if (m_byte_counter-1 == m_pkt_len & m_pkt_len!=0) begin
                    //m_receive<='0;
                    //o_succes<='1;
                    //o_err<='0;
                    if (s_axis.tlast) begin
                        //m_cor_len<='1;
                        o_succes<='1;
                        o_err<='0;
                    end
                    else begin
                        m_cor_len<='0;
                        o_succes<='0;
                        o_err<='1;
                    end
                end
                
                if (s_axis.tlast) begin
                    S<=0;
                    //m_crc_rst<='1;
                end
            end
        endcase 
        
        if (i_rst) begin
            S<=0;
            s_axis.tready = '1;
            o_succes='0;
            o_err='0;
            m_cor_len<='0;
            m_receive<='0;
            m_byte_counter<=0;
            //m_pkt_len<='0;
        end
        //m_catch_clk<=0;
        //m_catch_s<=0;
    end
    
//    always_ff @ (posedge i_clk) begin
//        m_catch_clk<=i_clk;
//    end
    
//    always_ff @(posedge S) begin
//        m_catch_s<=S;
//       //m_crc_rst<=';
//    end;
    
    
    
    always_ff @(posedge (S & i_clk)) begin
    
    if (m_byte_counter == 0) begin
       m_pkt_len<=s_axis.tdata;
       //m_crc_wrd_vld='1; 
       //m_crc_rst<='1;
    end
    //else m_crc_rst<='0;
    //if (m_byte_counter == m_pkt_len) begin
       //m_pkt_len<=s_axis.tdata;
       //m_crc_wrd_vld='0; 
       //m_crc_rst<=';
    //end
    
    
    end;
endmodule
