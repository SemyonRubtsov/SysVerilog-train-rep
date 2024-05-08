`timescale 1ns / 1ps

`ifdef WR_ADDR_NUM_REG
`else
    `define WR_ADDR_NUM_REG 0
`endif

`define max(a,b) { (a > b) ? a : b }

module tb_fifo;

    localparam DW = 64;
    localparam DR = int'(4*DW);
    localparam FIFO_DEPTH = 64;
    localparam DUAL_CLOCK = "True";
    localparam FWFT = "False";
    localparam MEM_STYLE = "Block";
    localparam EXTRA_REG = "False";
    localparam SYNC_STAGES = 3;
    localparam RESET_SYNC = "True";
    localparam RESET_VALUE = '1;
    localparam FEATURES = 8'h77;
    localparam PROG_FULL = 13;
    localparam PROG_EMPTY = 13;

    localparam READ_MODE = ( FWFT == "True" ) ? "fwft" : "std";
    localparam READ_LATENCY = ( FWFT == "True" ) ? 0 : ( EXTRA_REG == "True" ) ? 2 : 1;

    localparam READ_DEPTH = int'(FIFO_DEPTH*DW/DR);

    localparam AW = $clog2(FIFO_DEPTH);
    localparam AR = $clog2(READ_DEPTH);

    localparam WR_DEPTH = ( `WR_ADDR_NUM_REG == 0 && FWFT == "False" ) ? 2**AW :
                          ( `WR_ADDR_NUM_REG == 0 && FWFT == "True" ) ? 2**AW+2 : 
                          ( `WR_ADDR_NUM_REG == 1 && FWFT == "False" ) ? 2**AW-1 :
                          ( `WR_ADDR_NUM_REG == 1 && FWFT == "True" ) ? 2**AW+1 : 0;

    localparam RD_DEPTH = ( `WR_ADDR_NUM_REG == 0 && FWFT == "False" ) ? 2**AR :
                          ( `WR_ADDR_NUM_REG == 0 && FWFT == "True" ) ? 2**AR+2 : 
                          ( `WR_ADDR_NUM_REG == 1 && FWFT == "False" ) ? 2**AR-1 :
                          ( `WR_ADDR_NUM_REG == 1 && FWFT == "True" ) ? 2**AR+1 : 0;

    localparam W_CLK_PRD = 2.48;
    localparam R_CLK_PRD = ( DUAL_CLOCK == "False" ) ? W_CLK_PRD : 2.0;
    localparam C_CLK_MAX = ( W_CLK_PRD > R_CLK_PRD ) ? W_CLK_PRD : R_CLK_PRD;

    typedef logic [DW-1:0] t_dwr;
    typedef logic [DR-1:0] t_drd;
 
    bit w_fifo_a_rst_n = '1;
    bit c_fifo_w_clk_p = '0;
    bit c_fifo_r_clk_p = '0;
    bit w_fifo_w_rst_n = '1;
    bit q_fifo_w_rst_n = '1;
    bit w_fifo_r_rst_n = '1;
    bit q_fifo_r_rst_n = '1;
    bit w_fifo_dat_wen = '0;
    bit w_fifo_dat_ren = '0;

    logic w_fifo_fll_flg;
    logic w_fifo_a_tfull;
    logic w_fifo_ety_flg;
    logic w_fifo_a_empty;
    logic w_fifo_dat_vld;
    t_drd w_fifo_dat_bus;

    logic w_fifo_p_tfull = '0;
    logic [$clog2(FIFO_DEPTH):0] w_fifo_w_count = '0;
    logic w_fifo_p_empty = '0;
    logic [$clog2(READ_DEPTH):0] w_fifo_r_count = '0;

    // always begin 
    //     #(2*C_CLK_MAX)                     w_fifo_a_rst_n <= '1;
    //     #($urandom_range(10000, 50000))    w_fifo_a_rst_n <= '0;
    //     #(1*C_CLK_MAX)                     w_fifo_a_rst_n <= '1;
    //     #($urandom_range(10000, 50000))    w_fifo_a_rst_n <= '0;
    // end

    // always begin 
    //     #($urandom_range(1, 10)*W_CLK_PRD)      w_fifo_w_rst_n <= '1;
    //     #($urandom_range(1000, 5000)*W_CLK_PRD) w_fifo_w_rst_n <= '0;
    // end

    // if ( DUAL_CLOCK == "True" ) begin : dual_rd_reset
    //     always begin 
    //         #($urandom_range(1, 10)*R_CLK_PRD)      w_fifo_r_rst_n <= '1;
    //         #($urandom_range(1000, 5000)*R_CLK_PRD) w_fifo_r_rst_n <= '0;
    //     end
    // end else 
    //     assign w_fifo_r_rst_n = w_fifo_w_rst_n;

    // initial begin
    //     #(500ns)
    //         w_fifo_w_rst_n <= '0;
    //     #(10ns)
    //         w_fifo_w_rst_n <= '1;
    //     #($urandom_range(100000, 500000))
    //         w_fifo_w_rst_n <= '0;
    //     #(10ns)
    //         w_fifo_w_rst_n <= '1;
    //     #($urandom_range(1000000, 500000))
    //         w_fifo_w_rst_n <= '0;
    //     #(10ns)
    //         w_fifo_w_rst_n <= '1;
    //     #($urandom_range(100000, 500000))
    //         w_fifo_w_rst_n <= '0;
    //     #(10ns)
    //         w_fifo_w_rst_n <= '1;
    // end

    always @(posedge c_fifo_w_clk_p)
        q_fifo_w_rst_n <= w_fifo_w_rst_n;

    always @(posedge c_fifo_r_clk_p)
        q_fifo_r_rst_n <= ( DUAL_CLOCK == "True" ) ? w_fifo_r_rst_n : w_fifo_w_rst_n;

    logic w_fifo_w_rst_p;
    assign w_fifo_w_rst_p = !w_fifo_w_rst_n;

    logic w_fifo_r_rst_p;
    assign w_fifo_r_rst_p = !w_fifo_r_rst_n;

    logic q_fifo_dat_wen = '0;
    t_dwr q_fifo_dat_bus = '0;
    always @(posedge c_fifo_w_clk_p) begin
        q_fifo_dat_wen <= w_fifo_dat_wen;
        q_fifo_dat_bus <= q_fifo_dat_bus + 1;
    end

    logic q_fifo_dat_ren = '0;
    always @(posedge c_fifo_r_clk_p)
        q_fifo_dat_ren <= w_fifo_dat_ren;

    bit WR_SEQ_END = '0;
    bit RD_SEQ_END = '0;

    task wr_sequence(input int unsigned K = 1, int unsigned LENGTH = 16, RANDOM = "No", int unsigned L = 7, int unsigned H = 7, bit STOP = '0 );

        w_fifo_dat_wen = '1;

        if ( STOP )
            disable wr_sequence;

        repeat ( LENGTH ) begin
            
            if ( STOP ) break;

            if ( RANDOM == "No" ) begin
                if ( K == 0 ) begin
                    #(1*W_CLK_PRD) w_fifo_dat_wen = '1;
                end else begin
                    #(1*W_CLK_PRD) w_fifo_dat_wen = '0;
                    #(K*W_CLK_PRD) w_fifo_dat_wen = '1;
                end
            end else if ( RANDOM == "Yes" ) begin 
                #($urandom_range(1,H)*W_CLK_PRD) w_fifo_dat_wen = '0;
                #($urandom_range(1,L)*W_CLK_PRD) w_fifo_dat_wen = '1;
            end

        end

        w_fifo_dat_wen = '0;

        @(posedge c_fifo_w_clk_p) WR_SEQ_END = '1;
        @(posedge c_fifo_w_clk_p) WR_SEQ_END = '0;

    endtask

    task rd_sequence(input int unsigned K = 1, int unsigned LENGTH = 16, RANDOM = "No", int unsigned L = 7, int unsigned H = 7, bit STOP = '0 );
        
        w_fifo_dat_ren = '1;

        repeat ( LENGTH ) begin 

            if ( STOP ) break;

            if ( RANDOM == "No" ) begin
                if ( K == 0 ) begin
                    #(1*R_CLK_PRD) w_fifo_dat_ren = '1;
                end else begin
                    #(1*R_CLK_PRD) w_fifo_dat_ren = '0;
                    #(K*R_CLK_PRD) w_fifo_dat_ren = '1;
                end
            end else if ( RANDOM == "Yes" ) begin 
                #($urandom_range(1,H)*R_CLK_PRD) w_fifo_dat_ren = '0;
                #($urandom_range(1,L)*R_CLK_PRD) w_fifo_dat_ren = '1;
            end

        end

        w_fifo_dat_ren = '0;

        @(posedge c_fifo_r_clk_p) RD_SEQ_END = '1;
        @(posedge c_fifo_r_clk_p) RD_SEQ_END = '0;

    endtask

// Standard Queue
    t_dwr u_test_dat_mem [$:WR_DEPTH];
    t_drd u_test_dat_out = RESET_VALUE;

    int u_test_s_queue; // size queue
    bit u_test_f_queue; // full queue
    bit u_test_e_queue; // empty queue
    bit u_test_f_check; // check full
    bit u_test_e_check; // check empty

    bit u_test_d_check = '1;
    bit u_test_r_check = '1;
    bit [0:10] u_test_c_phase = '1;

    int u_test_d_delta [3] = '{default:0};
    always @(posedge c_fifo_r_clk_p) begin
        if ( w_fifo_dat_vld )
            u_test_d_delta[0:1] <= { w_fifo_dat_bus, u_test_d_delta[0]};
        u_test_d_delta[2] = u_test_d_delta[0] - u_test_d_delta[1];
    end 

// Check the correctness of the read data from fifo

    // always @(posedge c_fifo_w_clk_p)
    //     if ( UUT.m_fifo_w_rst_p )
    //         u_test_dat_mem <= {};
    //     else if ( q_fifo_dat_wen && !w_fifo_fll_flg )
    //         u_test_dat_mem.push_back(q_fifo_dat_bus);

    // if ( FWFT == "False" ) begin : norm_read_data

    //     always @(posedge c_fifo_r_clk_p)
    //         if ( UUT.m_fifo_r_rst_p )
    //             u_test_dat_out <= RESET_VALUE;
    //         else if ( q_fifo_dat_ren && !w_fifo_ety_flg )
    //             u_test_dat_out <= u_test_dat_mem.pop_front();

    // end else if ( FWFT == "True" ) begin : fwft_read_data

    //     logic q_fwft_ety_flg = '0;
    //     logic q_fwft_ety_edg = '0;
    //     logic q_fwft_dat_ren = '0;
    //     logic q_fwft_ren_edg = '0;

    //     always @(posedge c_fifo_r_clk_p)
    //         q_fwft_ety_flg <= w_fifo_ety_flg;

    //     always @(*) 
    //         if ( !q_fwft_ety_flg ) 
    //             q_fwft_ety_edg = '0;
    //         else if ( !w_fifo_ety_flg ) 
    //             q_fwft_ety_edg = '1;

    //     always @(posedge c_fifo_r_clk_p)
    //         q_fwft_dat_ren <= q_fifo_dat_ren && !w_fifo_ety_flg;

    //     always @(posedge c_fifo_r_clk_p)
    //         q_fwft_ren_edg <= q_fifo_dat_ren && !w_fifo_ety_flg;

    //     logic q_fwft_r_rst_p = '0;
    //     always @(posedge c_fifo_r_clk_p)
    //         q_fwft_r_rst_p <= UUT.m_fifo_r_rst_p;

    //     always @(posedge c_fifo_r_clk_p)
    //         if ( q_fwft_r_rst_p ) begin
    //             u_test_dat_out <= RESET_VALUE;
    //         end else if ( q_fwft_ety_edg ) begin
    //             u_test_dat_out <= u_test_dat_mem[0];
    //         end else if ( q_fwft_dat_ren && !w_fifo_ety_flg ) begin
    //             u_test_dat_out <= u_test_dat_mem.pop_front();
    //             u_test_dat_out <= u_test_dat_mem[0];
    //         end else if ( q_fwft_dat_ren ) begin
    //             u_test_dat_out <= u_test_dat_mem.pop_front();
    //         end

    // end

    assign u_test_s_queue = u_test_dat_mem.size();

    if ( FWFT == "False" ) begin : norm_data_check

        if ( EXTRA_REG == "True" ) begin : extra_reg

            t_drd q_test_dat_out = RESET_VALUE;
            always @(posedge c_fifo_r_clk_p)
                if ( UUT.m_fifo_r_rst_p )
                    q_test_dat_out <= RESET_VALUE;
                else
                    q_test_dat_out <= u_test_dat_out;

            always @(*)
                if ( w_fifo_dat_bus != q_test_dat_out ) 
                    u_test_d_check <= '0;
                else
                    u_test_d_check <= '1;

        end else begin : basic_reg
        
            always @(*)
                if ( w_fifo_dat_bus != u_test_dat_out ) 
                    u_test_d_check <= '0;
                else
                    u_test_d_check <= '1;
        end

    end else begin : fwft_data_check

        logic q_fwft_dat_ren = '0;
        t_drd v_fifo_dat_bus = '0;
        always @(posedge c_fifo_r_clk_p) begin
            q_fwft_dat_ren <= q_fifo_dat_ren;
            v_fifo_dat_bus <= w_fifo_dat_bus;
        end

        always @(*)
            if ( q_fwft_dat_ren && v_fifo_dat_bus != u_test_dat_out ) 
                u_test_d_check <= '0;
            else
                u_test_d_check <= '1;

    end 

    always_comb
        if ( !u_test_d_check )
            u_test_r_check <= ( DW == DR ) ? '0 : '1;

    assign u_test_f_queue = ( u_test_s_queue == WR_DEPTH ) ? '1 : '0;

    if ( FWFT == "False" )
        assign u_test_e_queue = ( u_test_s_queue == 0 ) ? '1 : '0;
    else if ( FWFT == "True" )
        always @(posedge c_fifo_r_clk_p)
            u_test_e_queue <= ( u_test_s_queue == 0 ) ? '1 : '0;
    
    assign #(0.5*W_CLK_PRD) u_test_f_check = ( UUT.m_fifo_w_rst_p || UUT.m_fifo_r_rst_p ) ? '1 : ( u_test_f_queue && !w_fifo_fll_flg ) ? '0 : '1;
    assign #(0.5*R_CLK_PRD) u_test_e_check = ( UUT.m_fifo_r_rst_p || UUT.m_fifo_w_rst_p ) ? '1 : ( u_test_e_queue && !w_fifo_ety_flg ) ? '0 : '1;

    // always 
    //     #(W_CLK_PRD)
    //         if ( !u_test_f_check )
    //             $display("%t : full flag benchmark - FAILED!", $time);

    // always 
    //     #(R_CLK_PRD)
    //         if ( !u_test_e_check )
    //             $display("%t : empty flag benchmark - FAILED!", $time);

// Empty flag delay
    localparam EFD = ( DUAL_CLOCK == "False" && FWFT == "False" ) ? R_CLK_PRD : 
                     ( DUAL_CLOCK == "False" && FWFT == "True" ) ? 3*R_CLK_PRD : 
                     ( DUAL_CLOCK == "True" && FWFT == "False" ) ? 2*W_CLK_PRD + (SYNC_STAGES+2)*R_CLK_PRD : 
                     ( DUAL_CLOCK == "True" && FWFT == "True" ) ? 2*W_CLK_PRD + (SYNC_STAGES+2)*R_CLK_PRD+2*R_CLK_PRD : 0;

// Full flag delay
    localparam FFD = ( DUAL_CLOCK == "False" && FWFT == "False" ) ? W_CLK_PRD :
                     ( DUAL_CLOCK == "False" && FWFT == "True" ) ? W_CLK_PRD :
                     ( DUAL_CLOCK == "True" && FWFT == "False" ) ? 2*R_CLK_PRD + (SYNC_STAGES+2)*W_CLK_PRD :
                     ( DUAL_CLOCK == "True" && FWFT == "True" ) ? 2*R_CLK_PRD + (SYNC_STAGES+2)*W_CLK_PRD : 0;        

    localparam int WR_ONE = ( DW > DR ) ? 1 : int'(DR/DW);
    localparam int RD_ONE = ( DR > DW ) ? 1 : int'(DW/DR);

// Let the testing begin for fifo
    initial begin
        $timeformat(-6, 1, "us", 5);
        
        $display("Dual clock fifo is %s", DUAL_CLOCK);
        $display("FIFO FWFT mode is %s", FWFT);
        $display("Write clock period is %3.3f ns.", W_CLK_PRD);
        $display("Read clock period is %3.3f ns.", R_CLK_PRD);
        $display("Depth of FIFO is %0d.", WR_DEPTH);
        $display("Sync stages in FIFO is %0d.\n", SYNC_STAGES);

// Phase 0: check not empty flag on write
        #(1000)
            if ( w_fifo_ety_flg == '1 )
                u_test_c_phase[0] = 1;
            else 
                u_test_c_phase[0] = 0;
            wr_sequence(0, WR_ONE, "No", 1, 1);
        #(EFD) // Lite test
            if ( w_fifo_ety_flg == '0 && u_test_c_phase[0] )
                u_test_c_phase[0] = 1;
            else 
                u_test_c_phase[0] = 0;
            
// Phase 1: check empty flag on read
        #(5*R_CLK_PRD)
            if ( w_fifo_ety_flg == '0 )
                u_test_c_phase[1] = '1;
            else 
                u_test_c_phase[1] = '0;
            rd_sequence(0, RD_ONE, "No", 1, 1);
        #(1*R_CLK_PRD)
            if ( w_fifo_ety_flg == '1 && u_test_c_phase[1] )
                u_test_c_phase[1] = '1;
            else 
                u_test_c_phase[1] = '0;

// Phase 2: check not full flag on write
        #(5*W_CLK_PRD)
            if ( w_fifo_fll_flg == '0 )
                u_test_c_phase[2] = 1;
            else 
                u_test_c_phase[2] = 0;
            wr_sequence(0, WR_DEPTH-1, "No", 1, 1);
        #(1*W_CLK_PRD)
            if ( w_fifo_fll_flg == '0 && u_test_c_phase[2] )
                u_test_c_phase[2] = 1;
            else 
                u_test_c_phase[2] = 0;

// Phase 3: check full flag on write
        #(5*W_CLK_PRD)
            if ( w_fifo_fll_flg == '0 )
                u_test_c_phase[3] = 1;
            else 
                u_test_c_phase[3] = 0;
            wr_sequence(0, WR_ONE, "No", 1, 1);
        #(1*W_CLK_PRD)
            if ( w_fifo_fll_flg == '1 && u_test_c_phase[3] )
                u_test_c_phase[3] = 1;
            else 
                u_test_c_phase[3] = 0;

// Phase 4: check not full flag on read
        #(5*R_CLK_PRD)
            if ( w_fifo_fll_flg == '1 )
                u_test_c_phase[4] = 1;
            else 
                u_test_c_phase[4] = 0;
            rd_sequence(0, RD_ONE, "No", 1, 1);
        #(FFD) // Lite test
            if ( w_fifo_fll_flg == '0 && u_test_c_phase[4] )
                u_test_c_phase[4] = 1;
            else 
                u_test_c_phase[4] = 0;
            
// Phase 5: check not empty flag on read
        #(5*R_CLK_PRD)
            if ( w_fifo_ety_flg == '0 )
                u_test_c_phase[5] = 1;
            else 
                u_test_c_phase[5] = 0;
            rd_sequence(0, RD_DEPTH-2*RD_ONE, "No", 1, 1);
        #(1*R_CLK_PRD)
            if ( w_fifo_ety_flg == '0 && u_test_c_phase[5] )
                u_test_c_phase[5] = 1;
            else 
                u_test_c_phase[5] = 0;

// Phase 6: check empty flag on read
        #(5*R_CLK_PRD)
            if ( w_fifo_ety_flg == '0 )
                u_test_c_phase[6] = 1;
            else 
                u_test_c_phase[6] = 0;
            rd_sequence(0, RD_ONE, "No", 1, 1);
        #(1*R_CLK_PRD)
            if ( w_fifo_ety_flg == '1 && u_test_c_phase[6] )
                u_test_c_phase[6] = 1;
            else 
                u_test_c_phase[6] = 0;

// Display check result of first group
            if ( DUAL_CLOCK == "True" && FWFT == "True" )
                $display("%0t : empty and full flag test is not carried out in ASYNC FIFO FWFT mode!", $time); // FIXME Add to testing
            else 
                if ( & u_test_c_phase[0:6] )
                    $display("%0t : empty and full flag test - PASSED.", $time);
                else
                    $display("%0t : empty and full flag test - FAILED!", $time);

// Phase 7: sequential write to empty fifo with full fill
        #(5*W_CLK_PRD) 
            if ( w_fifo_fll_flg == '0 )
                u_test_c_phase[7] = '1;
            else 
                u_test_c_phase[7] = '0;            
            wr_sequence(1, WR_DEPTH, "No", 1, 1);
        #(1*W_CLK_PRD)
            if ( w_fifo_fll_flg == '1 && u_test_c_phase[7] )
                u_test_c_phase[7] = '1;
            else 
                u_test_c_phase[7] = '0;

// Phase 8: sequentual write to full fifo
        #(5*W_CLK_PRD)
            if ( w_fifo_fll_flg == '1 )
                u_test_c_phase[8] = '1;
            else 
                u_test_c_phase[8] = '0;
            wr_sequence(1, WR_DEPTH, "No", 1, 1);
            if ( w_fifo_fll_flg == '1 && u_test_c_phase[8] )
                u_test_c_phase[8] = '1;
            else 
                u_test_c_phase[8] = '0;

// Phase 9: sequential read from full fifo with full clean 
        #(5*R_CLK_PRD)
            if ( w_fifo_ety_flg == '0 )
                u_test_c_phase[9] = '1;
            else 
                u_test_c_phase[9] = '0;                
            rd_sequence(1, RD_DEPTH, "No", 1, 1);
        #(1*R_CLK_PRD)
            if ( w_fifo_ety_flg == '1 && u_test_c_phase[9] )
                u_test_c_phase[9] = '1;
            else 
                u_test_c_phase[9] = '0;

// Phase 10: sequential read from empty fifo
        #(5*R_CLK_PRD)
            if ( w_fifo_ety_flg == '1 )
                u_test_c_phase[10] = '1;
            else 
                u_test_c_phase[10] = '0;
            rd_sequence(1, RD_DEPTH, "No", 1, 1);
            if ( w_fifo_ety_flg == '1 && u_test_c_phase[10] )
                u_test_c_phase[10] = '1;
            else 
                u_test_c_phase[10] = '0;

// Display check result of second group
        #(1*R_CLK_PRD)
            if ( DUAL_CLOCK == "True" && FWFT == "True" )
                if ( u_test_r_check )
                    $display("%0t : sequential write and read test - PASSED.", $time);
                else
                    $display("%0t : sequential write and read test - FAILED!", $time);
            else
                if ( & u_test_c_phase[7:10] && u_test_r_check )
                    $display("%0t : sequential write and read test - PASSED.", $time);
                else
                    $display("%0t : sequential write and read test - FAILED!", $time);

// Phase 11: simultaneously write and read to/from fifo
        #(5*C_CLK_MAX)
            fork
                wr_sequence(10, R_CLK_PRD*1e+3, "No", 1, 1);
                rd_sequence(10, W_CLK_PRD*1e+3, "No", 1, 1);
            join

// Phase 12: random write and read to/from fifo
        #(5*C_CLK_MAX)
            fork // Write more often
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 1, 18);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 30, 3);
            join
            fork // Read more often
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 5, 10);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 1, 19);
            join
            fork // Write and read and approximately identical
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 1, 21);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 1, 21);
            join
            fork // Write and read and approximately identical
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 20, 5);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 1, 40);
            join
            fork // Write and read and approximately identical
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 1, 40);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 20, 5);
            join
            fork // Write and read and approximately identical
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 16, 64);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 16, 64);
            join
            fork // Write and read and approximately identical
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 64, 16);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 64, 16);
            join
            fork // Write and read and approximately identical
                wr_sequence(0, R_CLK_PRD*1e+4, "Yes", 32, 128);
                rd_sequence(0, W_CLK_PRD*1e+4, "Yes", 32, 128);
            join

// Display check result of third group
        #(1*R_CLK_PRD)
            if ( u_test_r_check )
                $display("%0t : simultaneously and random write and read test - PASSED.", $time);
            else
                $display("%0t : simultaneously and random write and read test - FAILED!", $time);

// Phase 13: always write and read
        #(5*W_CLK_PRD) 
            fork
                wr_sequence(0, W_CLK_PRD*R_CLK_PRD*1e+4, "No", 1, 15);
                rd_sequence(0, R_CLK_PRD*W_CLK_PRD*1e+4, "No", 1, 15);
            join

// Display check result of fourth group
        #(1*R_CLK_PRD)
            if ( u_test_r_check )
                $display("%0t : always write and always read test - PASSED.", $time);
            else
                $display("%0t : always write and always read test - FAILED!", $time);     
    end

    fifo #(
        .DW ( DW ),
        .DR ( DR ),
        .DEPTH ( FIFO_DEPTH ),
        .FWFT ( FWFT ),
        .MEM_STYLE ( MEM_STYLE ),
        .EXTRA_REG ( EXTRA_REG ),
        .DUAL_CLOCK ( DUAL_CLOCK ),
        .SYNC_STAGES ( SYNC_STAGES ),
        .RESET_SYNC ( RESET_SYNC ),
        .PROG_FULL ( PROG_FULL ),
        .PROG_EMPTY ( PROG_EMPTY ),
        .RESET_VALUE ( RESET_VALUE ),
        .FEATURES ( FEATURES )
    ) UUT (
        //.i_fifo_a_rst_n ( w_fifo_a_rst_n ),
        //.i_fifo_w_rst_n ( q_fifo_w_rst_n ),
        .i_fifo_w_clk_p ( c_fifo_w_clk_p ),
        .i_fifo_w_valid ( q_fifo_dat_wen ),
        .i_fifo_w_value ( q_fifo_dat_bus ),
        .o_fifo_w_tfull ( w_fifo_fll_flg ),
        .o_fifo_a_tfull ( w_fifo_a_tfull ),
        .o_fifo_p_tfull ( w_fifo_p_tfull ),
        .o_fifo_w_count ( w_fifo_w_count ),
        //.i_fifo_r_rst_n ( q_fifo_r_rst_n ),
        .i_fifo_r_clk_p ( c_fifo_r_clk_p ),
        .o_fifo_r_empty ( w_fifo_ety_flg ),
        .i_fifo_r_query ( q_fifo_dat_ren ),
        .o_fifo_r_valid ( w_fifo_dat_vld ),
        .o_fifo_r_value ( w_fifo_dat_bus ),
        .o_fifo_a_empty ( w_fifo_a_empty ),
        .o_fifo_p_empty ( w_fifo_p_empty ),
        .o_fifo_r_count ( w_fifo_r_count )
    );

// Circulator
    localparam LENGTH = WR_DEPTH;

    logic u_circ_f_start = '0;
    logic u_circ_f_write = '0;
    logic u_circ_d_valid = '0;
    t_dwr u_circ_d_value = '0;
    t_dwr u_circ_d_queue [2**10];
    initial
        for ( int i = 0; i < $size(u_circ_d_queue); i++ )
            u_circ_d_queue[i] = i; // $urandom_range(0, 2**DW-1)

    logic q_circ_d_valid = '0;

    logic w_wclk_dat_ren;

    logic m_wclk_dat_vld;
    logic w_wclk_dat_wen;
    logic q_wclk_dat_wen = '0;
    t_dwr m_wclk_dat_bus;
    t_dwr w_wclk_dat_bus;

    logic m_wclk_fll_flg;
    logic m_wclk_ety_flg;
    logic q_wclk_fll_flg = '0;

    logic w_rclk_dat_ren;

    logic m_rclk_dat_vld;
    logic w_rclk_dat_wen;
    logic q_rclk_dat_wen = '0;
    t_drd m_rclk_dat_bus;

    logic m_rclk_fll_flg;
    logic m_rclk_ety_flg;
    logic q_rclk_fll_flg = '0;

    initial begin
        $display("Amount of data in the circulator is %0d\n", LENGTH);
        #(4*W_CLK_PRD*R_CLK_PRD)
            u_circ_f_write <= '1;
            for ( int i = 0; i <= LENGTH; i++ ) begin
                @(posedge c_fifo_w_clk_p)
                    if ( !m_wclk_fll_flg ) begin
                        u_circ_d_valid <= '1;
                        u_circ_d_value <= u_circ_d_queue[i];
                    end else begin
                        i--;
                        u_circ_d_valid <= '0;
                    end
            end
            u_circ_f_write <= '0;
            u_circ_d_valid <= '0;
            u_circ_d_value <= '0;
        #(10*W_CLK_PRD)
            u_circ_f_start <= '1;
    end

    always @(posedge c_fifo_w_clk_p)
        if ( m_wclk_fll_flg && u_circ_f_write && u_circ_d_valid )
            q_circ_d_valid <= '1;
        else if ( !m_wclk_fll_flg )
            q_circ_d_valid <= '0;

    assign w_wclk_dat_ren = !m_wclk_ety_flg && 
                            !m_wclk_fll_flg && 
                             u_circ_f_start;

    always @(posedge c_fifo_w_clk_p) begin

        q_wclk_fll_flg <= !m_wclk_fll_flg && 
                           m_wclk_ety_flg; 

        if ( m_wclk_fll_flg && !q_wclk_fll_flg && m_wclk_dat_vld )
            q_wclk_dat_wen <= '1;
        else if ( !m_wclk_fll_flg )
            q_wclk_dat_wen <= '0;
            
    end

    assign w_wclk_dat_wen = ( u_circ_f_start ) ? !m_wclk_fll_flg && m_wclk_dat_vld || q_wclk_dat_wen : !m_wclk_fll_flg && u_circ_d_valid || q_circ_d_valid;
    assign w_wclk_dat_bus = ( u_circ_f_start ) ? m_wclk_dat_bus : u_circ_d_value;

    fifo #(
        .DW ( DW ),
        .DR ( DR ),
        .DEPTH ( FIFO_DEPTH ),
        .DUAL_CLOCK ( DUAL_CLOCK ),
        .FWFT ( FWFT ),
        .MEM_STYLE ( MEM_STYLE ),
        .EXTRA_REG ( EXTRA_REG ),
        .SYNC_STAGES ( SYNC_STAGES ),
        .RESET_SYNC ( RESET_SYNC ),
        .RESET_VALUE ( RESET_VALUE ),
        .FEATURES ( FEATURES )
    ) forward_fifo (
        //.i_fifo_a_rst_n ( w_fifo_a_rst_n ),
        //.i_fifo_w_rst_n ( q_fifo_w_rst_n ),
        .i_fifo_w_clk_p ( c_fifo_w_clk_p ),
        .i_fifo_w_valid ( w_wclk_dat_wen ),
        .i_fifo_w_value ( w_wclk_dat_bus ),
        .o_fifo_w_tfull ( m_wclk_fll_flg ),
        .o_fifo_a_tfull ( ),
        .o_fifo_p_tfull ( ),
        .o_fifo_w_count ( ),
        //.i_fifo_r_rst_n ( q_fifo_r_rst_n ),
        .i_fifo_r_clk_p ( c_fifo_r_clk_p ),
        .o_fifo_r_empty ( m_rclk_ety_flg ),
        .i_fifo_r_query ( w_rclk_dat_ren ),
        .o_fifo_r_valid ( m_rclk_dat_vld ),
        .o_fifo_r_value ( m_rclk_dat_bus ),
        .o_fifo_a_empty ( ),
        .o_fifo_p_empty ( ),
        .o_fifo_r_count ( )
    );

    assign w_rclk_dat_ren = !m_rclk_ety_flg && 
                            !m_rclk_fll_flg;

    always @(posedge c_fifo_r_clk_p) begin

        q_rclk_fll_flg <= !m_rclk_fll_flg && 
                           m_rclk_ety_flg; 

        if ( m_rclk_fll_flg && !q_rclk_fll_flg && m_rclk_dat_vld )
            q_rclk_dat_wen <= '1;
        else if ( !m_rclk_fll_flg )
            q_rclk_dat_wen <= '0;
            
    end

    assign w_rclk_dat_wen = !m_rclk_fll_flg && m_rclk_dat_vld || q_rclk_dat_wen;

    fifo #(
        .DW ( DR ),
        .DR ( DW ),
        .DEPTH ( READ_DEPTH ),
        .DUAL_CLOCK ( DUAL_CLOCK ),
        .FWFT ( FWFT ),
        .MEM_STYLE ( MEM_STYLE ),
        .EXTRA_REG ( EXTRA_REG ),
        .SYNC_STAGES ( SYNC_STAGES ),
        .RESET_SYNC ( RESET_SYNC ),
        .RESET_VALUE ( RESET_VALUE ),
        .FEATURES ( FEATURES )
    ) reverse_fifo (
        //.i_fifo_a_rst_n ( w_fifo_a_rst_n ),
        //.i_fifo_w_rst_n ( q_fifo_r_rst_n ),
        .i_fifo_w_clk_p ( c_fifo_r_clk_p ),
        .i_fifo_w_valid ( w_rclk_dat_wen ),
        .i_fifo_w_value ( m_rclk_dat_bus ),
        .o_fifo_w_tfull ( m_rclk_fll_flg ),
        .o_fifo_a_tfull ( ),
        .o_fifo_p_tfull ( ),
        .o_fifo_w_count ( ),
        //.i_fifo_r_rst_n ( q_fifo_w_rst_n ),
        .i_fifo_r_clk_p ( c_fifo_w_clk_p ),
        .o_fifo_r_empty ( m_wclk_ety_flg ),
        .i_fifo_r_query ( w_wclk_dat_ren ),
        .o_fifo_r_valid ( m_wclk_dat_vld ),
        .o_fifo_r_value ( m_wclk_dat_bus ),
        .o_fifo_a_empty ( ),
        .o_fifo_p_empty ( ),
        .o_fifo_r_count ( )
    );

    bit u_circ_dat_vld;
    assign u_circ_dat_vld = ( FWFT == "False" ) ? m_wclk_dat_vld : m_wclk_dat_vld && !m_wclk_fll_flg;

    logic [$clog2(LENGTH):0] u_circ_counter = '0;
    always @(posedge c_fifo_w_clk_p)
        if ( !q_fifo_r_rst_n )
            u_circ_counter <= '0;
        else if ( u_circ_dat_vld && u_circ_counter == LENGTH-1 )
            u_circ_counter <= '0;
        else if ( u_circ_dat_vld )
            u_circ_counter <= u_circ_counter + 1;

    int test;
    assign test = u_circ_d_queue[u_circ_counter];
    
    logic [47:0] u_circ_num_lap = '0;
    always @(posedge c_fifo_r_clk_p)
        if ( u_circ_dat_vld && u_circ_counter == LENGTH-1 ) 
            u_circ_num_lap <= u_circ_num_lap + 1;

    logic u_circ_d_check;
    assign #(0.5*W_CLK_PRD) u_circ_d_check = ( !m_wclk_dat_vld || m_wclk_dat_vld && w_wclk_dat_bus == u_circ_d_queue[u_circ_counter] ) ? '1 : '0;

    logic [31:0] u_circ_num_fal = '0;
    always @(posedge c_fifo_r_clk_p) 
        if ( u_circ_f_start && !u_circ_d_check ) 
            u_circ_num_fal = u_circ_num_fal + 1;

    always
        #(1ms)
            if ( u_circ_f_start && u_circ_num_fal == 0 )
                $display("%t : circulator test - PASSED.", $time);
            else
                $display("%t : circulator test - FAILED!", $time);

// Xilinx fifo - actual only with fifo in sync mode
    logic x_fifo_dat_vld = '0;
    t_drd x_fifo_dat_bus = '0;
    logic x_fifo_fll_flg = '0;
    logic x_fifo_a_tfull = '0;
    logic x_fifo_ety_flg = '0;
    logic x_fifo_a_empty = '0;

    logic w_fifo_x_rst_p;
    assign w_fifo_x_rst_p = ( DUAL_CLOCK == "True" ) ? !w_fifo_a_rst_n : !q_fifo_w_rst_n;
    logic x_fifo_p_tfull = '0;
    logic [$clog2(FIFO_DEPTH):0] x_fifo_w_count = '0;
    logic x_fifo_p_empty = '0;
    logic [$clog2(READ_DEPTH):0] x_fifo_r_count = '0;

    // xi_fifo DUC (
    //     // .clk    ( c_fifo_w_clk_p ),
    //     // .srst   ( w_fifo_w_rst_p ),
    //     // .rd_rst_busy (),
    //     // .wr_rst_busy (),
    //     .rst            (!w_fifo_a_rst_n ),
    //     //.wr_rst ( w_fifo_w_rst_p ),
    //     //.rd_rst ( w_fifo_r_rst_p ),
    //     .wr_clk         ( c_fifo_w_clk_p ),        
    //     .rd_clk         ( c_fifo_r_clk_p ),
    //     .din            ( q_fifo_dat_bus ),
    //     .wr_en          ( q_fifo_dat_wen ),
    //     .rd_en          ( q_fifo_dat_ren ),
    //     .dout           ( x_fifo_dat_bus ),
    //     .full           ( x_fifo_fll_flg ),
    //     .almost_full    ( x_fifo_a_tfull ),
    //     .empty          ( x_fifo_ety_flg ),
    //     .almost_empty   ( x_fifo_a_empty ),
    //     .valid          ( x_fifo_dat_vld ),
    //     .rd_data_count  ( x_fifo_r_count ),  // output wire [3 : 0] rd_data_count
    //     .wr_data_count  ( x_fifo_w_count ),  // output wire [3 : 0] wr_data_count
    //     .prog_full      ( x_fifo_p_tfull ),  // output wire prog_full
    //     .prog_empty     ( x_fifo_p_empty )
    // );

    xpm_fifo_sync #(
        // .CDC_SYNC_STAGES(SYNC_STAGES), //
        .DOUT_RESET_VALUE("1"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE(MEM_STYLE),
        .FIFO_READ_LATENCY(READ_LATENCY),
        .FIFO_WRITE_DEPTH(FIFO_DEPTH),
        .FULL_RESET_VALUE(FEATURES[3]),
        .PROG_EMPTY_THRESH(PROG_EMPTY),
        .PROG_FULL_THRESH(PROG_FULL),
        .RD_DATA_COUNT_WIDTH($clog2(FIFO_DEPTH*DW/DR)+1),
        .READ_DATA_WIDTH(DR),
        .READ_MODE(READ_MODE),
        // .RELATED_CLOCKS(0), //
        .USE_ADV_FEATURES("1F0F"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(DW),
        .WR_DATA_COUNT_WIDTH($clog2(FIFO_DEPTH)+1)
   ) xpm_fifo_inst (
        .almost_empty   ( x_fifo_a_empty ),
        .almost_full    ( x_fifo_a_tfull ),
        .data_valid     ( x_fifo_dat_vld ),
        .dbiterr        (),
        .dout           ( x_fifo_dat_bus ),
        .empty          ( x_fifo_ety_flg ),
        .full           ( x_fifo_fll_flg ),
        .overflow       (),
        .prog_empty     ( x_fifo_p_empty ),
        .prog_full      ( x_fifo_p_tfull ),
        .rd_data_count  ( x_fifo_r_count ),
        .rd_rst_busy    (),
        .sbiterr        (),
        .underflow      (),
        .wr_ack         (),
        .wr_data_count  ( x_fifo_w_count ),
        .wr_rst_busy    (),
        .din            ( q_fifo_dat_bus ),
        .injectdbiterr  (),
        .injectsbiterr  (),
        // .rd_clk         ( c_fifo_r_clk_p ), //
        .rd_en          ( q_fifo_dat_ren ),
        .rst            ( w_fifo_x_rst_p ),
        .sleep          ( '0 ),
        .wr_clk         ( c_fifo_w_clk_p ),
        .wr_en          ( q_fifo_dat_wen )
    );

    logic [$clog2(FIFO_DEPTH):0] q_fifo_w_count;
    logic q_fifo_p_tfull;
    logic [$clog2(READ_DEPTH):0] q_fifo_r_count;
    logic q_fifo_p_empty;

    if ( DUAL_CLOCK == "True" ) begin : dual_features

        assign q_fifo_w_count = w_fifo_w_count;
        assign q_fifo_p_tfull = w_fifo_p_tfull;
        assign q_fifo_r_count = w_fifo_r_count;
        assign q_fifo_p_empty = w_fifo_p_empty;
        
    end else begin : sync_features

        always @(posedge c_fifo_w_clk_p) begin
            q_fifo_w_count <= w_fifo_w_count;
            q_fifo_p_tfull <= w_fifo_p_tfull;
        end

        always @(posedge c_fifo_r_clk_p) begin
            q_fifo_r_count <= w_fifo_r_count;
            q_fifo_p_empty <= w_fifo_p_empty;
        end

    end
    
    logic q_fifo_w_rst_p = '0;
    always @(posedge c_fifo_w_clk_p)
        q_fifo_w_rst_p <= UUT.m_fifo_w_rst_p;

    assign w_test_p_tfull = ( q_fifo_w_rst_p ) ? FEATURES[3] : ( w_fifo_w_count >= PROG_FULL ) ? '1 : 0;
    assign w_test_p_empty = ( w_fifo_r_count <= PROG_EMPTY ) ? '1 : 0;

    assign #(0.5*W_CLK_PRD) u_test_w_tfull = ( w_fifo_fll_flg == x_fifo_fll_flg ) ? '1 : '0;
    assign #(0.5*W_CLK_PRD) u_test_a_tfull = ( w_fifo_a_tfull == x_fifo_a_tfull ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_r_empty = ( w_fifo_ety_flg == x_fifo_ety_flg /* && w_fifo_dat_vld == x_fifo_dat_vld */ ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_a_empty = ( w_fifo_a_empty == x_fifo_a_empty /* && w_fifo_dat_vld == x_fifo_dat_vld */ ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_r_value = ( w_fifo_dat_bus == x_fifo_dat_bus ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_r_valid = ( w_fifo_dat_vld == x_fifo_dat_vld ) ? '1 : '0;

    assign #(0.5*R_CLK_PRD) u_test_w_count = ( q_fifo_w_count == x_fifo_w_count ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_p_tfull = ( w_fifo_p_tfull == w_test_p_tfull ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_r_count = ( q_fifo_r_count == x_fifo_r_count ) ? '1 : '0;
    assign #(0.5*R_CLK_PRD) u_test_p_empty = ( w_fifo_p_empty == w_test_p_empty ) ? '1 : '0;
    
    always #(W_CLK_PRD/2.0) c_fifo_w_clk_p = ~c_fifo_w_clk_p;
    always #(R_CLK_PRD/2.0) c_fifo_r_clk_p = ~c_fifo_r_clk_p;

endmodule