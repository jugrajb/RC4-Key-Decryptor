module edge_detector (async_sig, outclk, out_sync_sig, vcc, reset);

    input logic async_sig, outclk, vcc, reset;

    output logic out_sync_sig;

    logic A_out, B_out, C_out, D_out;

    always_ff@(posedge async_sig or posedge D_out)     
    begin 
        if(D_out) A_out <= 1'b0;
        else A_out <= vcc;
    end

    always_ff@(posedge outclk or posedge reset)
    begin 
        if(reset) B_out <= 1'b0;
        else B_out <= A_out;
    end

    always_ff@(posedge outclk or posedge reset)
        begin 
        if(reset) C_out <= 1'b0;
        else C_out <= B_out;
    end

    always_ff@(negedge outclk or posedge reset)
        begin 
        if(reset) D_out <= 1'b0;
        else D_out <= C_out;
    end

    assign out_sync_sig = C_out;    //synced async_sig with outclk
endmodule