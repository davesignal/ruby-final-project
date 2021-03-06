require_relative "set"
require "colorize"
# Controls the layout of the board, and what piece lies where
class Board
  attr_reader :data, :white_set, :black_set, :black_king, :white_king

  def initialize
    @data = Hash.new
    @x_index = [nil,"a","b","c","d","e","f","g","h"]
    @sym_dict = {
      pawn: "P",
      knight: "N",
      rook: "R",
      bishop: "B",
      king: "K",
      queen: "Q",
    }
  end

  # Contructs a hash with 64 definitions to serve as the board
  def build_board
    8.times do |y|
      8.times do |x|
        @data[[x+1,y+1]] = { :proper_name => "#{@x_index[x+1]}#{y+1}"}
      end
    end
  end

  # Calls :build_set from ::Set to build the list of pieces, then assigns them
  def populate_board
    @white_set = Set.new(:white, self)
    @black_set = Set.new(:black, self)

    @white_set.build_set
    @black_set.build_set

    @white_set.data.each do |key, value|
      @data[key][:occupant] = value
      value.type == :king ? @white_king = value : nil
    end

    @black_set.data.each do |key, value|
      @data[key][:occupant] = value
      value.type == :king ? @black_king = value : nil
    end
  end

  # Generates all legal moves and captures for non-pawn/knight pieces
  # Calls appropriate methods for pawns and knights
  def generate_moves(curr_piece)
    # Pawns and knights get their own generate methods
    return generate_pawn_moves(curr_piece) if curr_piece.type == :pawn
    return generate_knight_moves(curr_piece) if curr_piece.type == :knight

    curr_piece.can_move_to.clear
    curr_piece.color == :white ? opposition = :black : opposition = :white
    curr_loc = curr_piece.owner.data.key(curr_piece)
    curr_piece.move_data.each do |k,v|
      v.each do |x|
        possible_move = [curr_loc[0] + x[0], curr_loc[1] + x[1]]
        next unless @data.keys.include?(possible_move)
        if @data[possible_move][:occupant] == nil
          curr_piece.can_move_to << possible_move
        elsif @data[possible_move][:occupant].color == opposition
          curr_piece.can_move_to << possible_move
          break
        else
          break
        end
      end
    end
  end

  # Facilitates pawn's 'has-not-moved' bonus movement
  def pawn_special_rules(curr_piece)
    if curr_piece.color == :white
      if curr_piece.has_moved == false
        curr_piece.move_data = {n: [[0,1],[0,2]]}
      else
        curr_piece.move_data = {n: [[0,1]]}
      end
    else
      if curr_piece.has_moved == false
        curr_piece.move_data = {n: [[0,-1],[0,-2]]}
      else
        curr_piece.move_data = {n: [[0,-1]]}
      end
    end
  end

  # Generates the list of legal moves and captures for a pawn
  def generate_pawn_moves(curr_piece)
    pawn_special_rules(curr_piece)

    curr_piece.color == :white ? opposition = :black : opposition = :white
    curr_loc = curr_piece.owner.data.key(curr_piece)
    curr_piece.can_move_to.clear

    # Generates the list of allowable moves
    curr_piece.move_data.each do |k,v|
      v.each do |x|
        possible_move = [curr_loc[0] + x[0], curr_loc[1] + x[1]]
        next unless @data.keys.include?(possible_move)
        if @data[possible_move][:occupant] == nil
          curr_piece.can_move_to << possible_move
        else
          break
        end
      end
    end

    # Pawns have unique capture behavior
    curr_piece.capture_data.each do |k,v|
      possible_cap = [curr_loc[0] + v[0], curr_loc[1] + v[1]]
      next unless @data.keys.include?(possible_cap)
      next if @data[possible_cap][:occupant] == nil
      if @data[possible_cap][:occupant].color == opposition
        curr_piece.can_move_to << possible_cap
      end
    end
  end

  # Generates the list of legal moves for a knight
  # Tis but a flesh wound
  def generate_knight_moves(curr_piece)
    curr_piece.can_move_to.clear
    curr_piece.color == :white ? opposition = :black : opposition = :white
    curr_loc = curr_piece.owner.data.key(curr_piece)
    curr_piece.move_data.each do |x|
      possible_move = [curr_loc[0] + x[0], curr_loc[1] + x[1]]
      next unless @data.keys.include?(possible_move)
      if @data[possible_move][:occupant] == nil
        curr_piece.can_move_to << possible_move
      elsif @data[possible_move][:occupant].color == opposition
        curr_piece.can_move_to << possible_move
      else
        next
      end
    end
  end

  # Ensures that the kings cannot move into check, as per rules of chess
  def king_move_list_cleanup
    @white_set.data.each do |k,v|
      next if v.nil?
      v.can_move_to.each do |x|
        @black_king.can_move_to.delete(x)
      end
    end
    @black_set.data.each do |k,v|
      next if v.nil?
      v.can_move_to.each do |x|
        @white_king.can_move_to.delete(x)
      end
    end
  end

  # Method for removing pieces, typically via capture
  def remove_piece(location)
    return "out of bounds" unless @data.keys.include?(location)
    @data[location][:occupant] == nil ? return : holder = @data[location][:occupant]

    @data[location][:occupant] = nil

    holder.owner.data.delete(location)
    holder.owner.captured << holder
  end

  # Method for moving pieces around the board, including to capture
  # Does not check whether a move is legal for the piece; that's in Chess.rb
  def move_piece(location, destination)
    # Does ensure the starting and ending locations are on the board
    return "out of bounds" unless @data.keys.include?(location) && @data.keys.include?(destination)
    # And if there's actually a piece there.
    return if @data[location][:occupant] == nil

    if @data[destination][:occupant] == nil
      # Empty destination
      @data[destination][:occupant] = @data[location][:occupant]
      @data[location][:occupant] = nil
      @data[destination][:occupant].owner.data.delete(location)
      @data[destination][:occupant].owner.data[destination] = @data[destination][:occupant]
    elsif @data[destination][:occupant].color == @data[location][:occupant].color
      # Ally occupied destination
      return false
    else
      # Enemy occupied destination
      remove_piece(destination)
      @data[destination][:occupant] = @data[location][:occupant]
      @data[location][:occupant] = nil
      @data[destination][:occupant].owner.data.delete(location)
      @data[destination][:occupant].owner.data[destination] = @data[destination][:occupant]
    end
  end

  # Prints the current state of the chess board.
  def print_board
    square = String.new
    line = String.new
    row_queue = Array.new
    row = 1

    @data.each_with_index do |(k,v), i|
      if v[:occupant] == nil
        square = "   "
      else
        v[:occupant].color == :white ? square = " #{@sym_dict[v[:occupant].type]} ".cyan : square = " #{@sym_dict[v[:occupant].type]} ".red
      end
      if row.modulo(2) == 0
        if i.modulo(2) == 0
          line << square.on_white
        else
          line << square.on_black
        end
      else
        if i.modulo(2) == 0
          line << square.on_black
        else
          line << square.on_white
        end
      end
      offset = i + 1
      if offset.modulo(8) == 0
        line = " #{row} " + line
        row_queue << line
        row += 1
        line = String.new
      end
    end
    row_queue.unshift("    A  B  C  D  E  F  G  H ")
    9.times do
      puts row_queue.pop
    end
  end
end
