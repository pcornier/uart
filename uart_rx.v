
/* verilator lint_off CASEINCOMPLETE */

module uart_rx (
  input clk,
  input rx,
  output reg [7:0] dout,
  output done
);

reg [2:0] state;
reg [2:0] new_state;
reg [7:0] SR;
reg [2:0] SC;
reg [4:0] cycles;

parameter
  IDLE   = 3'd0,
  READ   = 3'd1,
  WAIT1  = 3'd2,
  WAIT2  = 3'd3,
  STOP   = 3'd4;


reg [4:0] clk_cnt;
wire clk_en;

always @(posedge clk)
  if (clk_cnt == 5'd27) // 50M / 115200 / 16 = 27
    clk_cnt <= 5'd0;
  else
    clk_cnt <= clk_cnt + 5'd1;

assign clk_en = clk_cnt == 5'd0;

always @(posedge clk_en)
  state <= new_state;

assign done = state == STOP;

always @*
  case (state)
    IDLE: if (rx == 0) new_state = WAIT1;
    READ:
      if (SC == 3'd7)
        new_state = STOP;
      else
        new_state = WAIT2;
    WAIT1: if (cycles == 5'd21) new_state = READ;
    WAIT2: if (cycles == 5'd14) new_state = READ;
    STOP: if (cycles == 5'd12) new_state = IDLE;
  endcase

always @(posedge clk_en)
  case (state)
    IDLE,
    READ: cycles <= 0;
    WAIT1,
    WAIT2,
    STOP: cycles <= cycles + 5'd1;
  endcase

always @(posedge clk_en)
  case (state)
    IDLE: SR <= 8'b0;
    READ: SR <= { rx , SR[7:1] };
  endcase

always @(posedge clk_en)
  case (state)
    IDLE: SC <= 3'd0;
    READ: SC <= SC + 3'd1;
  endcase
 
always @(posedge clk_en)
  if (state == STOP && cycles == 5'd12) dout <= SR;
  
endmodule
