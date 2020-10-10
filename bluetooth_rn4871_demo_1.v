//////////////////////////////////////////////////////////////////////////////
// Demo project showing communication with a Bluetooth PMOD board.
// Board: Digilent PMOD BLE: Bluetooth Low Energy Interface
// Link: https://store.digilentinc.com/pmod-ble-bluetooth-low-energy-interface/
// Uses the Nandland Go Board for FPGA: https://nandland.com/goboard
// License: The MIT License (you're free to do what you want with this code)
//
// Description: This project sends UART traffic from a computer to the Go Board.
// The UART is forwarded to a bluetooth transmitter which is received by a second
// boards receiver. Receiver board displays the value from the computer on the 
// 7 segment display.
//
// This leverages Go Board Project 7.
//////////////////////////////////////////////////////////////////////////////

module bluetooth_rn4871_demo_1
 (input  i_Clk,       // Main Clock
  // Computer UART:
  input  i_UART_RX,   // UART RX Data from computer
  output o_UART_TX,   // UART TX Data to computer
  // Bluetooth Interface
  output io_PMOD_2,   // RXD, Receive on RN4871 (FPGA drives this)
  input  io_PMOD_3,   // TXD, Transmit on RN4871
  output io_PMOD_8,   // RST_N, Reset (active low)
  // 7-Segment Displays, Segment1 is upper digit
  output o_Segment1_A,
  output o_Segment1_B,
  output o_Segment1_C,
  output o_Segment1_D,
  output o_Segment1_E,
  output o_Segment1_F,
  output o_Segment1_G,
  // Segment2 is lower digit
  output o_Segment2_A,
  output o_Segment2_B,
  output o_Segment2_C,
  output o_Segment2_D,
  output o_Segment2_E,
  output o_Segment2_F,
  output o_Segment2_G);

  // 25,000,000 / 115,200 = 217
  localparam CLOCKS_PER_BIT = 217;

  wire w_RX_From_Comp_DV, w_RX_From_BT_DV;
  wire [7:0] w_RX_From_Comp_Byte, w_RX_From_BT_Byte;
  wire w_TX_To_Comp_Active, w_TX_To_Comp_Serial;

  wire w_Segment1_A, w_Segment2_A;
  wire w_Segment1_B, w_Segment2_B;
  wire w_Segment1_C, w_Segment2_C;
  wire w_Segment1_D, w_Segment2_D;
  wire w_Segment1_E, w_Segment2_E;
  wire w_Segment1_F, w_Segment2_F;
  wire w_Segment1_G, w_Segment2_G;

/* COMMENTED OUT AND JUST TIE COMPUTER TO BT DIRECTLY.
  // UART Receiver (data coming from computer)
  UART_RX #(.CLKS_PER_BIT(CLOCKS_PER_BIT)) UART_RX_From_Comp_Inst
  (.i_Clock(i_Clk),
   .i_RX_Serial(i_UART_RX),
   .o_RX_DV(w_RX_From_Comp_DV),
   .o_RX_Byte(w_RX_From_Comp_Byte));

  // UART Transmitter (data sent to computer)
  // Data sent to computer is data from the Bluetooth Module.
  UART_TX #(.CLKS_PER_BIT(CLOCKS_PER_BIT)) UART_TX_To_Comp_Inst
  (.i_Clock(i_Clk),
   .i_TX_DV(w_RX_From_BT_DV),
   .i_TX_Byte(w_RX_From_BT_Byte),
   .o_TX_Active(w_TX_To_Comp_Active),
   .o_TX_Serial(w_TX_To_Comp_Serial),
   .o_TX_Done());

  // Drive UART to computer line high when transmitter is not active
  assign o_UART_TX = w_TX_To_Comp_Active ? w_TX_To_Comp_Serial : 1'b1; 

  // UART Transmitter (data sent to bluetooth TX)
  // Data sent to bluetooth module is from computer receiver.
  UART_TX #(.CLKS_PER_BIT(CLOCKS_PER_BIT)) UART_TX_To_Comp_Inst
  (.i_Clock(i_Clk),
   .i_TX_DV(w_RX_From_BT_DV),
   .i_TX_Byte(w_RX_From_BT_Byte),
   .o_TX_Active(w_TX_To_Comp_Active),
   .o_TX_Serial(w_TX_To_Comp_Serial),
   .o_TX_Done());
*/

  // Forward data from computer to the bluetooth transmitter
  assign o_UART_TX = io_PMOD_3;
  assign io_PMOD_2 = i_UART_RX;

  // Drive BT chip out of reset
  assign io_PMOD_8 = 1'b1;

  // UART Receiver (data coming from computer)
  // Gets forwarded to the 7-segment displays
  UART_RX #(.CLKS_PER_BIT(CLOCKS_PER_BIT)) UART_RX_From_BT_Inst
  (.i_Rst_L(1'b1),
   .i_Clock(i_Clk),
   .i_RX_Serial(i_UART_RX),
   .o_RX_DV(w_RX_From_BT_DV),
   .o_RX_Byte(w_RX_From_BT_Byte));

  // Binary to 7-Segment Converter for Upper Digit
  Binary_To_7Segment SevenSeg1_Inst
  (.i_Clk(i_Clk),
   .i_Binary_Num(w_RX_From_BT_Byte[7:4]),
   .o_Segment_A(w_Segment1_A),
   .o_Segment_B(w_Segment1_B),
   .o_Segment_C(w_Segment1_C),
   .o_Segment_D(w_Segment1_D),
   .o_Segment_E(w_Segment1_E),
   .o_Segment_F(w_Segment1_F),
   .o_Segment_G(w_Segment1_G));
   
  assign o_Segment1_A = ~w_Segment1_A;
  assign o_Segment1_B = ~w_Segment1_B;
  assign o_Segment1_C = ~w_Segment1_C;
  assign o_Segment1_D = ~w_Segment1_D;
  assign o_Segment1_E = ~w_Segment1_E;
  assign o_Segment1_F = ~w_Segment1_F;
  assign o_Segment1_G = ~w_Segment1_G;
  
  
  // Binary to 7-Segment Converter for Lower Digit
  Binary_To_7Segment SevenSeg2_Inst
  (.i_Clk(i_Clk),
   .i_Binary_Num(w_RX_From_BT_Byte[3:0]),
   .o_Segment_A(w_Segment2_A),
   .o_Segment_B(w_Segment2_B),
   .o_Segment_C(w_Segment2_C),
   .o_Segment_D(w_Segment2_D),
   .o_Segment_E(w_Segment2_E),
   .o_Segment_F(w_Segment2_F),
   .o_Segment_G(w_Segment2_G));
  
  assign o_Segment2_A = ~w_Segment2_A;
  assign o_Segment2_B = ~w_Segment2_B;
  assign o_Segment2_C = ~w_Segment2_C;
  assign o_Segment2_D = ~w_Segment2_D;
  assign o_Segment2_E = ~w_Segment2_E;
  assign o_Segment2_F = ~w_Segment2_F;
  assign o_Segment2_G = ~w_Segment2_G;

endmodule
