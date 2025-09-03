module fpga(
    input  wire clk,          // 100 MHz clock
    input  wire reset_n,      // Active-low reset button
    input  wire flare_detect, // Input from LM393 via PMOD
    output reg  normal_led,
    output reg  fallback_led,
    output reg [7:0] an,      // Anodes for 8-digit 7-seg
    output reg [6:0] seg      // Cathodes (a-g)
);

    // ----- State encoding -----
    parameter NORMAL   = 2'b00;
    parameter FALLBACK = 2'b01;
    parameter RECOVER  = 2'b10;

    reg [1:0] current_state, next_state;

    // ----- State transition -----
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= NORMAL;
        else
            current_state <= next_state;
    end

    // ----- Next state logic -----
    always @(*) begin
        case (current_state)
            NORMAL:   next_state = flare_detect ? FALLBACK : NORMAL;
            FALLBACK: next_state = flare_detect ? FALLBACK : RECOVER;
            RECOVER:  next_state = NORMAL;
            default:  next_state = NORMAL;
        endcase
    end

    // ----- Output LEDs -----
    always @(*) begin
        normal_led   = (current_state == NORMAL || current_state == RECOVER) ? 1'b1 : 1'b0;
        fallback_led = (current_state == FALLBACK) ? 1'b1 : 1'b0;
    end

    // ----- Seven Segment Display -----
    reg [2:0] digit_select;  // which digit 0-7
    reg [16:0] clkdiv;

    always @(posedge clk) clkdiv <= clkdiv + 1;
    always @(posedge clkdiv[16]) digit_select <= digit_select + 1;

    // Character ROM for FALL
    function [6:0] char_to_seg(input [7:0] c);
        case (c)
            "F": char_to_seg = 7'b0001110;
            "A": char_to_seg = 7'b0001000;
            "L": char_to_seg = 7'b1000111;
            "1": char_to_seg = 7'b1001111;
            "0": char_to_seg = 7'b1000000;
            default: char_to_seg = 7'b1111111; // blank
        endcase
    endfunction

    // Message select
    reg [7:0] message [0:7];
    always @(*) begin
        // default blank
        message[0] = " ";
        message[1] = " ";
        message[2] = " ";
        message[3] = " ";
        message[4] = " ";
        message[5] = " ";
        message[6] = " ";
        message[7] = " ";

        if (current_state == FALLBACK) begin
            // show "FALL" left-to-right
            message[7] = "F";
            message[6] = "A";
            message[5] = "L";
            message[4] = "L";
        end else begin
            // show "10100111"
            message[7] = "1";
            message[6] = "0";
            message[5] = "1";
            message[4] = "0";
            message[3] = "0";
            message[2] = "1";
            message[1] = "1";
            message[0] = "1";
        end
    end

    // Drive digit
    always @(*) begin
        an = 8'b11111111;            // disable all digits
        an[digit_select] = 0;        // enable one digit (active low)
        seg = char_to_seg(message[digit_select]);
    end

endmodule
