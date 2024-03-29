module load_mem_tb();
    reg clk, reset, start, err;

    wire l_done, l_wren;
    wire [7:0] l_data, l_address;

    load_mem dut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .l_address(l_address),
        .l_wren(l_wren),
        .l_data(l_data),
        .l_done(l_done)
    );

    //test states
    parameter [4:0] IDLE        = 5'b00_000;
    parameter [4:0] BEGIN_LOAD  = 5'b00_001;
    parameter [4:0] INC_COUNT   = 5'b00_010;
    parameter [4:0] LOAD_DATA   = 5'b01_011;
    parameter [4:0] WRITE_DATA  = 5'b01_100;
    parameter [4:0] CHECK_DONE  = 5'b00_101;
    parameter [4:0] LOAD_DONE   = 5'b10_110;

    task checkState;
        input [4:0] expected_state;

        begin
            if(load_mem_tb.dut.state !== expected_state) begin
                $display("Error ** state is %b, expected %b",
                load_mem_tb.dut.state, expected_state );
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

        
        $display("Checking initial"); #2
        checkState(IDLE);

        
        $display("clk cycle 1"); #4
        checkState(BEGIN_LOAD);

        
        $display("clk cycle 2"); #4
        checkState(LOAD_DATA);

       
        $display("clk cycle 3"); #4
        checkState(WRITE_DATA);

        
        $display("clk cycle 4"); #4
        checkState(CHECK_DONE);

        
        $display("clk cycle 5"); #4
        
        
        $display("clk cycle 6"); #2
        
        reset = 1'b1; #2;

         
        $display("clk cycle 7"); #4
        checkState(IDLE);   

        if(~err) $display("All tests passed");
        $stop;
    end
endmodule


    
