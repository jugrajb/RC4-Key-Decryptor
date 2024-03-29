module decrypt_msg (
    clk, reset, start, 
    dm_done, dm_invalid,
    dm_w_address, dm_w_data, dm_w_wren, dm_w_q,
    dm_en_r_address, dm_en_r_q,
    dm_dc_address, dm_dc_data, dm_dc_wren
);
    input logic clk, reset, start;
    input logic [7:0] dm_w_q, dm_en_r_q;

    output logic dm_done, dm_invalid, dm_w_wren, dm_dc_wren;
    output logic [7:0] dm_w_address, dm_w_data, dm_en_r_address, dm_dc_address, dm_dc_data;

    logic [4:0] k = 5'b0;
    logic [7:0] i, j = 8'b0;

    //States
    parameter [8:0] IDLE        = 9'b0000_00001;
    parameter [8:0] INC_I       = 9'b0000_00010;
    parameter [8:0] LOAD_I      = 9'b0000_00011;
    parameter [8:0] READ_I      = 9'b0000_00100;
    parameter [8:0] SAVE_I      = 9'b0000_00101;
    parameter [8:0] CALC_J      = 9'b0000_00110;
    parameter [8:0] LOAD_J      = 9'b0000_00111;
    parameter [8:0] READ_J      = 9'b0000_01000;
    parameter [8:0] SAVE_J      = 9'b0000_01001;
    parameter [8:0] WRITE_I     = 9'b0010_01010;
    parameter [8:0] WRITE_J     = 9'b0010_01011;
    parameter [8:0] CALC_F_IND  = 9'b0000_01110;
    parameter [8:0] LOAD_F_IND  = 9'b0000_01111;
    parameter [8:0] READ_F_IND  = 9'b0000_10000;
    parameter [8:0] LOAD_ENC    = 9'b0000_10001;
    parameter [8:0] READ_ENC    = 9'b0000_10010;
    parameter [8:0] CHK_DC_DATA = 9'b0000_10011;
    parameter [8:0] WRITE_DC    = 9'b0001_10100;
    parameter [8:0] CHK_DONE    = 9'b0000_10101;
    parameter [8:0] INC_K       = 9'b0000_10110;
    parameter [8:0] DONE        = 9'b0100_10111;
    parameter [8:0] INVALID_D   = 9'b1000_11000;
    parameter [8:0] XOR_F_EN    = 9'b0000_11001;

    logic [8:0] state = IDLE;

    logic [7:0] mem_data_i;
    logic [7:0] mem_data_j;
    logic [7:0] xor_data;
    

    always_ff @(posedge clk, posedge reset) begin
        if(reset) state <= IDLE;
        else begin
            case(state)
                IDLE:       begin
                                if(start) state <= INC_I;
                                else state <= IDLE;
                            end
                INC_I:      state <= LOAD_I;
                LOAD_I:     state <= READ_I;
                READ_I:     state <= SAVE_I;
                SAVE_I:     state <= CALC_J;
                CALC_J:     state <= LOAD_J;
                LOAD_J:     state <= READ_J;
                READ_J:     state <= SAVE_J;
                SAVE_J:     state <= WRITE_I;
                WRITE_I:    state <= WRITE_J;
                WRITE_J:    state <= LOAD_F_IND;
                LOAD_F_IND: state <= READ_F_IND;
                READ_F_IND: state <= LOAD_ENC;
                LOAD_ENC:   state <= READ_ENC;
                READ_ENC:   state <= XOR_F_EN;
                XOR_F_EN:   state <= CHK_DC_DATA;
                CHK_DC_DATA:begin
                                if((xor_data < 8'h61 & xor_data != 8'h20) | xor_data > 8'h7A ) 
                                    state <= INVALID_D;
                                else state <= WRITE_DC;
                            end
                WRITE_DC:   state <= CHK_DONE;
                CHK_DONE:   begin
                                if(k == 8'h1F) state <= DONE;
                                else state <= INC_K;
                            end
                INC_K:      state <= INC_I;
                DONE:       state <= DONE;
                INVALID_D:  state <= INVALID_D;
                default:    state <= IDLE;
            endcase
        end
    end

    assign dm_done = state[7];
    assign dm_invalid = state[8];

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            k <= 5'b0;
            i <= 8'b0;
            j <= 8'b0;
        end else begin
            case(state)
                INC_I:      i <= i + 1'b1;
                LOAD_I:     dm_w_address <= i;
                SAVE_I:     mem_data_i <= dm_w_q;
                CALC_J:     j <= j + mem_data_i;
                LOAD_J:     dm_w_address <= j;
                SAVE_J:     mem_data_j <= dm_w_q;
                WRITE_I:    begin
                                dm_w_address <= j;
                                dm_w_data <= mem_data_i;
                            end
                WRITE_J:    begin
                                dm_w_address <= i;
                                dm_w_data <= mem_data_j;
                            end
                LOAD_F_IND: dm_w_address <= (mem_data_i + mem_data_j);
                LOAD_ENC:   dm_en_r_address <= k;
                XOR_F_EN:   xor_data <= (dm_w_q ^ dm_en_r_q);
                WRITE_DC:   begin
                                dm_dc_address <= k;
                                dm_dc_data <= xor_data;
                            end
                INC_K:      k <= k + 1'b1;
                default:    begin
                                dm_w_address <= dm_w_address;
                                dm_dc_address <= dm_dc_address;
                                dm_en_r_address <= dm_en_r_address;
                            end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        dm_w_wren <= state[6];
        dm_dc_wren <= state[5];
    end

endmodule