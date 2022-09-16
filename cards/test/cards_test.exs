defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "greets the world" do
    assert Cards.hello() == :world
  end

  test "create_deck; makes a 32 deck of cards" do
	  deck_size = length(Cards.create_deck)
	  assert deck_size == 32
  end

  test "" do
    deck = Cards.create_deck()
    shuffled = Cards.shuffle(deck)
    refute deck == shuffled
  end
end
