module Core (
    clk,
    rst,
    in_data,
    next_matrix,
    can_read,
    can_cao,
    row_counter,
    col_counter,
    out_data,
    is_legal,
    change_row,
    valid,
    done_cao
);

    input clk;
    input rst;
    input [7:0] in_data;
    input next_matrix;
    input can_read;
    input can_cao;
    input [1:0] row_counter;
    input [1:0] col_counter;

    output reg signed [19:0] out_data;
    output reg is_legal;
    output reg change_row;
    output reg valid;
    output reg done_cao;

    reg done_rst = 0;

    reg signed [7:0] matrix_a [3:0][3:0];
    reg [1:0] matrix_a_row;
    reg [1:0] matrix_a_col;
    reg signed [7:0] matrix_b [3:0][3:0];
    reg [1:0] matrix_b_row;
    reg [1:0] matrix_b_col;
    reg signed [19:0] result;

    reg [1:0] current_row;
    reg [1:0] current_col;

    reg [1:0] change_row_counter;

    reg do_rst;

    integer i;
    integer j;

    always @(posedge clk) begin
        if ((rst && !done_rst) || do_rst) begin
            out_data <= 0;
            is_legal <= 0;
            change_row <= 0;
            valid <= 0;
            done_cao <= 0;

            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    matrix_a[i][j] <= 0;
                    matrix_b[i][j] <= 0;
                end
            end

            matrix_a_row <= 0;
            matrix_a_col <= 0;
            matrix_b_row <= 0;
            matrix_b_col <= 0;
            result <= 0;

            current_row <= 0;
            current_col <= 0;

            done_rst <= 1;

            change_row_counter <= 0;

            do_rst <= 0;
        end else if ((!rst && done_rst) && !do_rst) begin
            if (can_read) begin
                if (next_matrix) begin
                    matrix_b_row <= row_counter;
                    matrix_b_col <= col_counter;

                    matrix_b[row_counter][col_counter] <= in_data;
                end else begin
                    matrix_a_row <= row_counter;
                    matrix_a_col <= col_counter;

                    matrix_a[row_counter][col_counter] <= in_data;
                end
            end else if (can_cao) begin
                result = 0;

                if (matrix_a_col != matrix_b_row) begin
                    is_legal <= 0;
                end else begin
                    for (i = 0; i <= matrix_a_col; i = i + 1) begin
                        result = result + matrix_a[current_row][i] * matrix_b[i][current_col];
                    end

                    if (current_col == matrix_b_col) begin
                        current_col = 0;
                        current_row = current_row + 1;

                        change_row <= 1;
                        change_row_counter = change_row_counter + 1;
                    end else begin
                        current_col = current_col + 1;
                    end

                    is_legal <= 1;
                end

                out_data = result;
                valid <= 1;

                if ((change_row_counter > matrix_a_row) || matrix_a_col != matrix_b_row) begin
                    done_cao <= 1;
                    do_rst <= 1;
                end
            end
        end
    end

    always @(negedge clk) begin
        if (is_legal) begin
            is_legal <= 0;
        end

        if (change_row) begin
            change_row <= 0;
        end

        if (valid) begin
            valid <= 0;
        end
    end

endmodule
