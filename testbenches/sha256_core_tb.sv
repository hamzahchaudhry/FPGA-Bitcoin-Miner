module sha256_core_tb();
    reg clk, reset;
    reg [639:0] blockHeader;
    wire [31:0] a, b, c, d, e, f, g, h;
    wire [255:0] digest;

    reg [255:0] expected_first_hash;
    reg [255:0] expected_digest;
    reg err;

    sha256_core DUT(
        .clk(clk),
        .reset(reset),
        .blockHeader(blockHeader),
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

    initial begin
        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end
    end

    initial begin
        err = 0; reset = 1;
        #10;
        reset = 0;
        blockHeader         = 640'h0100000081cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000e320b6c2fffc8d750423db8b1eb942ae710e951ed797f7affc8892b0f1fc122bc7f5d74df2b9441a42a14695;
        expected_first_hash = 256'hb9d751533593ac10cdfb7b8e03cad8babc67d8eaeac0a3699b82857dacac9390;
        expected_digest     = 256'h1dbd981fe6985776b644b173a4d0385ddc1aa2a829688d1e0000000000000000;

        #1500;
        if (DUT.first_hash !== expected_first_hash) begin
            err = 1;
            $display("FAILED: First hash incorrect!");
        end else begin
            $display("PASSED: First hash matches!");
        end

        #500;

        if (DUT.digest !== expected_digest) begin
            err = 1;
            $display("FAILED: Second hash (digest) incorrect!");
        end else begin
            $display("PASSED: Second hash (digest) matches!");
        end
        $stop;
    end
endmodule