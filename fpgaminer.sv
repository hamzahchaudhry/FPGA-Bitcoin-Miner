module fpgaminer(
    input clk, reset,
    input [639:0] blockHeader,
    output [255:0] digest
    );

    reg s;
    reg [1:0] bs;

    sha256 sha256(
        .clk(clk),
        .reset(reset),
        .s(s),
        .block1(block1),
        .block2(block2),
        .bs(bs),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .digest(digest)
    );

endmodule