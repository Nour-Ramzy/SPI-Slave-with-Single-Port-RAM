module spi_slave (clk,rst_n,SS_n,MOSI,MISO,rx_data,rx_valid,tx_data,tx_valid);
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_ADD = 3'b011;
parameter READ_DATA = 3'b100;
//
input clk,rst_n,SS_n;
input MOSI;
input [7:0] tx_data;
input tx_valid;
output reg MISO;
output reg [9:0] rx_data;
output reg rx_valid;
// encoding



//next state , current state
reg [2:0] ns,cs;
//internals
 reg [3:0] bit_count;
  //reg [3:0] counter_read_data;
 reg read_ptr;
 reg [9:0] shift_reg;

 //next state logic
 always @(*) begin
    if (!rst_n) begin
        ns = IDLE;
    end
    else begin
        case (cs)
            IDLE: begin
                if (!SS_n) begin
                    ns = CHK_CMD;
                end
                else begin
                    ns = IDLE;
                end
            end
            CHK_CMD: begin
                if (!SS_n && !MOSI) begin
                    ns = WRITE;
                end
                else if (!SS_n && MOSI && !read_ptr) begin
                    ns = READ_ADD;
                end
                else if (!SS_n && MOSI && read_ptr) begin
                    ns = READ_DATA;
                end
                else begin
                    ns = IDLE;
                end
            end
            WRITE: begin
                if (SS_n) begin
                    ns = IDLE;
                end
                else begin
                    ns = WRITE;
                end
            end
            READ_ADD: begin
                if (SS_n) begin
                    ns = IDLE;
                end
                else begin
                    ns = READ_ADD;
                end
            end
            READ_DATA: begin
                if (SS_n) begin
                    ns = IDLE;
                end
                else begin
                    ns = READ_DATA;
                end
            end
            default: ns= IDLE;
        endcase
    end
 end

 // state memory
 always @(posedge clk) begin
    if (!rst_n) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
 end

 //output logic
 always @(posedge clk) begin
    if (!rst_n) begin
        bit_count <= 4'd0;
        //counter_read_data <= 4'd0;
        read_ptr <= 1'b0;
        shift_reg <= 10'b0;
        rx_valid <= 1'b0;
        rx_data <= 10'b0;
        MISO <= 1'b0;
    end
    else begin
        case (cs)
           IDLE : begin
                rx_valid <= 0;
                shift_reg <= 10'b0;
            end
            CHK_CMD : begin
                bit_count <= 4'd10;
                //counter_read_data <= 4'd10;
            end 
           WRITE: begin
                    if (bit_count > 0) begin
                    shift_reg <= {shift_reg[8:0], MOSI};
                    bit_count <= bit_count - 1;
                end
                else begin
                    rx_data  <= shift_reg;
                    rx_valid <= 1;
                    bit_count <= 0; // prevent underflow
                end

                end
            READ_ADD: begin
                   
                   if (bit_count > 0) begin
                    shift_reg <= {shift_reg[8:0], MOSI};
                    bit_count <= bit_count - 1;
                end
                else begin
                    rx_data  <= shift_reg;
                    rx_valid <= 1;
                    read_ptr <= 1;   // mark address as received
                    bit_count <= 0;
                end
                end  
            READ_DATA: begin
                if (tx_valid) begin
                    rx_valid <= 0;
                    // Read Data
                    if (bit_count == 0)
                        read_ptr <= 0;
                    else begin
                        MISO <= tx_data[bit_count-1];
                        bit_count <= bit_count - 1;
                    end
                end
                  // check to read edata
                else begin
                   // Request to read data from RAM
                    if (bit_count > 0) begin
                        shift_reg <= {shift_reg[8:0], MOSI};
                        bit_count <= bit_count - 1;
                    end
                    else begin
                        rx_data  <= shift_reg;
                        rx_valid <= 1;
                        bit_count <= 4'd9; // 1 extra cycle before tx_valid arrives
                    end
                end
            end      
        endcase
    end
 end


endmodule //spi_slave  