
module uart_tb (
  input clk,
  input rx,          // <= from FT232
  input rst,
  output tx,         // => to FT232
  output [6:0] d1,
  output [6:0] d2
);

wire [7:0] dout;
wire done;

uart_rx urx(
  .clk(clk),
  .rx(rx),
  .dout(dout),
  .done(done)
);

seg7 seg(
  .din(dout),
  .d1(d1),
  .d2(d2)
);

uart_tx utx (
  .clk(clk),
  .start(done),
  .din(dout), // <=
  .tx(tx),    // =>
  .rdy(rdy)
);

endmodule