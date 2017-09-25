require_relative "board.rb"
class Chess
  attr_reader :gameboard, :current_turn

  def initialize
    @gameboard = Board.new
    @current_turn = :new_game

  end

  def title_screen
    puts "Welcome to Chess!"
    valid_in = false

    while valid_in == false
      puts "[N]ew Game, or [C]ontinue?"
      u_input = gets.chomp.downcase
      if u_input == "c"
        puts "Save/Continue functionality not yet implemented."
      else
        puts "New game!"
        valid_in = true
      end
    end

    if u_input == "c"
      # Insert call to :load_game here
    else
      end_of_turn
    end
  end

  def save_game
    save_state = {
      board_state: @gameboard,
      curr_player: @current_turn
    }

    File.open("saved_game.yml", "w") {|f| f.write(write_game.to_yaml)}
  end

  def load_game
    return false unless File.exists?("saved_game.yml")
    load_state = YAML.load(File.open("saved_game.yml"))

    @gameboard = load_state[:board_state]
    @current_turn = load_state[:curr_player]
  end

  def translate(u_input)
    x_index = ["INVALID","a","b","c","d","e","f","g","h"]
    translated_coords = Array.new
    translated_coords[0] = x_index.find_index(u_input[0])
    translated_coords[1] = u_input[1].to_i
    return false unless @gameboard.data.keys.include?(translated_coords)
    return translated_coords
  end

  def end_of_turn
    if @current_turn == :new_game
      @gameboard.build_board
      @gameboard.populate_board
    end

    @gameboard.white_set.data.each_value {|piece| @gameboard.generate_moves(piece)}
    @gameboard.black_set.data.each_value {|piece| @gameboard.generate_moves(piece)}
    @gameboard.king_move_list_cleanup

    @current_turn == :white ? @current_turn = :black : @current_turn = :white
  end
end
