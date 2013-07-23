require 'pry'

# Object Oriented Blackjack game

# 1) Abstraction
# 2) Encapsulation

class Card
  attr_accessor :suit, :face_value

  def initialize(s, fv)
    @suit = s
    @face_value = fv
  end

  def pretty_output
    "The #{face_value} of #{find_suit}"
  end

  def to_s
    pretty_output
  end

  def find_suit
    ret_val = case suit
                      when 'H' then 'Hearts'
                      when 'S' then 'Spades'
                      when 'D' then 'Diamonds'
                      when 'C' then 'Clubs'
                    end
      ret_val
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['H', 'D', 'S', 'C'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |face_value|
        @cards << Card.new(suit, face_value)
      end
    end
    scramble!
  end

  def scramble!
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end

  def size
    cards.size
  end
end

module Hand

  ACE_MAX = 11
  ACE_MIN = 10

  def show_hand
    puts "---- #{name}'s hand ----"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> Total: #{total}"
  end

    def total
    face_values = cards.map{|card| card.face_value }

    total = 0
    face_values.each do |val|
      if val == "A"
        total += ACE_MAX
      else
        total += (val.to_i == 0 ? ACE_MIN : val.to_i)
      end
    end

    #correct for Aces
    face_values.select{|val| val == "A"}.count.times do
      break if total <= Blackjack::BLACKJACK_AMOUNT
      total -= ACE_MIN
    end

    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end

end

class Player
  include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    @cards = []
  end

  def show_flop
    show_hand
  end
end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "dealer"
    @cards = []
  end

  def show_flop
    puts "---- Dealer's hand ----"
    puts "=> first card is hidden"
    puts "=> second card is #{cards[1]}"
  end

end

class Blackjack
  attr_accessor  :deck, :player, :dealer

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new("player 1")
    @dealer = Dealer.new
  end

  def set_player_name
    puts "what's your name?"
    player.name = gets.chomp
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end

  def show_flop
    player.show_flop
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "dealer hit blackjack. #{player.name} loses"
      else
        puts "congrats, #{player.name} hit blackjack and wins! "
      end
      exit
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "congrats, dealer busted. #{player.name} wins!"
      else
        puts "#{player.name} busted. dealer wins"
      end
      exit
    end
  end

  def player_turn
    puts "#{player.name}'s turn"

    blackjack_or_bust?(player)

    while !player.is_busted?
      puts "what would you like to do?  (1) hit  or (2) stay"
      response = gets.chomp

      if !['1', '2'].include?(response)
        puts "error: please enter 1 or 2"
        next
      end

      # stay
      if response == '2'
        puts "#{player.name} chose to stay at #{player.total}"
        break
      end

      # hit
      new_card = deck.deal_one
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now: #{player.total}"

      blackjack_or_bust?(player)
    end
#    puts "#{player.name} stays at #{player.total}"
  end

  def dealer_turn
    puts "dealer's turn"

    blackjack_or_bust?(dealer)

    while dealer.total < DEALER_HIT_MIN
      new_card = deck.deal_one
      puts "dealing card to dealer: #{new_card}"
      dealer.add_card(new_card)
      puts "dealer's total is now: #{dealer.total}"

      blackjack_or_bust?(dealer)
    end
    puts "dealer stays at #{dealer.total}"
  end

  def who_won?
    if dealer.total > player.total
      puts "dealer won .. #{player.name} loses!"
    elsif dealer.total < player.total
      puts "#{player.name} wins!"
    else
      puts "its a tie!"
    end
  end

  def start
    set_player_name
    deal_cards
    show_flop
    player_turn
    dealer_turn
    who_won?
  end
end

game = Blackjack.new
game.start
