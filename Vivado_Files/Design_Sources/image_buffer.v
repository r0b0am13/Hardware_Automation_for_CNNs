`timescale 1ns / 1ps

module image_buffer #(KERNEL_SIZE=3,DATA_SIZE = 8,ROW_SIZE = 28)(clock, pixel_data_in,convol_out,out_valid,data_in_valid);

localparam counter_size = $clog2(ROW_SIZE*(KERNEL_SIZE-1)+KERNEL_SIZE+1);
input clock,data_in_valid;
input [DATA_SIZE-1:0] pixel_data_in;
output wire [KERNEL_SIZE*KERNEL_SIZE*DATA_SIZE-1:0] convol_out;
output reg out_valid;

wire [DATA_SIZE-1:0] lb_out [0:KERNEL_SIZE-2];
wire [KERNEL_SIZE*DATA_SIZE-1:0] conv_out [0:KERNEL_SIZE-1];

reg [counter_size-1:0] counter = 0;

genvar i;
generate
    for(i=0;i<KERNEL_SIZE;i=i+1) begin
    if(i==0) begin
        line_buffer #(KERNEL_SIZE,DATA_SIZE,ROW_SIZE) lb (.clock(clock),.data_valid(data_in_valid),.pixel_in(pixel_data_in),.pixel_out(lb_out[i]),.conv_row_out(conv_out[i]));
        end
    else if(i==(KERNEL_SIZE-1)) begin
        line_buffer #(KERNEL_SIZE,DATA_SIZE,ROW_SIZE) lb (.clock(clock),.data_valid(data_in_valid),.pixel_in(lb_out[i-1]),.pixel_out(),.conv_row_out(conv_out[i]));
        end
    else begin
        line_buffer #(KERNEL_SIZE,DATA_SIZE,ROW_SIZE) lb (.clock(clock),.data_valid(data_in_valid),.pixel_in(lb_out[i-1]),.pixel_out(lb_out[i]),.conv_row_out(conv_out[i]));
        end
    end
    
    for(i=0;i<KERNEL_SIZE;i=i+1) begin
        assign convol_out[(i+1)*DATA_SIZE*KERNEL_SIZE-1:i*DATA_SIZE*KERNEL_SIZE] = conv_out[KERNEL_SIZE-i-1];
    end

endgenerate


always @(posedge clock) begin
    if (!data_in_valid) begin
        counter <= 0;
        out_valid <=0;
        end
    else begin 
        if (counter == ROW_SIZE*(KERNEL_SIZE-1)+KERNEL_SIZE - 1)
            out_valid <=1;
        else
            counter <= counter + 1;
    end
end
endmodule



