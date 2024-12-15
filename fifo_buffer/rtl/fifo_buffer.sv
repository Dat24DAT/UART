module fifo_buffer #(
    parameter B = 8, //bit_length of each word
              W = 4  // number of address bits
)(
   input logic clk, rst,
   input logic r, w, // read.write flag
   input logic [B-1:0] w_data, 
   output logic empty, full, //status flag
   output logic [B-1:0] r_data
);

logic [B-1:0] arr_reg [2**W-1:0]; // reg arr
logic [W-1:0] w_ptr_reg, w_ptr_next, w_prt_succ;
logic [W-1:0] r_ptr_reg, r_ptr_next, r_prt_succ;
logic full_reg, full_next, empty_reg, empty_next;
logic w_en;

// body
// reg for write 
assign w_en = w & ~full_reg;
always_ff @( posedge clk ) begin 
    if(w_en) arr_reg[w_ptr_reg] <= w_data;
end
assign r_data = arr_reg[r_ptr_reg];

// fifo control 
// register operation

always_ff @(posedge clk, posedge rst) begin 
    if(rst) begin 
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 0;
        empty_reg <= 1'b1;
    end else begin 
        w_ptr_reg <= w_ptr_next;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

// next_state logic for read and write pointers

always_comb begin 
    w_prt_succ = w_ptr_reg + 1'b1;
    r_prt_succ = r_ptr_reg + 1'b1;
    // default case
    w_ptr_next = w_ptr_reg;
    r_ptr_next = r_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;
    //full case
    case ({w, r})
        2'b01: //read=1
            if(!empty_reg) begin //fifo is full
                r_ptr_next = r_prt_succ;
                full_next = 0; 
                if(r_prt_succ==w_ptr_reg) begin 
                    empty_next = 1;
                end
            end
        2'b10: //write=1
            if(!full_reg) begin //fifo is empty
                w_ptr_next = w_prt_succ;
                empty_next = 0;
                if(w_prt_succ==r_ptr_reg) begin 
                    full_next = 1;
                end
            end
        2'b11: //write=read=1
            begin 
                w_ptr_next = w_prt_succ;
                r_ptr_next = r_prt_succ;
            end
    endcase
end

//output 
assign full = full_reg;
assign empty = empty_reg;
endmodule
