require 'rspec'
require './blackjack.rb'

include Blackjack

describe Card do

  let(:card1) { Card.new(:spades,:three) }
  let(:card2) { Card.new(:hearts, :queen) }
  let(:card3) { Card.new(:hearts, :ace) }

  it "returns its suit" do
    card1.suit.should be(:spades)
    card2.suit.should be(:hearts)
  end

  it "returns its value" do
    card1.value.should be(:three)
    card2.value.should be(:queen)
  end

  it "returns its Blackjack value" do
    card1.blackjack_value.should be(3)
  end

  it "raises an error if the card is an ace" do
    expect do
      card3.blackjack_value
    end.to raise_error("card is an ace")
  end

  it "has four possible suits" do
    Card.suits.count.should be(4)
  end

  it "has thirteen possible values" do
    Card.values.count.should be(13)
  end

end

describe Deck do
  subject(:deck) { Deck.new }

  it "has 52 cards" do
    deck.cards.count.should be(52)
  end

  it "has 52 unique cards" do
    deck.cards.uniq.count.should be(52)
  end

  it "can initialize with specified cards" do
    deck = Deck.new([Card.new(:hearts, :five), Card.new(:clubs, :eight)])

    deck.cards.count.should be(2)
  end

  describe "#take" do
    it "takes n cards from the deck" do
      cards = deck.take(2)
      cards.count.should be(2)
    end

    it "makes the deck smaller by n cards" do
      deck.take(5)
      deck.cards.count.should be(47)
    end

    it "takes cards from the top of the deck" do
      last_card = deck.cards.last
      deck.take(2).should include(last_card)
    end
  end

  describe "#return" do
    let(:taken_cards) { deck.take(2) }

    it "returns cards to the deck" do
      deck.return(taken_cards)
      deck.cards.count.should be(52)
    end

    it "returns cards to the bottom of the deck" do
      first_card = deck.cards.first
      deck.return(taken_cards)
      deck.cards.first.should_not be(first_card)
    end

  end

  describe "#shuffle" do
    it "shuffles the deck" do
      expect do
        deck.shuffle
      end.to change { deck.cards }
    end
  end

end

describe Hand do
  let(:deck) do Deck.new([
      Card.new(:hearts, :ace),
      Card.new(:spades, :ace)
    ])
  end

  let(:low_point_hand) do
      Hand.new([
          Card.new(:hearts, :three),
          Card.new(:spades, :six)
        ])
    end

  let(:high_point_hand) do
    Hand.new([
        Card.new(:hearts, :ten),
        Card.new(:spades, :queen)
      ])
  end

  let(:busted_hand1) do
    Hand.new([
        Card.new(:hearts, :ten),
        Card.new(:spades, :six),
        Card.new(:clubs, :eight)
      ])
  end

  let(:busted_hand2) do
    Hand.new([
        Card.new(:hearts, :ten),
        Card.new(:spades, :queen),
        Card.new(:clubs, :three)
      ])
  end

  describe "#hit" do
    it "adds one card to the hand" do
      low_point_hand.hit(deck)
      low_point_hand.cards.count.should be(3)
    end

    it "does not allow a hit if the hand is >= 21" do
      expect do
        busted_hand2.hit(deck)
      end.to raise_error("can't hit over 21")
    end
  end

  describe "#deal_from" do
    it "deals two cards from the deck to the hand" do
      hand = Hand.deal_from(deck)
      hand.cards.count.should be(2)
    end
  end

  describe "#points" do

    it "returns the hand's blackjack point value" do
      low_point_hand.points.should be(9)
      high_point_hand.points.should be(20)
    end

    it "counts ace as 11 by default" do
      hand = Hand.new([
          Card.new(:hearts, :ace),
          Card.new(:spades, :jack)
        ])
      hand.points.should be(21)
    end

    it "counts ace as 1 as necessary" do
      high_point_hand.hit(deck)
      high_point_hand.points.should be(21)
    end

  end

  describe "#busted?" do
    it "returns true if points in hand > 21" do
      busted_hand1.should be_busted
      busted_hand2.should be_busted
    end

    it "returns false if points in hand <= 21" do
      low_point_hand.should_not be_busted
      high_point_hand.hit(deck)
      high_point_hand.should_not be_busted
    end

  end

  describe "#beats?" do
    it "returns true if hand beats another hand" do
      high_point_hand.beats?(low_point_hand).should be_true
    end

    it "returns false if hand loses to another hand" do
      low_point_hand.beats?(high_point_hand).should be_false
    end

    it "does not let a busted hand win" do
      busted_hand1.beats?(low_point_hand).should be_false
      busted_hand1.beats?(busted_hand2).should be_false
    end

    it "allows a low point hand to beat a busted hand" do
      low_point_hand.beats?(busted_hand1).should be_true
    end

  end

end

describe Player do
  subject (:player) { Player.new("John Smith", 100_000) }

  its (:name) { should eq ("John Smith") }
  its (:bankroll) { should be (100_000) }

  describe "#place_bet" do
    let(:dealer) { double("dealer", :take_bet => nil) }

    it "registers bet with dealer" do
      dealer.should_receive(:take_bet).with(player, 10_000)

      player.place_bet(dealer, 10_000)
    end

    it "subtracts bet amount from player's bankroll" do
      player.place_bet(dealer, 10_000)
      player.bankroll.should be(90_000)
    end

    it "doesn't allow a player to bet beyond their bankroll" do
      expect do
        player.place_bet(dealer, 110_000)
      end.to raise_error "not nuff monies!"
    end
  end

  describe "#hand" do
    let(:deck) do
      double("deck", :cards => [
          {suit: :spades, value: :queen},
          {suit: :hearts, value: :five}
        ])
    end




  end



end


