# -*- coding: utf-8 -*-
module Blackjack

  class Card
    SUIT_STRINGS = {
      :clubs    => "♣",
      :diamonds => "♦",
      :hearts   => "♥",
      :spades   => "♠"
    }

    VALUE_STRINGS = {
      :deuce => "2",
      :three => "3",
      :four  => "4",
      :five  => "5",
      :six   => "6",
      :seven => "7",
      :eight => "8",
      :nine  => "9",
      :ten   => "10",
      :jack  => "J",
      :queen => "Q",
      :king  => "K",
      :ace   => "A"
    }

    BLACKJACK_VALUE = {
      :deuce => 2,
      :three => 3,
      :four  => 4,
      :five  => 5,
      :six   => 6,
      :seven => 7,
      :eight => 8,
      :nine  => 9,
      :ten   => 10,
      :jack  => 10,
      :queen => 10,
      :king  => 10
    }

    def self.suits
      SUIT_STRINGS.keys
    end

    def self.values
      VALUE_STRINGS.keys
    end

    attr_accessor :suit, :value

    def initialize(suit, value)
      @suit, @value = suit, value
    end

    def blackjack_value
      raise "card is an ace" if @value == :ace

      BLACKJACK_VALUE[@value]
    end

  end

  class Deck

    def self.all_cards
      Card.suits.product(Card.values).map { |suit, value| Card.new(suit, value) }
    end

    attr_accessor :cards

    def initialize(cards=Deck.all_cards)
      @cards = cards
    end

    def take(n)
      taken_cards = []
      n.times do
        taken_cards << @cards.pop
      end
      taken_cards
    end

    def return(cards)
      @cards.unshift(*cards)
    end

    def shuffle
      @cards.shuffle!
    end

  end

  class Hand

    def self.deal_from(deck)
      Hand.new(deck.take(2))
    end


    attr_accessor :cards

    def initialize(cards)
      @cards = cards
    end

    def hit(deck)
      raise "can't hit over 21" if points >= 21
      @cards += deck.take(1)
    end

    def points
      ace_count = 0
      points = 0

      @cards.each do |card|
        if card.value == :ace
          ace_count += 1
          points += 11
        else
          points += card.blackjack_value
        end
      end

      points -= 10 until points <= 21 || ace_count == 0
      points
    end

    def busted?
      points > 21
    end

    def beats?(other_hand)
      if busted?
        return false
      elsif !busted? && other_hand.busted?
        return true
      else
        return points > other_hand.points
      end
    end

  end

  class Player

    attr_accessor :name, :bankroll, :hand

    def initialize(name, bankroll)
      @name, @bankroll = name, bankroll
      @hand = hand
    end

    def place_bet(dealer, amount)
      raise "not nuff monies!" if amount > @bankroll
      dealer.take_bet(self, amount)
      @bankroll -= amount
    end
  end


end