module decoder(
    input logic [6:0] addr, 
    input logic en_pcomp,     
    output logic [127:0] r_sel
);
    logic [3:0] pd1_out, pd2_out;
    logic [7:0] pd3_out; 

    2to4_predecoder pd1(
        .in(addr[1:0]),
        .out(pd1_out)
    );

    2to4_predecoder pd2(
        .in(addr[3:2]),
        .out(pd2_out)
    );               

    3to8_predecoder pd3(
        .in(addr[6:4]),
        .out(pd3_out)
    );

    // assign r_sel[0] = ~(~((~(~pd1[0] & ~pd2[0])) & ~pd3[0]));
    generate
        for (genvar i = 0; i < 128; i = i + 1) begin : gen_r_sel
            assign r_sel[i] = en_precomputed ? ~(~((~(~pd1[i % 4] & ~pd2[i / 4 % 4])) & ~pd3[i / 16])): 0;
        end
    endgenerate
endmodule

module predecoder_2to4(
    input logic [1:0] in,   
    output logic [3:0] out  
);

    wire not_in0 = ~in[0];
    wire not_in1 = ~in[1];

    nand ng0(out[0], not_in1, not_in0); //  00
    nand ng1(out[1], not_in1, in[0]);   //  01 
    nand ng2(out[2], in[1], not_in0);   //  10
    nand ng3(out[3], in[1], in[0]);     //  11
endmodule


module predecoder_3to8(
    input logic [2:0] in,
    output logic [7:0] out
);

    wire not_in0 = ~in[0];
    wire not_in1 = ~in[1];
    wire not_in2 = ~in[2];

    nand ng0(out[0], not_in2, not_in1, not_in0); // 000
    nand ng1(out[1], not_in2, not_in1, in[0]);   // 001
    nand ng2(out[2], not_in2, in[1], not_in0);   // 010
    nand ng3(out[3], not_in2, in[1], in[0]);     // 011
    nand ng4(out[4], in[2], not_in1, not_in0);   // 100
    nand ng5(out[5], in[2], not_in1, in[0]);     // 101
    nand ng6(out[6], in[2], in[1], not_in0);     // 110
    nand ng7(out[7], in[2], in[1], in[0]);       // 111
endmodule

