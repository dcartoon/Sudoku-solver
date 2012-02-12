$LOAD_PATH << File.dirname(__FILE__)

require 'solver'
require 'test/unit'

class TestSolver < Test::Unit::TestCase
  def setup
    @board_text = 
"+-------+-------+-------+
| _ 6 _ | 1 _ 4 | _ 5 _ | 
| _ _ 8 | 3 _ 5 | 6 _ _ | 
| 2 _ _ | _ _ _ | _ _ 1 | 
+-------+-------+-------+
| 8 _ _ | 4 _ 7 | _ _ 6 | 
| _ _ 6 | _ _ _ | 3 _ _ | 
| 7 _ _ | 9 _ 1 | _ _ 4 | 
+-------+-------+-------+
| 5 _ _ | _ _ _ | _ _ 2 | 
| _ _ 7 | 2 _ 6 | 9 _ _ | 
| _ 4 _ | 5 _ 8 | _ 7 _ | 
+-------+-------+-------+"
    lines = @board_text.split("\n")
    @parsed_board = parse_board(lines)
  end

  def teardown
  end

  def test_parse_line
    line = "| _ 4 _ | 5 _ 8 | _ 7 _ | "
    parsed_line = parse_line(line)
    
    assert_equal 9, parsed_line.length
    assert_equal ["_", 4, "_", 5, "_", 8, "_", 7, "_"], parsed_line
  end
  
  def test_parse_board
    assert_equal 9, @parsed_board.length
    assert_equal ["_", 4, "_", 5, "_", 8, "_", 7, "_"], @parsed_board[8]
  end

  def test_get_array_possibilities
    array =  ["_", 4, "_", 5, "_", 8, "_", 7, "_"]
    possibilities = get_array_possibilities(array)
    assert_equal [1, 2, 3, 6, 9], possibilities
  end

  def test_get_row_possibilities
    possibilities = get_row_possibilities(@parsed_board, 0)
    assert_equal [2, 3, 7, 8, 9], possibilities                                     
  end

  def test_get_column
    column = get_column(@parsed_board, 0)
    assert_equal ["_", "_", 2, 8, "_", 7, 5, "_", "_"], column
  end

  def test_get_column_possibilities
    possibilities = get_column_possibilities(@parsed_board, 0)
    assert_equal [1, 3, 4, 6, 9], possibilities
  end

  def test_get_groupings
    result = get_groupings(0, 0)
    assert_equal [0, 1, 2], result[:row_group]
    assert_equal [0, 1, 2], result[:col_group]

    result = get_groupings(3, 0)
    assert_equal [3, 4, 5], result[:row_group]
    assert_equal [0, 1, 2], result[:col_group]
  end

  def test_get_group_cells
    cells = get_group_cells(@parsed_board, 0, 0)
    assert_equal 9, cells.length
    assert_equal ["_", 6, "_", "_", "_", 8, 2, "_", "_"], cells
  end

  def test_get_group_possibilities
    possibilities = get_group_possibilities(@parsed_board, 0, 0)
    assert_equal [1, 3, 4, 5, 7, 9], possibilities

    possibilities = get_group_possibilities(@parsed_board, 8, 8)
    assert_equal [1, 3, 4, 5, 6, 8], possibilities
  end

  def test_get_cell_possibilities
    possibilities = get_cell_possibilities(@parsed_board, 0, 0)
    assert_equal [3, 9], possibilities
    
    possibilities = get_cell_possibilities(@parsed_board, 4, 4)
    assert_equal [2, 5, 8], possibilities
  end

  def test_get_first_unfilled_cell
    assert_equal({ :row_num => 0, :col_num => 0}, get_first_unfilled_cell(@parsed_board))

    assert_equal(nil, get_first_unfilled_cell([[1],[2],[3]]))
  end

  def test_solve_mostly_filled_board
    board_text = 
"+-------+-------+-------+
| 9 6 3 | 1 7 4 | 2 5 8 |
| 1 7 8 | 3 2 5 | 6 4 9 |
| 2 5 4 | 6 8 9 | 7 3 1 |
+-------+-------+-------+
| 8 2 1 | 4 3 7 | 5 9 6 |
| 4 9 6 | 8 5 2 | 3 1 7 |
| 7 3 5 | 9 6 1 | 8 2 4 |
+-------+-------+-------+
| 5 8 9 | 7 1 3 | 4 6 2 |
| 3 1 7 | 2 4 6 | 9 8 5 |
| 6 4 2 | 5 9 8 | 1 7 _ |
+-------+-------+-------+"
    lines = board_text.split("\n")
    parsed_board = parse_board(lines)
    assert solve_board(parsed_board)
  end

  def test_solve_filled_board
    board_text = 
"+-------+-------+-------+
| 9 6 3 | 1 7 4 | 2 5 8 |
| 1 7 8 | 3 2 5 | 6 4 9 |
| 2 5 4 | 6 8 9 | 7 3 1 |
+-------+-------+-------+
| 8 2 1 | 4 3 7 | 5 9 6 |
| 4 9 6 | 8 5 2 | 3 1 7 |
| 7 3 5 | 9 6 1 | 8 2 4 |
+-------+-------+-------+
| 5 8 9 | 7 1 3 | 4 6 2 |
| 3 1 7 | 2 4 6 | 9 8 5 |
| 6 4 2 | 5 9 8 | 1 7 3 |
+-------+-------+-------+"
    lines = board_text.split("\n")
    parsed_board = parse_board(lines)
    assert solve_board(parsed_board)
  end

  def test_solve_invalid_board
        board_text = 
"+-------+-------+-------+
| 9 6 3 | 1 7 4 | 2 5 8 |
| 1 7 8 | 3 2 5 | 6 4 9 |
| 2 5 4 | 6 8 9 | 7 3 1 |
+-------+-------+-------+
| 8 2 1 | 4 3 7 | 5 9 6 |
| 4 9 6 | 8 5 2 | 3 1 7 |
| 7 3 5 | 9 6 1 | 8 2 4 |
+-------+-------+-------+
| 5 8 9 | 7 1 3 | 4 6 2 |
| 3 1 7 | 2 4 6 | 9 8 5 |
| 6 4 2 | 5 9 8 | 1 3 _ |
+-------+-------+-------+"
    lines = board_text.split("\n")
    parsed_board = parse_board(lines)
    assert_equal(nil, solve_board(parsed_board))
  end
end
