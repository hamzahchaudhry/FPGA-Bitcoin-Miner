`define BLOCK_HEADER_LENGTH 10'b1010000000
`define INITIAL             3'b000
`define PROCESS_BLOCK1      3'b001
`define wait                3'b010
`define PROCESS_BLOCK2      3'b100
`define DONE                3'b111

module sha256(clk, reset, blockHeader, digest);
    input clk, reset;
    input [639:0] blockHeader;
    output [255:0] digest;

    // hash values h_out
    reg [31:0] hash [0:7];




    // split block header into 2 512-bit blocks
    wire [511:0] Block1 = blockHeader[511:0];
    // append second block with last 128 bits of block header, 1, 319 0s, and 64 bits of block header length (640)
    wire [511:0] Block2 = {blockHeader[639:512], 1'b1, 319'b0, 54'b0, `BLOCK_HEADER_LENGTH};

    // assign output value
    reg [255:0] final_digest;
    assign digest = final_digest;

    // compression function outputs
    reg [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out;

    // states
    reg [2:0] present_state;

    reg s;
    reg [1:0] bs;

    compression_func cf(
        .clk(clk),
        .s(s),
        .block1(Block1),
        .block2(Block2),
        .bs(bs),
        .k(k),
        .a_in(hash[0]),
        .b_in(hash[1]),
        .c_in(hash[2]),
        .d_in(hash[3]),
        .e_in(hash[4]),
        .f_in(hash[5]),
        .g_in(hash[6]),
        .h_in(hash[7]),
        .a_out(a_out),
        .b_out(b_out),
        .c_out(c_out),
        .d_out(d_out),
        .e_out(e_out),
        .f_out(f_out),
        .g_out(g_out),
        .h_out(h_out)
    );
                    
    always_ff @(posedge clk) begin
        if (reset) begin
            // Initialize hash values
            hash[0] <= 32'h6a09e667;
            hash[1] <= 32'hbb67ae85;
            hash[2] <= 32'h3c6ef372;
            hash[3] <= 32'ha54ff53a;
            hash[4] <= 32'h510e527f;
            hash[5] <= 32'h9b05688c;
            hash[6] <= 32'h1f83d9ab;
            hash[7] <= 32'h5be0cd19;
            s = 0;
            bs = 2'b00;
            final_digest <= 256'b0;
            present_state <= `INITIAL;
        end else begin
            case (present_state)
                `PROCESS_BLOCK1: begin
                    s = 1;
                    bs = 2'b01;
                    hash[0] <= hash[0] + a_out;
                    hash[1] <= hash[1] + b_out;
                    hash[2] <= hash[2] + c_out;
                    hash[3] <= hash[3] + d_out;
                    hash[4] <= hash[4] + e_out;
                    hash[5] <= hash[5] + f_out;
                    hash[6] <= hash[6] + g_out;
                    hash[7] <= hash[7] + h_out;
                    present_state <= `PROCESS_BLOCK2;
                end
                `wait: begin
                    s = 0;
                    bs = 2'b00;
                    present_state <= `PROCESS_BLOCK2;
                end
                `PROCESS_BLOCK2: begin
                    s = 1;
                    bs = 2'b01;
                    hash[0] <= hash[0] + a_out;
                    hash[1] <= hash[1] + b_out;
                    hash[2] <= hash[2] + c_out;
                    hash[3] <= hash[3] + d_out;
                    hash[4] <= hash[4] + e_out;
                    hash[5] <= hash[5] + f_out;
                    hash[6] <= hash[6] + g_out;
                    hash[7] <= hash[7] + h_out;
                    final_digest <= {hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7]};
                    present_state <= `DONE;
                end
                `DONE: present_state <= `DONE;
                default: present_state <= `INITIAL;
            endcase
        end
    end
endmodule