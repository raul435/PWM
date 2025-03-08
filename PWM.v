module PWM (
    input wire clk,
    input wire en,
    input wire btn_inc,
    input wire btn_dec,
    output reg pwm_out
);

    parameter PERIOD_CYCLES = 1_000_000;
    parameter MIN_PULSE = 25_000;
    parameter MAX_PULSE = 125_000;
    parameter STEP_SIZE = 5;

    wire clk_slow;
    wire btn_inc_dev, btn_dec_dev;

    reg [10:0] duty_cycle = 25;
    reg [19:0] pulse_duration = MIN_PULSE;
    reg [19:0] cycle_counter = 0;
    reg btn_inc_last = 1, btn_dec_last = 1;

    Debouncer debouncer_inst_inc ( .clk(clk), .rst(0), .pb_in(btn_inc), .pb_out(btn_inc_dev) );
    Debouncer debouncer_inst_dec ( .clk(clk), .rst(0), .pb_in(btn_dec), .pb_out(btn_dec_dev) );
    ClockDivider clock_divider_inst ( .clk(clk), .rst(0), .clk_div(clk_slow) );

    always @(posedge clk_slow) begin
        if (en) begin
            if (!btn_inc_dev && btn_inc_last && (duty_cycle < 125))
                duty_cycle <= duty_cycle + STEP_SIZE;
            if (!btn_dec_dev && btn_dec_last && (duty_cycle > 25))
                duty_cycle <= duty_cycle - STEP_SIZE;
        end
        btn_inc_last <= btn_inc_dev;
        btn_dec_last <= btn_dec_dev;
    end

    always @(posedge clk) begin
        if (!en) begin
            pwm_out <= 0;
            cycle_counter <= 0;
        end else begin
            pulse_duration <= MIN_PULSE + ((MAX_PULSE - MIN_PULSE) * (duty_cycle - 25)) / 100;
            pwm_out <= (cycle_counter < pulse_duration) ? 1 : 0;
            cycle_counter <= (cycle_counter >= PERIOD_CYCLES - 1) ? 0 : cycle_counter + 1;
        end
    end

endmodule


