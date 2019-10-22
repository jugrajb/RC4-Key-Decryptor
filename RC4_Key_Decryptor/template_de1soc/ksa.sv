`default_nettype none
module ksa (
    //////////// CLOCK //////////
    CLOCK_50,
    //////////// LED //////////
    LEDR,
    //////////// KEY //////////
    KEY,
    //////////// SW //////////
    SW,
    //////////// SEG7 //////////
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5
);
//=======================================================
//  PORT declarations
//=======================================================
//CLK
input logic CLOCK_50;

//KEY
input logic [3:0] KEY;

//SW
input logic [9:0] SW;

//LED
output logic [9:0] LEDR;

//SEG7
output logic [6:0] HEX0;
output logic [6:0] HEX1;
output logic [6:0] HEX2;
output logic [6:0] HEX3;
output logic [6:0] HEX4;
output logic [6:0] HEX5;

//=======================================================
//Parameters
//=======================================================
parameter CORE_COUNT = 8;
parameter KEY_SPACE = 8388608;

//=======================================================
//  REG/WIRE declarations
//=======================================================
logic clk, reset_n;
logic reset_key_cycle;
logic [3:0] nIn;
logic [6:0] ssOut;

logic [(CORE_COUNT-1): 0] decrpytion_done;
logic [(CORE_COUNT-1): 0] invalid;
logic [(CORE_COUNT-1): 0] core_select;

logic stop = 1'b0;

logic [6:0] hex_ksa_0;
logic [6:0] hex_ksa_1;
logic [6:0] hex_ksa_2;
logic [6:0] hex_ksa_3;
logic [6:0] hex_ksa_4;
logic [6:0] hex_ksa_5;

logic add_scel, sub_csel, reset_csel;
//========================================================
assign clk = CLOCK_50;
assign reset_n = KEY[3];

assign LEDR[0] = stop;
assign LEDR[8:1] = core_select;
assign LEDR[9] = (invalid == 8'b1111_1111);

edge_detector sync_reset_key (
    .async_sig(~reset_n),
    .outclk(clk),
    .out_sync_sig(reset_key_cycle),
    .vcc(1'b1),
    .reset(1'b0)
);

always_ff @(posedge clk) begin
    if(decrpytion_done) stop <= 1'b1;
    else if(invalid == 8'b1111_1111) stop <= 1'b1;
    else if(reset_key_cycle) stop <= 1'b0;
    else stop <= stop;
end

always_ff @(posedge clk) begin
    if(decrpytion_done) core_select <= decrpytion_done;
    else core_select <= SW[CORE_COUNT-2:0];
end

mux_8_to_1 #(8) m1 (
    .in1(decryp_core[0].hex_data_0),
    .in2(decryp_core[1].hex_data_0),
    .in3(decryp_core[2].hex_data_0),
    .in4(decryp_core[3].hex_data_0),
    .in5(decryp_core[4].hex_data_0),
    .in6(decryp_core[5].hex_data_0),
    .in7(decryp_core[6].hex_data_0),
    .in8(decryp_core[7].hex_data_0),
    .select(core_select),
    .out1(hex_ksa_0)
);

mux_8_to_1 #(8) m2 (
    .in1(decryp_core[0].hex_data_1),
    .in2(decryp_core[1].hex_data_1),
    .in3(decryp_core[2].hex_data_1),
    .in4(decryp_core[3].hex_data_1),
    .in5(decryp_core[4].hex_data_1),
    .in6(decryp_core[5].hex_data_1),
    .in7(decryp_core[6].hex_data_1),
    .in8(decryp_core[7].hex_data_1),
    .select(core_select),
    .out1(hex_ksa_1)
);

mux_8_to_1 #(8) m3 (
    .in1(decryp_core[0].hex_data_2),
    .in2(decryp_core[1].hex_data_2),
    .in3(decryp_core[2].hex_data_2),
    .in4(decryp_core[3].hex_data_2),
    .in5(decryp_core[4].hex_data_2),
    .in6(decryp_core[5].hex_data_2),
    .in7(decryp_core[6].hex_data_2),
    .in8(decryp_core[7].hex_data_2),
    .select(core_select),
    .out1(hex_ksa_2)
);

mux_8_to_1 #(8) m4 (
    .in1(decryp_core[0].hex_data_3),
    .in2(decryp_core[1].hex_data_3),
    .in3(decryp_core[2].hex_data_3),
    .in4(decryp_core[3].hex_data_3),
    .in5(decryp_core[4].hex_data_3),
    .in6(decryp_core[5].hex_data_3),
    .in7(decryp_core[6].hex_data_3),
    .in8(decryp_core[7].hex_data_3),
    .select(core_select),
    .out1(hex_ksa_3)
);

mux_8_to_1 #(8) m5 (
    .in1(decryp_core[0].hex_data_4),
    .in2(decryp_core[1].hex_data_4),
    .in3(decryp_core[2].hex_data_4),
    .in4(decryp_core[3].hex_data_4),
    .in5(decryp_core[4].hex_data_4),
    .in6(decryp_core[5].hex_data_4),
    .in7(decryp_core[6].hex_data_4),
    .in8(decryp_core[7].hex_data_4),
    .select(core_select),
    .out1(hex_ksa_4)
);

mux_8_to_1 #(8) m6 (
    .in1(decryp_core[0].hex_data_5),
    .in2(decryp_core[1].hex_data_5),
    .in3(decryp_core[2].hex_data_5),
    .in4(decryp_core[3].hex_data_5),
    .in5(decryp_core[4].hex_data_5),
    .in6(decryp_core[5].hex_data_5),
    .in7(decryp_core[6].hex_data_5),
    .in8(decryp_core[7].hex_data_5),
    .select(core_select),
    .out1(hex_ksa_5)
);

assign HEX0 = hex_ksa_0;
assign HEX1 = hex_ksa_1;
assign HEX2 = hex_ksa_2;
assign HEX3 = hex_ksa_3;
assign HEX4 = hex_ksa_4;
assign HEX5 = hex_ksa_5;

genvar i;
generate
	for(i=0; i<CORE_COUNT; i=i+1) begin : decryp_core

        logic [6:0] hex_data_0;
        logic [6:0] hex_data_1;
        logic [6:0] hex_data_2;
        logic [6:0] hex_data_3;
        logic [6:0] hex_data_4;
        logic [6:0] hex_data_5;

		decryption_core #(
            .start_key((KEY_SPACE/CORE_COUNT)*i),
            .max_key((KEY_SPACE/CORE_COUNT)*(i+1)+50)
        ) dc1 (
            .clk(clk), 
            .reset(reset_n), 
            .invalid(invalid[i]),
            .done(decrpytion_done[i]),
            .stop(stop),
            .hex_0_data_out(hex_data_0),
            .hex_1_data_out(hex_data_1),
            .hex_2_data_out(hex_data_2),
            .hex_3_data_out(hex_data_3),
            .hex_4_data_out(hex_data_4),
            .hex_5_data_out(hex_data_5),
            .reset_key_cycle(reset_key_cycle)
        );
	end
endgenerate


endmodule

