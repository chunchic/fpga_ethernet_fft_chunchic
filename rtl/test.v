module test (
input a, b,
output reg c

);

always_ff @(posedge clk) begin
    c <= a + b;
end

endmodule;