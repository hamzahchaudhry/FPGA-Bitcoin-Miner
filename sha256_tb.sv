module sha256_tb();
    reg clk, reset;
    reg [639:0] blockHeader;
    wire [255:0] digest;

    reg err;
    reg [255:0] expected_digest;

    sha256 DUT(clk, reset, blockHeader, digest);

    initial begin
        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end
    end

    initial begin
        reset = 1;
        #10;
        reset = 0;
        
        blockHeader = {
            32'h01000000, // Version
            256'h0000000000000000000000000000000000000000000000000000000000000000, // Previous Hash
            256'h3ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a, // Merkle Root
            32'h29ab5f49, // Timestamp
            32'hfffffff,  // Difficulty
            32'h1dac2b7c   // Nonce
        };
        expected_digest = 256'h000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f;
        #50;

        if (DUT.digest !== expected_digest) begin err = 1; $display("FAILED"); $stop; end

    end

endmodule;