typedef enum logic [1:0] {
    INITIAL        = 2'b00,
    SCHEDULE_ARRAY = 2'b01,
    MAIN_LOOP      = 2'b10,
    DONE           = 2'b11
} state_t;

module compression_func(
    input clk, reset, s,
    input [511:0] block1, block2,
    input [1:0] bs,
    input [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    output reg [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out,
    output reg [255:0] digest
    );

    reg [31:0] hash [0:7];                                                                          // hash values
    reg [31:0] k [0:63];                                                                            // round constants k
    initial begin
        k[0] = 32'h428a2f98; k[1] = 32'h71374491; k[2] = 32'hb5c0fbcf; k[3] = 32'he9b5dba5;
        k[4] = 32'h3956c25b; k[5] = 32'h59f111f1; k[6] = 32'h923f82a4; k[7] = 32'hab1c5ed5;
        k[8] = 32'hd807aa98; k[9] = 32'h12835b01; k[10] = 32'h243185be; k[11] = 32'h550c7dc3;
        k[12] = 32'h72be5d74; k[13] = 32'h80deb1fe; k[14] = 32'h9bdc06a7; k[15] = 32'hc19bf174;
        k[16] = 32'he49b69c1; k[17] = 32'hefbe4786; k[18] = 32'h0fc19dc6; k[19] = 32'h240ca1cc;
        k[20] = 32'h2de92c6f; k[21] = 32'h4a7484aa; k[22] = 32'h5cb0a9dc; k[23] = 32'h76f988da;
        k[24] = 32'h983e5152; k[25] = 32'ha831c66d; k[26] = 32'hb00327c8; k[27] = 32'hbf597fc7;
        k[28] = 32'hc6e00bf3; k[29] = 32'hd5a79147; k[30] = 32'h06ca6351; k[31] = 32'h14292967;
        k[32] = 32'h27b70a85; k[33] = 32'h2e1b2138; k[34] = 32'h4d2c6dfc; k[35] = 32'h53380d13;
        k[36] = 32'h650a7354; k[37] = 32'h766a0abb; k[38] = 32'h81c2c92e; k[39] = 32'h92722c85;
        k[40] = 32'ha2bfe8a1; k[41] = 32'ha81a664b; k[42] = 32'hc24b8b70; k[43] = 32'hc76c51a3;
        k[44] = 32'hd192e819; k[45] = 32'hd6990624; k[46] = 32'hf40e3585; k[47] = 32'h106aa070;
        k[48] = 32'h19a4c116; k[49] = 32'h1e376c08; k[50] = 32'h2748774c; k[51] = 32'h34b0bcb5;
        k[52] = 32'h391c0cb3; k[53] = 32'h4ed8aa4a; k[54] = 32'h5b9cca4f; k[55] = 32'h682e6ff3;
        k[56] = 32'h748f82ee; k[57] = 32'h78a5636f; k[58] = 32'h84c87814; k[59] = 32'h8cc70208;
        k[60] = 32'h90befffa; k[61] = 32'ha4506ceb; k[62] = 32'hbef9a3f7; k[63] = 32'hc67178f2;
    end

    reg [31:0] w [63:0];                                  // message schedule array
    reg [31:0] s0, s1, S0, S1, ch, maj, temp1, temp2;     // intermediate regs
    integer j;                                            // loop index for reset logic
    integer i;                                            // loop index for other operations
    state_t present_state;                                // FSM states

    // FSM
    always_ff @(posedge clk) begin
        if (reset) begin
            // initialize hash values
            hash[0] <= 32'h6a09e667;
            hash[1] <= 32'hbb67ae85;
            hash[2] <= 32'h3c6ef372;
            hash[3] <= 32'ha54ff53a;
            hash[4] <= 32'h510e527f;
            hash[5] <= 32'h9b05688c;
            hash[6] <= 32'h1f83d9ab;
            hash[7] <= 32'h5be0cd19;

            // initialize output variables
            a_out <= hash[0];
            b_out <= hash[1];
            c_out <= hash[2];
            d_out <= hash[3];
            e_out <= hash[4];
            f_out <= hash[5];
            g_out <= hash[6];
            h_out <= hash[7];

            // reset message schedule array
            for (j = 0; j < 64; j++) begin
                w[j] <= 32'd0;
            end

            // set initial state
            present_state <= INITIAL;
        end else begin
            if (s) begin
                case (present_state)
                    INITIAL: begin
                        case (bs)
                            2'b01: begin
                                for (i = 0; i < 16; i++) begin
                                    w[i] <= block1[511 - (i * 32) -: 32];
                                end
                            end
                            2'b10: begin
                                for (i = 0; i < 16; i++) begin
                                    w[i] <= block2[511 - (i * 32) -: 32];
                                end
                            end                    
                            default: ;
                        endcase
                        a_out <= a_in;
                        b_out <= b_in;
                        c_out <= c_in;
                        d_out <= d_in;
                        e_out <= e_in;
                        f_out <= f_in;
                        g_out <= g_in;
                        h_out <= h_in;
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
                            S1 = 
                                ({e_out[5:0], e_out[31:6]}) ^ 
                                ({e_out[10:0], e_out[31:11]}) ^ 
                                ({e_out[24:0], e_out[31:25]});
                            ch = (e_out & f_out) ^ (~e_out & g_out);
                            temp1 = h_out + S1 + ch + k[i] + w[i];
                            S0 = 
                                ({a_out[1:0], a_out[31:2]}) ^ 
                                ({a_out[12:0], a_out[31:13]}) ^ 
                                ({a_out[21:0], a_out[31:22]});
                            maj = (a_out & b_out) ^ (a_out & c_out) ^ (b_out & c_out);
                            temp2 = S0 + maj;

                            h_out = g_out;
                            g_out = f_out;
                            f_out = e_out;
                            e_out = d_out + temp1;
                            d_out = c_out;
                            c_out = b_out;
                            b_out = a_out;
                            a_out = temp1 + temp2;
                        end
                        hash[0] = hash[0] + a_out;
                        hash[1] = hash[1] + b_out;
                        hash[2] = hash[2] + c_out;
                        hash[3] = hash[3] + d_out;
                        hash[4] = hash[4] + e_out;
                        hash[5] = hash[5] + f_out;
                        hash[6] = hash[6] + g_out;
                        hash[7] = hash[7] + h_out;
                        present_state <= DONE;
                    end
                    DONE: begin
                        digest = {hash[0],hash[1],hash[2],hash[3],hash[4],hash[5],hash[6],hash[7]};
                        if (reset) present_state <= INITIAL;
                        else present_state <= DONE;
                    end
                    default: present_state <= INITIAL;
                endcase
            end
        end
    end
endmodule
