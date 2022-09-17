defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello()
      :world

  """
  def hello do
    :world
  end

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> create_grid
    |> filter_odd_squares
    |> create_pixel_map
    |> create_image
    |> save_image(input)
  end

  def hash_input(input) do
    #hashed = :crypto.hash(:md5, input)
    #Base.encode16(hashed)
    #:binary.bin_to_list hashed
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{name: input, hex: hex}
  end

  def pick_color(image) do
    #%Identicon.Image{hex: hex_list} = image
    #[r, g, b | _rest] = hex_list
    %Identicon.Image{hex: [r, g, b | _rest]} = image
    colors = {r, g, b}

#    %Identicon.Image{hex: image.hex, colors: colors}
    %Identicon.Image{image| colors: colors}
  end

  def create_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
        |> Enum.chunk_every(3, 3, :discard)
        |> Enum.map(&mirror_row/1)
        |> List.flatten
        |> Enum.with_index

    %Identicon.Image{image| grid: grid}
  end

  def mirror_row([f, n | _tail] = row) do
    row ++ [n, f]
  end

  def mirror_row_tbh(row) do
    [f, n, l] = row
    [f, n, l, n, f]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    even_grid = Enum.filter grid, fn({value, _index}) ->
      rem(value, 2) == 0
    end

    %Identicon.Image{image| even_grid: even_grid}
  end

  def create_pixel_map(%Identicon.Image{even_grid: grid } = image) do
    pixels = Enum.map grid, fn({_val, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image| pixel_map: pixels}
  end

  def create_image(image) do
    %Identicon.Image{colors: colors, pixel_map: pixels} = image
    egd_image = :egd.create(250, 250)
    fill = :egd.color(colors)
    Enum.each pixels, fn({start, stop}) ->
      :egd.filledRectangle egd_image, start, stop, fill
    end
    :egd.render(egd_image)
  end

  def save_image(png_image, filename) do
    File.write "#{filename}.png", png_image
  end

end
