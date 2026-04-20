module accumulator (
    input              clk,
    input              rst_n,
    input              enable,
    input              clear,

    input      [31:0]  data_in,
    input              valid_in,

    output reg [31:0]  sum
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum <= 32'd0;
    end
    else if (clear) begin
        sum <= 32'd0;
    end
    else begin
        if (enable && valid_in)
            sum <= sum + data_in;
    end
end

endmodule