defmodule Cards do
  @moduledoc """
  Documentation for `Cards`.

  Provides methods for cereating and/or handeling a deck of cards. 
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cards.hello()
      :world

  """
  def hello do
    :world
  end

  def hello2 do
    "Hi!"
  end

  @doc """
  Returns a list of strings representing a deck of playing cards

  ## Examples

      iex> _deck = Cards.create_deck()
      ["ace of hearts", "king of hearts", "queen of hearts",
       "jack of hearts", "ten of hearts", "nine of hearts",
       "eight of hearts", "seven of hearts", "ace of diamonds",
       "king of diamonds", "queen of diamonds", "jack of diamonds",
       "ten of diamonds", "nine of diamonds", "eight of diamonds",
       "seven of diamonds", "ace of spades", "king of spades",
       "queen of spades", "jack of spades", "ten of spades",
       "nine of spades", "eight of spades", "seven of spades",
       "ace of clubs", "king of clubs", "queen of clubs", "jack of clubs",
       "ten of clubs", "nine of clubs", "eight of clubs",
       "seven of clubs"]

  """
  def create_deck do
    values = ["ace", "king", "queen", "jack", "ten", "nine", "eight", "seven"]
    suits = ["hearts", "diamonds", "spades", "clubs"]

    for suit <- suits, value <- values do
      "#{value} of #{suit}"
    end
  end

  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  @doc """
  Determine is a deck of cards `contains` this card.

  ## Examples

      iex> deck = Cards.create_deck
      iex> {some_hand, _rest} = Cards.deal(deck, 2)
      iex> [head | tail] = some_hand
      iex> Cards.contains?(deck, head)
      true
      iex> Cards.contains?(tail, head)
      false

  """
  def contains?(deck, card) do
    # card in deck
    Enum.member?(deck, card)
  end

  @doc """
  Divides a deck into a hand and the remainder (aka rest) of the deck.
  The (hand) `size` argument indicates how many cards should
  be in the hand.

  ## Examples

      iex> deck = Cards.create_deck
      iex> {some_cards, _rest} = Cards.deal deck, 4
      iex> [head | rest] = some_cards
      iex> head
      "ace of hearts"
      iex> length(rest)
      3

  """
  def deal(deck, size) do
    Enum.split(deck, size)
  end

  def save(deck, filename) do
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary)
  end

  def load(filename) do
    # {status, binary } = File.read(filename)
    case File.read(filename) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, reason} -> "read failed; #{reason}"
    end
  end

  def create_hand(hand_size) do
    Cards.create_deck()
    |> Cards.shuffle()
    |> deal(hand_size)
  end
end
