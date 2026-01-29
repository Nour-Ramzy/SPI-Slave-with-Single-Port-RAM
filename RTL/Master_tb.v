module master_tb (
    
);
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_ADD = 3'b011;
parameter READ_DATA = 3'b100;

reg SCK,MOSI,SS_n,rst_n;
wire MISO;

//
SPI_wrapper my_spi(.*);
//
initial begin
    SCK = 1'b0;
    forever #1 SCK = ~SCK;
end
//
reg [7:0] wr_addr, rd_addr;
reg [7:0] wr_data, rd_data;

initial begin
    $readmemh ("mem.dat",my_spi.dut2.mem);
    // Test Reset Operation
    $display ("Test Reset Operation");
    rst_n = 0;
    {wr_addr,rd_addr,wr_data,rd_data} = 0;
    repeat (5) begin
        @(negedge SCK);
        if ((my_spi.dut1.cs != IDLE) && (MISO != 0)) begin
            $display ("Error in Reset Operation");
            $stop;
        end
    end
    rst_n = 1;
    // Test Write Address Operation
    $display ("Test Write Address Operation");
    SS_n = 0;
    @(negedge SCK);
    MOSI = 0;
    repeat (3) @(negedge SCK);
    repeat (8) begin
        MOSI = $random;
        wr_addr = {wr_addr[6:0],MOSI};
        @(negedge SCK);
    end
    SS_n = 1;
    repeat (2) @(negedge SCK);
    if (my_spi.dut2.wr_addr != wr_addr) begin
        $display ("Error in Write Address Operation");
        $stop;
    end
    @(negedge SCK);
    // Test Write Data Operation
    $display ("Test Write Data Operation");
    SS_n = 0;
    @(negedge SCK);
    MOSI = 0;
    repeat (2) @(negedge SCK);
    MOSI = 1;
    @(negedge SCK);
    repeat (8) begin
        MOSI = $random;
        wr_data = {wr_data[6:0],MOSI};
        @(negedge SCK);
    end
    SS_n = 1;
    repeat (2) @(negedge SCK);
    if (my_spi.dut2.mem[my_spi.dut2.wr_addr] != wr_data) begin
        $display ("Error in Write Data Operation");
        $stop;
    end
    @(negedge SCK);
    // Test Read Address Operation
    $display ("Test Read Address Operation");
    SS_n = 0;
    @(negedge SCK);
    MOSI = 1;                
    repeat (2) @(negedge SCK);
    MOSI = 0;
    @(negedge SCK);
    repeat (8) begin
        MOSI = $random;
        rd_addr = {rd_addr[6:0],MOSI};
        @(negedge SCK);
    end
    SS_n = 1;
    repeat (2) @(negedge SCK);
    if (my_spi.dut2.rd_addr != rd_addr) begin
        $display ("Error in Read Address Operation");
        $stop;
    end
    // Test Read Data Operation
    $display ("Test Read Data Operation");
    SS_n = 0;
    @(negedge SCK);
    MOSI = 1;
    repeat (3) @(negedge SCK);
    repeat (8) begin
        MOSI = $random; // Dummy Data
        @(negedge SCK);
    end
    @(negedge SCK);
    repeat (8) begin
        @(negedge SCK);
        rd_data = {rd_data[6:0],MISO};
    end
    SS_n = 1;
    repeat (2) @(negedge SCK);
    
    repeat (2) @(negedge SCK);
    $stop;
end

endmodule