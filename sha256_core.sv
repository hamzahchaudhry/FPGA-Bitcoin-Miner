typedef enum logic [2:0] {
    INITIAL        = 3'b000,
    PROCESS_BLOCK_1 = 3'b001,
    PROCESS_BLOCK_2 = 3'b011,
    SCHEDULE_ARRAY = 3'b100,
    MAIN_LOOP      = 3'b101,
    CHUNK_CHOOSE    = 3'B111,
    DONE           = 3'b110
} state_t;

module sha256_core (
        input clk, reset,
        input [639:0] blockHeader,
        output reg [31:0] a, b, c, d, e, f, g, h,
        output reg [255:0] digest
    );

    reg [1023:0] padded_block;
    reg chunk;
    reg step;
    reg [255:0] first_hash;

    reg [31:0] hash [0:7];    // hash values
    reg [31:0] k [0:63];      // round constants k    
    initial $readmemh("sha256_core_k.hex", k);

    reg [31:0] w [63:0];                                  // message schedule array
    reg [31:0] s0, s1, S0, S1, ch, maj, temp1, temp2;     // intermediate regs
    integer j;                                            // loop index for reset logic
    integer i;                                            // loop index for other operations
    state_t present_state;                                // FSM states

    // FSM
    always_ff @(posedge clk) begin
        if (reset) begin
            // initialize hash values
            $readmemh("sha256_core_hash.hex", hash);
            chunk <= 0;
            step <= 0;
            // reset message schedule array
            for (j = 0; j < 64; j++) begin
                w[j] <= 32'd0;
            end

            // set initial state
            present_state <= INITIAL;
        end else begin
            case (present_state)
                INITIAL: begin
                    if (!step) begin
                        padded_block = {blockHeader, 1'b1, 319'b0, 64'd640};
                    end else begin
                        padded_block = {first_hash, 1'b1, 191'b0, 64'd256};
                    end
                    a <= hash[0];
                    b <= hash[1];
                    c <= hash[2];
                    d <= hash[3];
                    e <= hash[4];
                    f <= hash[5];
                    g <= hash[6];
                    h <= hash[7];
                    
                    if (!step) present_state <= chunk ? PROCESS_BLOCK_2 : PROCESS_BLOCK_1;
                    else present_state <= PROCESS_BLOCK_2;
                end
                PROCESS_BLOCK_1: begin
                    for (i = 0; i < 16; i++) begin
                        w[i] <= padded_block[1023 - (i * 32) -: 32];
                    end
                    present_state <= SCHEDULE_ARRAY;
                end
                PROCESS_BLOCK_2: begin
                    for (i = 0; i < 16; i++) begin
                        w[i] <= padded_block[511 - (i * 32) -: 32];
                    end
                    present_state <= SCHEDULE_ARRAY;
                end
                SCHEDULE_ARRAY: begin
                    i <= 16;
                    if (i < 64) begin
                        // Compute s0 and s1 for the current i
                        s0 = (w[i-15] >> 7 | w[i-15] << 25) ^ 
                                (w[i-15] >> 18 | w[i-15] << 14) ^ 
                                (w[i-15] >> 3);

                        s1 = (w[i-2] >> 17 | w[i-2] << 15) ^ 
                                (w[i-2] >> 19 | w[i-2] << 13) ^ 
                                (w[i-2] >> 10);

                        // Update w[i]
                        w[i] <= w[i-16] + s0 + w[i-7] + s1;

                        // Increment i for the next clock cycle
                        i <= i + 1;
                    end else begin
                        // Move to the next state after completing all 64 words
                        present_state <= MAIN_LOOP;
                    end
                end
                MAIN_LOOP: begin
                    // Compression function main loop:
                    for (i = 0; i < 64; i++) begin
                        S1 = ({e[5:0], e[31:6]}) ^ 
                                ({e[10:0], e[31:11]}) ^ 
                                ({e[24:0], e[31:25]});
                        ch = (e & f) ^ (~e & g);
                        temp1 = h + S1 + ch + k[i] + w[i];
                        S0 = ({a[1:0], a[31:2]}) ^ 
                                ({a[12:0], a[31:13]}) ^ 
                                ({a[21:0], a[31:22]});
                        maj = (a & b) ^ (a & c) ^ (b & c);
                        temp2 = S0 + maj;

                        h = g;
                        g = f;
                        f = e;
                        e = d + temp1;
                        d = c;
                        c = b;
                        b = a;
                        a = temp1 + temp2;
                    end
                    hash[0] <= hash[0] + a;
                    hash[1] <= hash[1] + b;
                    hash[2] <= hash[2] + c;
                    hash[3] <= hash[3] + d;
                    hash[4] <= hash[4] + e;
                    hash[5] <= hash[5] + f;
                    hash[6] <= hash[6] + g;
                    hash[7] <= hash[7] + h;

                    present_state <= CHUNK_CHOOSE;
                end
                CHUNK_CHOOSE: begin
                    if (!chunk) begin
                        chunk <= 1;  // Move to the next chunk
                    end else if (!step) begin
                        first_hash <= {hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7]};
                        step <= 1;  // Move to the second step
                        $readmemh("sha256_core_hash.hex", hash);
                    end
                    present_state <= step ? DONE : INITIAL;
                end
                DONE: begin
                    digest = {hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7]};
                    present_state <= reset ? INITIAL : DONE;
                end
                default: present_state <= INITIAL;
            endcase
        end
    end
endmodule
