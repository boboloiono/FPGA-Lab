module filter_3x3_240px
#(
    parameter BLOCK_LENGTH = 240,
    parameter FILTER_SIZE = 3,

    // Filter weights
    parameter WA3 = 0,
    parameter WB3 = -1,
    parameter WA1 = 4,
    parameter DIV = 1
)
(
    // System
    input reset,
    input clk,

    // IO
    input [15:0] d_in,
    output wire [15:0] d_out,

    // Control
    input wren,
    output wire d_rdy,
    input [9:0] cursor
);

    // Address and Write Enable for RAM
    reg [9:0] addr11, addr12, addr13;
    reg [9:0] addr21, addr22, addr23;
    reg [9:0] addr31, addr32, addr33;

    reg wren1, wren2, wren3;

    // RAM Outputs
    wire [15:0] q11, q12, q13;
    wire [15:0] q21, q22, q23;
    wire [15:0] q31, q32, q33;

    // RAM Instantiation
    ram ram11 (.address(addr11), .clock(clk), .data(d_in), .wren(wren1), .q(q11));
    ram ram12 (.address(addr12), .clock(clk), .data(d_in), .wren(wren1), .q(q12));
    ram ram13 (.address(addr13), .clock(clk), .data(d_in), .wren(wren1), .q(q13));
    ram ram21 (.address(addr21), .clock(clk), .data(d_in), .wren(wren2), .q(q21));
    ram ram22 (.address(addr22), .clock(clk), .data(d_in), .wren(wren2), .q(q22));
    ram ram23 (.address(addr23), .clock(clk), .data(d_in), .wren(wren2), .q(q23));
    ram ram31 (.address(addr31), .clock(clk), .data(d_in), .wren(wren3), .q(q31));
    ram ram32 (.address(addr32), .clock(clk), .data(d_in), .wren(wren3), .q(q32));
    ram ram33 (.address(addr33), .clock(clk), .data(d_in), .wren(wren3), .q(q33));

    // Write Address and Enable Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr11 <= 0; addr12 <= 0; addr13 <= 0;
            addr21 <= 0; addr22 <= 0; addr23 <= 0;
            addr31 <= 0; addr32 <= 0; addr33 <= 0;
            wren1 <= 0; wren2 <= 0; wren3 <= 0;
        end else if (wren) begin
            // Update RAM addresses
            addr11 <= cursor;
            addr12 <= cursor + 1;
            addr13 <= cursor + 2;

            addr21 <= cursor + BLOCK_LENGTH;
            addr22 <= cursor + BLOCK_LENGTH + 1;
            addr23 <= cursor + BLOCK_LENGTH + 2;

            addr31 <= cursor + 2 * BLOCK_LENGTH;
            addr32 <= cursor + 2 * BLOCK_LENGTH + 1;
            addr33 <= cursor + 2 * BLOCK_LENGTH + 2;

            // Enable write for all rows
            wren1 <= 1;
            wren2 <= 1;
            wren3 <= 1;
        end else begin
            wren1 <= 0;
            wren2 <= 0;
            wren3 <= 0;
        end
    end

    // Define 3x3 matrix of RGB weights
    wire [4:0] r00, r01, r02, r10, r11, r12, r20, r21, r22;
    wire [5:0] g00, g01, g02, g10, g11, g12, g20, g21, g22;
    wire [4:0] b00, b01, b02, b10, b11, b12, b20, b21, b22;

    assign {r00, g00, b00} = q11;
    assign {r01, g01, b01} = q12;
    assign {r02, g02, b02} = q13;
    assign {r10, g10, b10} = q21;
    assign {r11, g11, b11} = q22;
    assign {r12, g12, b12} = q23;
    assign {r20, g20, b20} = q31;
    assign {r21, g21, b21} = q32;
    assign {r22, g22, b22} = q33;

    // Filtered RGB
    wire [10:0] filtered_r, filtered_g, filtered_b;
    assign filtered_r = (r00 * WA3 + r01 * WB3 + r02 * WA3 +
                         r10 * WB3 + r11 * WA1 + r12 * WB3 +
                         r20 * WA3 + r21 * WB3 + r22 * WA3) / DIV;

    assign filtered_g = (g00 * WA3 + g01 * WB3 + g02 * WA3 +
                         g10 * WB3 + g11 * WA1 + g12 * WB3 +
                         g20 * WA3 + g21 * WB3 + g22 * WA3) / DIV;

    assign filtered_b = (b00 * WA3 + b01 * WB3 + b02 * WA3 +
                         b10 * WB3 + b11 * WA1 + b12 * WB3 +
                         b20 * WA3 + b21 * WB3 + b22 * WA3) / DIV;

    // RGB data after filtering
    wire [15:0] filtered_data;
    assign filtered_data[15:11] = filtered_r[4:0];
    assign filtered_data[10:5] = filtered_g[5:0];
    assign filtered_data[4:0] = filtered_b[4:0];

    // Output signals
    assign d_out = filtered_data;
    assign d_rdy = !wren && (cursor == addr11);
