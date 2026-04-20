module multiplier (
    input              clk,
    input              rst_n,
    input              enable,

    input      [15:0]  a,
    input      [15:0]  b,

    output reg [31:0]  product,
    output reg         valid
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        product <= 32'd0;
        valid   <= 1'b0;
    end
    else begin
        product <= a * b;          // always computed
        valid   <= enable;         // only qualify output
    end
end

endmodule