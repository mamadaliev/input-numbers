/* 
 * Combinatorical Digital Device (CDD)
 * 
 * 
 * @version: 1.0 (beta)
 * @author: Sherzod Mamadaliev
 *          Yaroslav Cherepanov
 * 
 */
module cdd (
    clock,
    reset,
    data,
    out0,
    out1,
    out2,
    out3,
    out4,
    out5,
    cnt
);

// inputs
input clock;      // CLOCK_50
input reset;      // KEY[0]
input [3:0] data; // SW[0]..SW[9]

// outputs
output reg [3:0] out0; // HEX0
output reg [3:0] out1; // HEX1
output reg [3:0] out2; // HEX2
output reg [3:0] out3; // HEX3
output reg [3:0] out4; // HEX4
output reg [3:0] out5; // HEX5
output [2:0] cnt;

reg [3:0] shift_reg [5:0];
reg [3:0] memory; // TODO:
reg [3:0] state;   // for save the states
reg [2:0] counter; // for counting tackts

assign cnt = counter;

// states
parameter RESET  = 0; // start program
parameter WAIT   = 1; // wait to input data
parameter OUTPUT = 2; // display numbers
parameter READ   = 3; // reads numbers on switchers
parameter SHIFT  = 4; // shift numbers

// block transitions
always@(posedge clock or negedge reset)
begin
    if (!reset) begin
        state <= RESET; // state: 0
    end else begin
        case (state)
            RESET:
                state <= WAIT; // state: 1

            WAIT:
                if (counter == 3'd2) begin
                    state <= OUTPUT; // state: 2
                end

            OUTPUT:
                if (counter == 3'd4) begin
                    state <= READ; // state: 3
                end

            READ:
                if (counter == 3'd6) begin
                    state <= SHIFT; // state: 4
                end

            SHIFT:
                if (counter == 3'd7) begin
                    state <= WAIT; // state: 2
                end
        endcase
    end
end

// block states
always@(posedge clock)
begin
    case (state)
        RESET: begin
            out0 = 4'd0;
            out1 = 4'd0;
            out2 = 4'd0;
            out3 = 4'd0;
            out4 = 4'd0;              
            out5 = 4'd0;
            counter = 3'd0;
        end

        WAIT: begin
            counter = counter + 1;
        end 

        OUTPUT: begin
            out0 <= shift_reg[0];
            out1 <= shift_reg[1];
            out2 <= shift_reg[2];
            out3 <= shift_reg[3];
            out4 <= shift_reg[4];
            out5 <= shift_reg[5];
            counter = counter + 1;
        end

        READ: begin
            memory[0] <= data[0];
            memory[1] <= data[1];
            memory[2] <= data[2];
            memory[3] <= data[3];
            counter = counter + 1;
        end

        SHIFT: begin        
            shift_reg[0] <= memory;
            shift_reg[1] <= shift_reg[0];
            shift_reg[2] <= shift_reg[1];
            shift_reg[3] <= shift_reg[2];
            shift_reg[4] <= shift_reg[3];
            shift_reg[5] <= shift_reg[4];
            counter = counter + 1;
        end
    endcase
end
endmodule
