//`include "uart_tx"

/* verilator lint_off CASEINCOMPLETE */

module uart_tb (
  input clk,
  output tx
);

parameter
  START = 2'd0,
  WAIT  = 2'd1,
  NEXT  = 2'd2,
  STOP  = 2'd3;

uart_tx utx(
  .clk(clk),
  .start(start),
  .din(data),
  .tx(tx),
  .rdy(rdy)
);

reg [7:0] data;
reg [1:0] state;
reg [3:0] chr_cnt;
reg start;
wire rdy;

always @(chr_cnt)
  case (chr_cnt)
    4'd00: data = "A";
    4'd01: data = "B";
    4'd02: data = "C";
    4'd03: data = "D";
    4'd04: data = "\r";
    4'd05: data = "\n";
    4'd06: data = "a";
    4'd07: data = "b";
    4'd08: data = "c";
    4'd09: data = "d";
    4'd10: data = "\r";
    4'd11: data = "\n";
    default: data = ".";
  endcase

always @(posedge clk)
  case (state)
    START: if (!rdy) state <= WAIT;
    WAIT: if (rdy) state <= NEXT;
    NEXT: state <= START;
  endcase

always @*
  case (state)
    START:
      if (rdy) start = 1;
      else start = 0;
    default: start = 0;
  endcase

always @(posedge clk)
  case (state)
    NEXT: 
      if (chr_cnt == 4'd11)
        chr_cnt <= 0;
      else
        chr_cnt <= chr_cnt + 4'd1;
    STOP: chr_cnt <= 0;
  endcase

endmodule