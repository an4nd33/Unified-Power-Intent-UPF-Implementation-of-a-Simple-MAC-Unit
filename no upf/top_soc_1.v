module top_soc (

    input              clk,
    input              rst_n,

    input              mul_en,
    input              acc_en,
    input              acc_clear,

    input      [15:0]  a,
    input      [15:0]  b,

    output     [31:0]  result
);

    wire [31:0] product;
    wire        valid;

    multiplier u_mul (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (mul_en),
        .a       (a),
        .b       (b),
        .product (product),
        .valid   (valid)
    );

    accumulator u_acc (
        .clk      (clk),
        .rst_n    (rst_n),
        .enable   (acc_en),
        .clear    (acc_clear),
        .data_in  (product),
        .valid_in (valid),
        .sum      (result)
    );

endmodule