`timescale 1ns/1ps
module tb_fir;
    parameter ARCH = 0;
    parameter TEST_CASE = 0; // impulse, 500 kHz, 1.6 MHz, stress
    parameter USE_DDS = 0;
    `include "fir_defs.vh"
    localparam COUNT = 256;
    localparam TOTAL = COUNT + TAPS;
    reg clk = 0;
    reg rst = 1;
    reg in_valid = 0;
    wire in_ready, out_valid;
    reg signed [15:0] x = 0;
    wire signed [36:0] y;
    integer sent = 0, received = 0;
    reg passed = 0;
    wire pass_valid, stop_valid;
    wire [15:0] pass_data, stop_data;
    reg signed [15:0] samples [0:TOTAL-1];
    reg [15:0] lfsr = 16'hACE1;
    integer i, captured;
    real frequency, value;
    always #100 clk = ~clk;
    main #(.ARCH(ARCH)) dut (clk, rst, in_valid, in_ready, x, out_valid, y);
    generate if (USE_DDS) begin: vendor_stimulus
        dds_500k pass_source (.aclk(clk), .aresetn(~rst),
            .m_axis_data_tvalid(pass_valid), .m_axis_data_tdata(pass_data));
        dds_1600k stop_source (.aclk(clk), .aresetn(~rst),
            .m_axis_data_tvalid(stop_valid), .m_axis_data_tdata(stop_data));
    end endgenerate

    initial begin
        if (ARCH < 0 || ARCH > 2 || TEST_CASE < 0 || TEST_CASE > 3)
            $fatal(1, "Invalid architecture or test case");
        if (ARCH == 2 && !USE_DDS)
            $fatal(1, "Generate vendor IP with setup_lab5.tcl");
        for (i=0; i<TOTAL; i=i+1) samples[i] = 0;
        #800;
        @(negedge clk); rst = 0;
        if (TEST_CASE == 0) begin
            for (i = 0; i < TOTAL; i = i + 1)
                samples[i] = (i < 10) ? 16'sd0 : 16'sd1000;
        end
        else if (TEST_CASE == 1 || TEST_CASE == 2) begin
            if (USE_DDS) begin
                // Capture consecutive DDS samples, then replay with backpressure.
                captured = 0;
                while (captured < COUNT) begin
                    @(posedge clk);
                    if (TEST_CASE == 1 && pass_valid) begin
                        samples[captured] = $signed(pass_data);
                        captured = captured + 1;
                    end else if (TEST_CASE == 2 && stop_valid) begin
                        samples[captured] = $signed(stop_data);
                        captured = captured + 1;
                    end
                end
            end else begin
                frequency = (TEST_CASE == 1) ? 0.5e6 : 1.6e6;
                for (i=0; i<COUNT; i=i+1) begin
                    value = 30000.0 * $sin(2.0*3.141592653589793*frequency*i/5.0e6);
                    // Match VHDL round: nearest integer, ties away from zero.
                    samples[i] = $rtoi(value >= 0 ? value + 0.5 : value - 0.5);
                end
            end
        end else begin
            for (i=0; i<COUNT; i=i+1) begin
                lfsr = {lfsr[14:0], lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
                samples[i] = $signed(lfsr);
            end
            samples[0] = -16'sd32768;
            samples[1] = 16'sd32767;
        end
        for (i=0; i<TOTAL; i=i+1) begin
            @(negedge clk); x = samples[i]; in_valid = 1;
            @(posedge clk);
            while (!in_ready) @(posedge clk);
            if (TEST_CASE == 3 && i % 7 == 0) begin
                @(negedge clk); in_valid = 0;
                repeat (3) @(posedge clk);
            end
        end
        @(negedge clk); in_valid = 0;
        wait (received == TOTAL);
        #10000; // Detect duplicate outputs after drain.
        $display("PASS: architecture=%0d case=%0d checked %0d outputs", ARCH, TEST_CASE, received);
        passed = 1;
        $fclose(trace);
        #1; $finish;
    end

    reg signed [36:0] expected [0:TOTAL-1];
    reg signed [15:0] history [0:TAPS-1];
    reg signed [31:0] product;
    reg signed [36:0] sum;
    integer wr = 0, rd = 0, j, trace;
    initial begin
        trace = $fopen("fir_trace.csv", "w");
        if (!trace) $fatal(1, "Cannot open fir_trace.csv");
        $fdisplay(trace, "event,index,time_ns,input,output,expected");
    end
    always @(posedge clk) begin
        if (rst) begin
            for (j=0; j<TAPS; j=j+1) history[j] = 0;
            wr = 0; rd = 0; sent = 0; received = 0;
        end else begin
            if (in_valid && in_ready) begin
                for (j=TAPS-1; j>0; j=j-1) history[j] = history[j-1];
                history[0] = x;
                sum = 0;
                for (j=0; j<TAPS; j=j+1) begin
                    product = history[j] * coeff(j);
                    sum = sum + {{5{product[31]}}, product};
                end
                if (wr >= TOTAL) $fatal(1, "Too many accepted inputs");
                expected[wr] = sum;
                $fdisplay(trace, "input,%0d,%0d,%0d,,%0d", wr, $time, x, sum);
                wr = wr + 1; sent = wr;
            end
            #1; // Observe registered outputs after nonblocking assignments.
            if (out_valid) begin
                if (rd >= wr) $fatal(1, "Unexpected or duplicate output");
                if (y !== expected[rd])
                    $fatal(1, "FIR mismatch at sample %0d: actual=%h expected=%h", rd, y, expected[rd]);
                $fdisplay(trace, "output,%0d,%0d,,%0d,%0d", rd, $time, y, expected[rd]);
                rd = rd + 1; received = rd;
            end
        end
    end
    initial begin
        #3000000;
        $fatal(1, "Timeout: stalled interface or missing output");
    end
endmodule
