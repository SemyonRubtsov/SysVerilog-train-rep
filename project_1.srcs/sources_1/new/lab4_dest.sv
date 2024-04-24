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
    parameter G_BYT = 1,
    parameter P_LEN = 10,
    parameter CRC_WAIT=1
) (

    input i_clk,
    input i_rst,
   
    output logic err,
    output logic succes,
    
    if_axis.s s_axis              // input wire s_axis_tlast
    
);
    
    logic [G_BYT*8-1:0] o_crc_res_dat='0;
    logic [G_BYT*8-1:0] i_crc_wrd_dat='0;
    logic m_wrd_vld='0;
    logic m_crc_rst='0;
    logic m_receive;
    logic o_crc_res_vld;
    int m_pkt_len;
    int m_byte_counter;
    
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
        .i_crc_s_rst_p(succes),
        .i_crc_ini_vld('0),
        .i_crc_wrd_vld(m_receive),
        .i_crc_ini_dat('0),
        .i_crc_wrd_dat(s_axis.tdata),
        .o_crc_wrd_rdy (),
        .o_crc_res_vld (o_crc_res_vld),
        .o_crc_res_dat(o_crc_res_dat)
    );
    
    enum logic [3:0] {S0 = 3'b001,
                     S1 = 3'b010,
                     S2 = 3'b011,
                     S3 = 3'b100,
                     S4 = 3'b101,
                     S5 = 3'b110,
                     S6 = 3'b111} S;
    
    //assign m_receive = s_axis.tvalid & !s_axis.tlast;
    
    always_ff @(posedge i_rst) begin
        s_axis.tready = '1;
        //S<=S0;
        //err<='0;
        //s_axis.tvalid = '0;
        //s_axis.tlast  = '0;
        //s_axis.tdata  = '0;
    end
    
    //assign err = i_crc_wrd_dat;
    //assign i_crc_wrd_dat = s_axis.tdata;
    //assign S = !s_axis.tvalid ? S3:S;
    //if (!s_axis.tvalid) S=S3;
    
    always_ff @(posedge i_clk) begin
        
        if (i_rst) begin
            S<=S0;
            succes='0;
        end
        
        if (s_axis.tlast) R_CRC<=s_axis.tdata;
        
        if (o_crc_res_vld) C_CRC<=o_crc_res_dat;
        
        //else cnt<=cnt+1;
        //err<=s_axis.tdata[0];
        
        case(S)
            S0: begin
            
                //err<=(C_CRC==R_CRC) ? '1:'0;
                
                //if (!o_crc_res_vld) begin
                if (C_CRC==R_CRC) begin 
                    err<='0;
                    succes<='0;
                end
                else begin
                    err<='1;
                    succes<='0;
                end
                //end
                
                if (s_axis.tvalid) begin
                   S <= S2;
                   m_pkt_len<='0;
                   m_byte_counter<=0;
                   //m_receive<='1;
                   //m_axis.tvalid <= '0;   
                end
            end
            S1: begin
                if (s_axis.tvalid) begin
                    S<=S2;
                end
            end
            S2: begin
            
                m_receive<=(s_axis.tvalid & !s_axis.tlast);
                
                if (!m_pkt_len) m_pkt_len<=s_axis.tdata;
                m_byte_counter<=m_byte_counter+1;
                
                if (m_byte_counter == m_pkt_len & m_pkt_len!=0) begin
                    m_receive<='0;
                    succes<='1;
                    err<='0;
                    //S<=S0;
                    //else S<=S0;
                end
                
                if (s_axis.tlast) S<=S0;
                
            end
            S3: begin
                //if (o_crc_res_vld) C_CRC<=o_crc_res_dat;
                
                if (s_axis.tvalid) begin
                    S<=S2;
                    //err<='0;
                    //succes<='1;
                end
                
            end
            S4: begin
            
                if (C_CRC!=R_CRC) begin
                    err<='1;
                    succes<='0;
                end
                
                if (s_axis.tvalid) begin
                    S<=S2;
                end
                
            end
        endcase 
        
        //m_wrd_vld <= (s_axis.tvalid & !s_axis.tlast) ? '1 : '0;
        //cnt<=(cnt>=10) ? cnt<=cnt+1: cnt<='0;
    end
        //s_axis.tready=~s_axis.tready;
    
    //end
endmodule
