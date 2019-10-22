module decryption_core #(
    parameter [23:0] start_key = 24'b0,
    parameter [23:0] max_key = 24'h7FFFFF
) (
    input logic clk, reset, stop, reset_key_cycle,
    output logic done, invalid,
    output logic [6:0] hex_0_data_out, hex_1_data_out, hex_2_data_out, hex_3_data_out, hex_4_data_out, hex_5_data_out
);
    //flags
    logic load_done;
    logic shuffle_done;
    logic decryption_done;
    logic decryption_invalid;

    //load mem
    logic [7:0] l_address, l_data;
    logic l_wren;

    //shuffle mem
    logic [7:0] s_address, s_data;
    logic s_wren;

    //decrypt msg
    logic [7:0] dm_address, dm_data;
    logic dm_wren;

    //rc4 crack
    logic [23:0] sc_key;
    logic reset_d;
    logic start_decrypt;

    //working mem
    logic [7:0] w_address, w_data, w_q;
    logic w_wren;

    //encrypted rom
    logic [7:0] rom_address, rom_q;

    //decrypted ram
    logic [7:0] dc_address, dc_data, dc_q;
    logic dc_wren;

    assign done = decryption_done;
    
    load_mem l_mem(
        .clk(clk), 
        .reset(reset_d),
        .start(start_decrypt),
        .l_done(load_done), 
        .l_address(l_address), 
        .l_wren(l_wren),
        .l_data(l_data)
    );

    shuffle_mem s_mem(
        .clk(clk),
        .reset(reset_d),
        .start(load_done),
        .secret_key(sc_key),
        .s_done(shuffle_done),
        .s_q(w_q),
        .s_address(s_address),
        .s_data(s_data),
        .s_wren(s_wren)
    );

    decrypt_msg dc_msg(
        .clk(clk),
        .reset(reset_d),
        .start(shuffle_done),
        .dm_done(decryption_done),
        .dm_invalid(decryption_invalid),
        .dm_w_address(dm_address),
        .dm_w_data(dm_data),
        .dm_w_wren(dm_wren),
        .dm_w_q(w_q),
        .dm_en_r_address(rom_address),
        .dm_en_r_q(rom_q),
        .dm_dc_address(dc_address),
        .dm_dc_data(dc_data),
        .dm_dc_wren(dc_wren)
    );

    rc4_key_cycle
    #(
        .counter_start(start_key),
        .counter_end(max_key) 
    ) rc4(
        .clk(clk),
        .reset(reset_key_cycle),
        .start(1'b1),
        .enable(stop),
        .dc_done(decryption_done),
        .dc_invalid(decryption_invalid),
        .sc_key(sc_key),
        .start_decrypt(start_decrypt),
        .reset_decrypt(reset_d),
        .no_sol(invalid)
    );

    select_working_mem_input sgmi(
        .clk(clk),
        .load_done(load_done),
        .shuffle_done(shuffle_done),
        .l_address(l_address),
        .l_data(l_data),
        .l_wren(l_wren),
        .s_address(s_address),
        .s_data(s_data),
        .s_wren(s_wren),
        .dm_address(dm_address),
        .dm_data(dm_data),
        .dm_wren(dm_wren),
        .out_address(w_address),
        .out_data(w_data),
        .out_wren(w_wren)
    );

    s_memory mem(
        .address(w_address), 
        .clock(clk),
        .data(w_data),
        .wren(w_wren),
        .q(w_q)
    );

    encrypted_rom en_rom(
        .address(rom_address),
        .clock(clk),
        .data(8'b0),
        .wren(1'b0),
        .q(rom_q)
    );

    decrpted_ram dc_ram(
        .address(dc_address),
        .clock(clk),
        .data(dc_data),
        .wren(dc_wren),
        .q(dc_q)
    );

    SevenSegmentDisplayDecoder hexDisplay0(.ssOut(hex_0_data_out), .nIn(sc_key[3:0]));
    SevenSegmentDisplayDecoder hexDisplay1(.ssOut(hex_1_data_out), .nIn(sc_key[7:4]));
    SevenSegmentDisplayDecoder hexDisplay2(.ssOut(hex_2_data_out), .nIn(sc_key[11:8]));
    SevenSegmentDisplayDecoder hexDisplay3(.ssOut(hex_3_data_out), .nIn(sc_key[15:12]));
    SevenSegmentDisplayDecoder hexDisplay4(.ssOut(hex_4_data_out), .nIn(sc_key[19:16]));
    SevenSegmentDisplayDecoder hexDisplay5(.ssOut(hex_5_data_out), .nIn(sc_key[23:20]));


endmodule