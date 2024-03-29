module rc4_tb();
    reg clk, reset, start, enable, dc_done, dc_invalid, err;
    
    wire [23:0] sc_key;

    wire reset_decrypt, start_decrypt, no_sol;

    rc4_key_cycle dut(
        clk, reset, start, enable, dc_done, dc_invalid, sc_key, reset_decrypt,
        start_decrypt, no_sol
    );

        //States
    parameter [6:0] IDLE            = 7'b000_0000;
    parameter [6:0] RESET_MANUAL    = 7'b001_0001;
    parameter [6:0] WAIT_DECRYPT    = 7'b010_0010;
    parameter [6:0] KEY_INC         = 7'b000_0011;
    parameter [6:0] RESET_DECRPYT   = 7'b001_0100;
    parameter [6:0] DONE            = 7'b000_0101;
    parameter [6:0] CHK_KEY         = 7'b000_0111;
    parameter [6:0] NO_SOL          = 7'b100_1000;

    task checkState;
        input [6:0] expected_state;

        begin
            if(rc4_tb.dut.state !== expected_state) begin
                $display("Error ** state is %b, expected %b",
                rc4_tb.dut.state, expected_state );
            err = 1'b1;
            end
        end
    endtask

           initial begin 
        clk = 0; #2;
        forever begin
        clk = 1; #2;
        clk = 0; #2;
        end
    end

    initial begin
        err = 1'b0; reset = 1'b0; start = 1'b1;

        checkState(IDLE); #4;

        dc_invalid = 1'b1;
         $display("Checking State"); 
         checkState(WAIT_DECRYPT); #4;
         $display("Checking State"); 
         checkState(KEY_INC); #4;
         $display("Checking State"); 
         checkState(RESET_DECRPYT); #4;
         $display("Checking State"); 
         dc_done = 1'b1; dc_invalid = 1'b0;
         checkState(WAIT_DECRYPT); #4;
         $display("Checking State"); 
         checkState(DONE); #4


        if(~err) $display("All tests passed");
        $stop;
    end
endmodule