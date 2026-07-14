module FIFO_TB;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;

    reg [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    wire [$clog2(DEPTH+1)-1:0] count;


    // FIFO Instance
    FIFO #(DATA_WIDTH, DEPTH) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty),
        .count(count)
    );


    // Clock generation
    always #5 clk = ~clk;


    // Expected memory for checking
    reg [DATA_WIDTH-1:0] expected_mem [0:DEPTH-1];

    integer wr_index;
    integer rd_index;


    initial begin

        clk = 0;
        rst = 1;

        wr_en = 0;
        rd_en = 0;

        din = 0;

        wr_index = 0;
        rd_index = 0;


        // Reset
        #20;
        rst = 0;


        // -----------------------------
        // Basic Write Test
        // -----------------------------

        repeat(5) begin

            @(posedge clk);

            if(!full) begin

                wr_en = 1;

                din = wr_index + 10;

                expected_mem[wr_index] = din;

                wr_index = wr_index + 1;

            end

        end


        @(posedge clk);
        wr_en = 0;



        // -----------------------------
        // Basic Read Test
        // -----------------------------

        repeat(5) begin

            @(posedge clk);

            if(!empty) begin

                rd_en = 1;

                #1;

                if(dout !== expected_mem[rd_index]) begin

                    $display("ERROR: Data mismatch at %0t",$time);

                    $display("Expected = %0d, Got = %0d",
                              expected_mem[rd_index],
                              dout);

                    $stop;

                end


                rd_index = rd_index + 1;

            end

        end


        @(posedge clk);
        rd_en = 0;



        // -----------------------------
        // FIFO Full Test
        // -----------------------------

        wr_index = 0;


        repeat(DEPTH) begin

            @(posedge clk);


            if(!full) begin

                wr_en = 1;

                din = $random;


                expected_mem[wr_index] = din;

                wr_index = wr_index + 1;

            end

        end


        @(posedge clk);

        wr_en = 0;



        if(!full)

            $display("ERROR: FIFO should be full!");

        else

            $display("FIFO FULL condition verified.");




        // -----------------------------
        // FIFO Empty Test
        // -----------------------------

        rd_index = 0;


        repeat(DEPTH) begin

            @(posedge clk);


            if(!empty) begin

                rd_en = 1;

                #1;


                if(dout !== expected_mem[rd_index]) begin

                    $display("ERROR during full-read test");

                    $stop;

                end


                rd_index = rd_index + 1;

            end

        end



        @(posedge clk);

        rd_en = 0;



        if(!empty)

            $display("ERROR: FIFO should be empty!");

        else

            $display("FIFO EMPTY condition verified.");





        // -----------------------------
        // Simultaneous Read Write Test
        // -----------------------------

        @(posedge clk);

        wr_en = 1;
        rd_en = 1;

        din = 8'hAA;



        @(posedge clk);

        wr_en = 0;
        rd_en = 0;



        $display("Simultaneous R/W test completed.");



        #50;


        $display("ALL TESTS PASSED.");

        $finish;


    end



    // Monitor
    initial begin

        $monitor(
        "T=%0t | WR=%b | RD=%b | DIN=%0d | DOUT=%0d | FULL=%b | EMPTY=%b | COUNT=%0d",
        $time,
        wr_en,
        rd_en,
        din,
        dout,
        full,
        empty,
        count
        );

    end


endmodule