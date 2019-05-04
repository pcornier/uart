
module uart_tx (
  input clk,
  input start,
  input [7:0] din,
  output reg tx,
  output reg rdy
);

reg [3:0] bit_cnt;
wire [9:0] data;
reg state, next_state;

parameter IDLE = 1'b0, DATA = 1'b1;

wire clk_en;
reg [8:0] clk_cnt;

always @(posedge clk)
  if (clk_cnt == 9'd434) // 50M / 115200 = 434
    clk_cnt <= 9'd0;
  else
    clk_cnt <= clk_cnt + 9'd1;

assign clk_en = clk_cnt == 9'd0; 

// stop bit, data[7:0], start bit
assign data = { 1'b1, din, 1'b0 };

always @(posedge clk_en)
  if (start)
    rdy <= 0;
  else if (state == IDLE)
    rdy <= 1;

always @(posedge clk_en)
  state <= next_state;

always @(posedge clk_en)
  case (state)
    IDLE: bit_cnt <= 0;
    DATA: bit_cnt <= bit_cnt + 4'd1;
  endcase

always @*
  case (state)
    IDLE: if (start) next_state = DATA;
    DATA: if (bit_cnt == 4'd9) next_state = IDLE;
  endcase

always @*
  case (state)
    IDLE: tx = 1'b1;
    DATA: tx = data[bit_cnt];
  endcase

endmodule