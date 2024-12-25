module compression_func_tb();
    reg clk, reset, s;
    reg [511:0] block1, block2;
    reg [1:0] bs;
    reg [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in;
    wire [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out;

    wire [255:0] abcdefgh_out;
    reg err;
    assign abcdefgh_out = {a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out};
    reg [255:0] expected_abcdefgh_out;

    // Instantiate the compression function
    compression_func DUT(
        .clk(clk),
        .reset(reset),
        .s(s),
        .block1(block1),
        .block2(block2),
        .bs(bs),
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .d_in(d_in),
        .e_in(e_in),
        .f_in(f_in),
        .g_in(g_in),
        .h_in(h_in),
        .a_out(a_out),
        .b_out(b_out),
        .c_out(c_out),
        .d_out(d_out),
        .e_out(e_out),
        .f_out(f_out),
        .g_out(g_out),
        .h_out(h_out)
    );

    // Clock generation
    initial begin
        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end
    end

    // Test logic
    initial begin

        a_in = 32'h6a09e667;
        b_in = 32'hbb67ae85;
        c_in = 32'h3c6ef372;
        d_in = 32'ha54ff53a;
        e_in = 32'h510e527f;
        f_in = 32'h9b05688c;
        g_in = 32'h1f83d9ab;
        h_in = 32'h5be0cd19;
        expected_abcdefgh_out = 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;

        // Apply reset
        reset = 1;
        s = 0;
        bs = 0;
        #10;

        // Deassert reset and start
        reset = 0;
        s = 1;

        // Load the block
        block1 = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
        block2 = 512'b0;
        bs = 2'b01; // Indicating block1 is active
        #600;  // Wait for computation

        // Deassert start signal
        s = 0;

        // Check output
        if (DUT.digest !== expected_abcdefgh_out) begin
            err = 1; 
            $display("FAILED: Output mismatch!");
            $stop;
        end else begin
            $display("PASSED: Output matches!");
        end
    end
endmodule
