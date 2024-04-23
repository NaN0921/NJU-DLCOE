`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/19 12:00:18
// Design Name: 
// Module Name: lab06_b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lfsr_seg(
    input  [7:0]  SW,
    input CLK100MHZ,
	input  BTNC,
	input  load,
	output reg [3:0] LED,
	output [7:0] AN,
	output [7:0] hex
);

    reg [7:0] dout;
    reg delay1, delay2;
    wire lin, clk;
    wire clk_20ms, clk_1ms;
    assign lin = dout[4] ^ dout[3] ^ dout[2] ^ dout[0];
    assign clk = delay1 & delay2;
    
    always @(posedge clk_20ms) begin
        delay1 <= BTNC;
        delay2 <= delay1;
    end
    
    always @(posedge clk)
        if(!load) begin dout <= {lin, dout[7:1]}; LED <= LED + 1; end
        else begin dout <= SW; LED <= 4'b0; end
        
    clkgen #(1000) my_clk1(CLK100MHZ, 1'b0, 1'b1, clk_1ms);
    clkgen #(50) my_clk2(CLK100MHZ, 1'b0, 1'b1, clk_20ms);
    sevenseg my7seg(clk_1ms, 8'b00000011, {24'b0, dout}, AN, hex);
endmodule

module lfsr_seg_p(
    input  [7:0]  SW,
    input CLK100MHZ,
	input  clk,
	input  load,
	output reg [3:0] LED,
	output [7:0] AN,
	output [7:0] hex
);
    reg [7:0] dout;
    wire lin;
    wire clk_5khz;
    assign lin = dout[4] ^ dout[3] ^ dout[2] ^ dout[0];
    
    always @(posedge clk)
        if(!load) begin dout <= {lin, dout[7:1]}; LED <= 4'b0; end
        else begin dout <= SW; LED <= LED + 1; end
        
    clkgen #(5000) my_clk(CLK100MHZ, 1'b0, 1'b1, clk_5khz);
    sevenseg my7seg(clk_5khz, 8'b00000011, {24'b0, dout}, AN, hex);
endmodule

module clkgen(input clkin, input rst, input clken, output reg clkout = 0);
    parameter clk_freq = 1;  
    parameter count_limit = 100000000/clk_freq/2 - 1;
    //parameter count_limit = 10/clk_freq/2 - 1; //for simulation test
    
    reg [31:0] clkcount = 32'b0;
    always @(posedge clkin) begin
        if(rst) begin clkcount <= 0; clkout <= 0; end
        else begin
            if(clken) begin
                if(clkcount >= count_limit) begin 
                    clkcount <= 32'd0; 
                    clkout <= ~clkout;
                end
                else clkcount <= clkcount + 1;
            end
        end
    end
endmodule

module sevenseg( input clk, input [7:0] en, input [31:0] digits, output [7:0] an, output [7:0] hex);
    reg [3:0] d;
    reg [2:0] s;
    wire [7:0] my_an;
    initial begin
    s= 3'b000;
    end
    
    always @(s)
        case (s)
          3'd0 : d = digits[3:0];
          3'd1 : d = digits[7:4];
          3'd2 : d = digits[11:8];
          3'd3 : d = digits[15:12];
          3'd4 : d = digits[19:16];
          3'd5 : d = digits[23:20];
          3'd6 : d = digits[27:24];
          3'd7 : d = digits[31:28];
       default:  d = 4'd0;
       endcase 
    always@(posedge clk)
        s<=s+1;
    decode38 dec(s, my_an);	 
    assign an=(en[s]==1'b1)?~my_an:8'hff;
    bcd7seg seg(d, hex);
endmodule

module decode38 (
    input [2:0] s,
    output reg [7:0] a
);
always @(s)
        case (s)
          3'b000 : a = 8'b00000001;
          3'b001 : a = 8'b00000010;
          3'b010 : a = 8'b00000100;
          3'b011 : a = 8'b00001000;
          3'b100 : a = 8'b00010000;
          3'b101 : a = 8'b00100000;
          3'b110 : a = 8'b01000000;
          3'b111 : a = 8'b10000000;
       default:  a = 8'b00000000;
       endcase 

endmodule

module bcd7seg(
	 input  [3:0] b,
	 output reg [7:0] h
	 );
    always @(*)
        case (b)
            4'b0000: h = 8'b11000000; //70H
            4'b0001: h = 8'b11111001; //79H
            4'b0010: h = 8'b10100100; //24H
            4'b0011: h = 8'b10110000; //30H
            4'b0100: h = 8'b10011001;
            4'b0101: h = 8'b10010010;
            4'b0110: h = 8'b10000010;
            4'b0111: h = 8'b11111000;
            4'b1000: h = 8'b10000000;
            4'b1001: h = 8'b10010000; //10H
            4'b1010: h = 8'b10001000;
            4'b1011: h = 8'b10000011;
            4'b1100: h = 8'b11000110;
            4'b1101: h = 8'b10100001;
            4'b1110: h = 8'b10000110;
            4'b1111: h = 8'b10001110;
       endcase 
endmodule