endmodule

/*module filter_3x3_240px
#(
    parameter BLOCK_LENGTH = 240,
    parameter FILTER_SIZE = 3,

    // weight of each pixel, change these parameters to make difference effect of filter
    // |WA3|WB3|WA3|
    // |WB3|WA1|WB3|
    // |WA3|WB3|WA3|
    parameter WA3 = 0,
    parameter WB3 = -1,
    parameter WA1 = 4,
    parameter DIV = 1

)
(
    // system
    input	reset,
    input	clk,

    // io
    input [15:0] d_in,
    output wire [15:0] d_out,

    // control
    input wren,
    output wire d_rdy,
    input [9:0] cursor
);
	
//To Do: filter the input image
//	- increase efficiency by eliminating redundancy
//	- read each clock cycle a new line of pixels (except for the first three rows, since you need three rows to start filtering (because of the 3x3 filter))
//	- keep the two already loaded lines for reuse
//	- if necessary use an additional pointer to keep track of your first input pixel of the image
//	- be aware that there could be timing issues:
//	- synchronize your internal pointer with the custom master pointer
//	- validate your design via SignalTap
		
	// 3 cursors delay, because of the ram required 3 clk cycle to output the data to 'q'
    reg [9:0] cursor1, cursor2, cursor3;

	reg [15:0] row0 [0:BLOCK_LENGTH-1];
	reg [15:0] row1 [0:BLOCK_LENGTH-1];
	reg [15:0] row2 [0:BLOCK_LENGTH-1];
	
    always @(posedge clk) begin
        if (reset) begin
            cursor1 <= 0;
            cursor2 <= 0;
            cursor3 <= 0;
        end else begin
            cursor1 <= cursor;
            cursor2 <= cursor1;
            cursor3 <= cursor2;
        end
    end
	
	// update reg, every time only one pixel is added to reg
    integer i;
    always @(posedge clk) begin
        if (wren) begin
            // each data moves up once
            for (i = 0; i < BLOCK_LENGTH-1; i = i + 1) begin
                row0[i] <= row0[i + 1];
                row1[i] <= row1[i + 1];
                row2[i] <= row2[i + 1];
            end
            row0[BLOCK_LENGTH-1] <= row1[0];
            row1[BLOCK_LENGTH-1] <= row2[0];
            row2[BLOCK_LENGTH-1] <= d_in;
        end
    end
			   
	// define 3x3 matrics of RGB weights
    wire [4:0] r00, r01, r02, r10, r11, r12, r20, r21, r22;
    wire [5:0] g00, g01, g02, g10, g11, g12, g20, g21, g22;
    wire [4:0] b00, b01, b02, b10, b11, b12, b20, b21, b22;

    assign {r00, g00, b00} = row0[cursor3];
    assign {r01, g01, b01} = row0[cursor3 + 1];
    assign {r02, g02, b02} = row0[cursor3 + 2];
    assign {r10, g10, b10} = row1[cursor3];
    assign {r11, g11, b11} = row1[cursor3 + 1];
    assign {r12, g12, b12} = row1[cursor3 + 2];
    assign {r20, g20, b20} = row2[cursor3];
    assign {r21, g21, b21} = row2[cursor3 + 1];
    assign {r22, g22, b22} = row2[cursor3 + 2];

	// filtered RGB
    wire [10:0] filtered_r, filtered_g, filtered_b;
    
    assign filtered_r = (r00 * WA3 + r01 * WB3 + r02 * WA3 +
                         r10 * WB3 + r11 * WA1 + r12 * WB3 +
                         r20 * WA3 + r21 * WB3 + r22 * WA3) / DIV;

    assign filtered_g = (g00 * WA3 + g01 * WB3 + g02 * WA3 +
                         g10 * WB3 + g11 * WA1 + g12 * WB3 +
                         g20 * WA3 + g21 * WB3 + g22 * WA3) / DIV;

    assign filtered_b = (b00 * WA3 + b01 * WB3 + b02 * WA3 +
                         b10 * WB3 + b11 * WA1 + b12 * WB3 +
                         b20 * WA3 + b21 * WB3 + b22 * WA3) / DIV;

    // RGB data after filtered
    wire [15:0] filtered_data;
    assign filtered_data[15:11] = filtered_r[4:0];
    assign filtered_data[10:5] = filtered_g[5:0];
    assign filtered_data[4:0] = filtered_b[4:0];

    // data ready signal for write_filter_tb
    assign d_out = filtered_data;
    assign d_rdy = (wren == 0) & ((cursor == cursor3));
	
endmodule
*/
