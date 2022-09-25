# ---
# Excerpted from "Programming Ecto",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wmecto for more book information.
# ---
##############################################
## Ecto Playground
#
# This script sets up a sandbox for experimenting with Ecto. To
# use it, just add the code you want to try into the Playground.play/0
# function below, then execute the script via mix:
#
#   mix run priv/repo/playground.exs
#
# The return value of the play/0 function will be written to the console
#
# To get the test data back to its original state, just run:
#
#   mix ecto.reset
#
alias MusicDB.Repo
alias MusicDB.{Artist, Album, Track, Genre, Log, AlbumWithEmbeds, ArtistEmbed, TrackEmbed}
alias Ecto.Multi

import Ecto.Query
import Ecto.Changeset

defmodule Playground do
  alias MusicDB.Track

  # this is just to hide the "unused import" warnings while we play
  def this_hides_warnings do
    [Artist, Album, Track, Genre, Repo, Multi, Log, AlbumWithEmbeds, ArtistEmbed, TrackEmbed]
    from(a in "artists")
    from(a in "artists", where: a.id == 1)
    cast({%{}, %{}}, %{}, [])
  end

  def play do
    ###############################################
    #
    # PUT YOUR TEST CODE HERE
    #
    ##############################################

    #### intro
    # Repo.insert(%Artist{name: "New order"})
    artist_query = from("artists", select: [:id, :name, :inserted_at])
    IO.inspect(Repo.all(artist_query))

    ### writing queries with schemas
    #
    artist_id = "1"
    query = from("artists", where: [id: type(^artist_id, :integer)], select: [:id, :name])
    IO.inspect(Repo.all(query))

    #
    track_id = "1"
    tq = from(Track, where: [id: ^track_id])
    IO.inspect(Repo.all(tq))

    #
    tq2 = from(Track, where: [id: ^track_id], select: [:id, :title])
    IO.inspect(Repo.all(tq2))

    #
    tq3 = from(t in Track, where: t.id == ^track_id)
    IO.inspect(Repo.all(tq3))

    ## when NOT to use schemas (ie: reports?)
    rq =
      from(a in "artists",
        join: al in "albums",
        on: a.id == al.artist_id,
        group_by: a.name,
        select: %{artist: a.name, number_of_albums: count(al.id)}
      )

    IO.inspect(Repo.all(rq))

    ### inserting and deleting schemas
    # insert
    IO.inspect(Repo.insert_all("artists", [[name: "John Coltrane 01"]]))
    IO.inspect(Repo.insert(%Artist{name: "John Coltrane 11"}))
    IO.inspect(Repo.insert_all(Artist, [[name: "John Coltrane 21"]]))

    aq = from(Artist, select: [:id, :name])
    IO.inspect(Repo.all(aq))

    # delete
    IO.inspect(
      from(a in "artists", where: a.name == "John Coltrane 21")
      |> Repo.delete_all()
    )

    aq2 = Repo.get_by(Artist, name: "John Coltrane 11")
    IO.inspect(Repo.delete(aq2))

    IO.inspect(
      from(Artist, where: [name: "John Coltrane 01"])
      |> Repo.delete_all()
    )

    aq = from(Artist, select: [:id, :name])
    IO.inspect(Repo.all(aq))

    #### last statement; "done"
    IO.puts("done (ch3)")
  end
end

defmodule MusicDB.Track do
  use Ecto.Schema

  schema "tracks" do
    field(:title, :string)
    field(:duration, :integer)
    field(:index, :integer)
    field(:number_of_plays, :integer)
    timestamps()
  end
end

# add your test code to Playground.play above - this will execute it
# and write the result to the console
IO.inspect(Playground.play())
