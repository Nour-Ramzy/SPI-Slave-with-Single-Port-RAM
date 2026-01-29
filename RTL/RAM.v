module spi_sram (clk,rst_n,din,rx_valid,dout,tx_valid);
parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;
input clk,rst_n,rx_valid;
input [9:0] din;
output reg [7:0] dout;
output reg tx_valid;

//internal 
reg [7:0] mem [MEM_DEPTH-1:0];
//internal adress
reg [ADDR_SIZE-1:0] wr_addr,rd_addr;
//
always @(posedge clk) begin
    if (!rst_n) begin
        dout <= 8'b0;
        tx_valid <= 1'b0;
        wr_addr <= 0;
        rd_addr <= 0;
    end
    else begin
    tx_valid = (din[9] & din[8] & rx_valid)? 1'b1 : 1'b0;

    if (rx_valid) begin
            case (din[9:8])
                2'b00 : wr_addr <= din[7:0];
                2'b01 : mem[wr_addr] <= din[7:0];
                2'b10 : rd_addr <= din[7:0];
                2'b11 : dout <= mem[rd_addr];
            endcase
        end
    
end
end

endmodule //spi_sram