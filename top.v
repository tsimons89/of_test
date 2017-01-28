`timescale 1ns / 1ps

module top(
    //Clock
    input sys_clk_p,
    input sys_clk_n,
    //VGA
    output [4:0] vga_pRed,
    output [4:0] vga_pBlue,
    output [5:0] vga_pGreen,
    output vga_pHSync,
    output vga_pVSync,
    //For testing
    input [7:0] sw
);
    parameter NUM_FRAMES = 7;
    parameter NUM_DERIVATIVE_FRAMES = 3;
    parameter OF_CALC_WIDTH = 12;
    parameter PIXEL_WIDTH = 8;
    parameter IMAGE_HEIGHT = 252;
    parameter IMAGE_WIDTH = 316;
    parameter VID_IN_DATA_WIDTH = 24;
    parameter kRedDepth = 5;
    parameter kGreenDepth = 6;
    parameter kBlueDepth = 5;
    

    wire [23:0] rgb_pData;
    reg [23:0] rgb_pData_reg;
    wire vid_pVDE;
    wire HS_out;
    wire VS_out;
    wire [3:0] cur_frame;
    wire PixelClk;
    wire [PIXEL_WIDTH - 1:0] pixel_in;
    wire [PIXEL_WIDTH*NUM_FRAMES - 1:0] pixels_out;
    
    wire [OF_CALC_WIDTH - 1:0] vx,vy;
    reg  [OF_CALC_WIDTH - 1:0] vx_reg,vy_reg;
    wire [PIXEL_WIDTH - 1:0] frame0,frame1,frame2,frame3,frame4,frame5,frame6;
    wire [16:0] pix_addr = pixel_x + pixel_y*IMAGE_WIDTH;
    wire [9:0] pixel_x,pixel_y;

  clk_wiz_0 pix_clk_div
   (
    .clk_in1_p(sys_clk_p),    // input clk_in1_p
    .clk_in1_n(sys_clk_n),    // input clk_in1_n
    .clk_out1(PixelClk));    // output clk_out1 25MHz
    
    
    vga_timing my_timing(PixelClk,pixel_x,pixel_y,vid_pVDE,vga_pHSync,vga_pVSync);
    
    frame0 my_f0 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame0)  // output wire [7 : 0] douta
    );
    frame1 my_f1 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame1)  // output wire [7 : 0] douta
    );
    frame2 my_f2 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame2)  // output wire [7 : 0] douta
    );
    frame3 my_f3 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame3)  // output wire [7 : 0] douta
    );
    frame4 my_f4 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame4)  // output wire [7 : 0] douta
    );
    frame5 my_f5 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame5)  // output wire [7 : 0] douta
    );
    frame6 my_f6 (
      .clka(PixelClk),    // input wire clka
      .ena(1'b1),      // input wire ena
      .addra(pix_addr),  // input wire [16 : 0] addra
      .douta(frame6)  // output wire [7 : 0] douta 
    );
    assign pixels_out = (pixel_x < IMAGE_WIDTH && pixel_y < IMAGE_HEIGHT)?{frame0,frame1,frame2,frame3,frame4,frame5,frame6}:0;
    assign pixel_in = (pixel_x >= IMAGE_WIDTH || pixel_y >= IMAGE_HEIGHT)?0:
                      (sw == 0)?frame0:
                      (sw == 1)?frame1:
                      (sw == 2)?frame2:
                      (sw == 3)?frame3:
                      (sw == 4)?frame4:
                      (sw == 5)?frame5:frame6;
    
    optical_flow_calc my_OF_calc(PixelClk,vid_pVDE,pixels_out,vx,vy);
    
    optical_flow_display my_display(PixelClk,pixel_in,vx_reg,vy_reg,vid_pVDE,vga_pHSync,vga_pVSync,rgb_pData,pixel_x,pixel_y);    
    
    always @(posedge PixelClk) begin
        vx_reg <= vx;
        vy_reg <= vy;
        rgb_pData_reg <= rgb_pData;
    end
                    
    assign vga_pRed = rgb_pData_reg[VID_IN_DATA_WIDTH-1 -: kRedDepth];
    assign vga_pBlue = rgb_pData_reg[VID_IN_DATA_WIDTH/3*2-1 -: kBlueDepth];
    assign vga_pGreen = rgb_pData_reg[VID_IN_DATA_WIDTH/3-1 -: kGreenDepth]; 

  
endmodule
