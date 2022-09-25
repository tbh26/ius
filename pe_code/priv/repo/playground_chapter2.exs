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
#   mix run priv/repo/playground_chapter2.exs
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
  # this is just to hide the "unused import" warnings while we play
  def this_hides_warnings do
    [Artist, Album, Track, Genre, Repo, Multi, Log, AlbumWithEmbeds, ArtistEmbed, TrackEmbed]
    from(a in "artists")
    from(a in "artists", where: a.id == 1)
    cast({%{}, %{}}, %{}, [])
  end

  defmacro lower(arg) do
    quote do: fragment(lower("lower(?)", unquote(arg)))
  end

  def album_by_artist(artist_name) do
    from(a in "albums",
      join: ar in "artists",
      on: a.artist_id == ar.id,
      where: ar.name == ^artist_name
    )
  end

  def title_only(query) do
    from(a in query, select: a.title)
  end

  def by_artist(query, artist_name) do
    from(a in query,
      join: ar in "artists",
      on: a.artist_id == ar.id,
      where: ar.name == ^artist_name
    )
  end

  def with_tracks_longer_than(query, duration) do
    from(a in query,
      join: t in "tracks",
      on: a.id == t.album_id,
      where: t.duration > ^duration,
      distinct: true
    )
  end

  def play do
    ###############################################
    #
    # PUT YOUR TEST CODE HERE
    #
    ##############################################

    ## first steps
    new_order = "New order"
    # Repo.insert(%Artist{name: new_order})
    # retrieve the record
    no = Repo.get_by(Artist, name: new_order)
    IO.inspect(no)

    ##
    # MusicDB.Repo.aggregate("artists", :count, :name)

    ### Chapter II, Querying your database
    ## basic query
    # query = from "artists", select: [:name]
    query = Ecto.Query.from("artists", select: [:name])
    # Ecto.Adapters.SQL.to_sql(:all, Repo, query)
    # Repo.to_sql(:all, query)
    IO.inspect(Repo.all(query))

    ### use "where" and protect against sql injection (notice: ^)
    # query = from "artists", select: [:id, :name]
    # query = from "artists", where: [name: "Bill Evans"], select: [:id, :name]
    artist_name = "Bill Evans"
    query = from("artists", where: [name: ^artist_name], select: [:id, :name])
    IO.inspect(Repo.all(query))

    ### dynamic values / types
    # artist_id = 1
    # query = from "artists", where: [id: ^artist_id], select: [:id, :name]
    artist_id = "1"
    query = from("artists", where: [id: type(^artist_id, :integer)], select: [:id, :name])
    IO.inspect(Repo.all(query))

    ### query bindings
    query = from(a in "artists", where: a.name == ^"Bill Evans", select: [:id, :name])
    IO.inspect(Repo.all(query))

    ### query expression
    # like
    like_query = from(a in "artists", where: like(a.name, ^"Bill%"), select: [:id, :name])
    IO.inspect(Repo.all(like_query))
    # nil / not nil
    nil_query = from(a in "artists", where: is_nil(a.birth_date), select: [:id, :name])
    IO.inspect(Repo.all(nil_query))
    not_nil_query = from(a in "artists", where: not is_nil(a.name), select: [:id, :name])
    IO.inspect(Repo.all(not_nil_query))
    # date comparison
    date_query =
      from(a in "artists", where: a.inserted_at < ago(15, "hour"), select: [:id, :name])

    IO.inspect(Repo.all(date_query))

    ### raw sql
    rq =
      from(a in "artists",
        where: fragment("lower(?)", a.name) == "miles david",
        select: [:id, :name]
      )

    IO.inspect(Ecto.Adapters.SQL.to_sql(:all, Repo, rq))
    # rq = from(a in "artists", where: lower(a.name) == "miles david", select: [:id, :name])
    # IO.inspect(Ecto.Adapters.SQL.to_sql(:all, Repo, rq))

    ### union(s)
    tracks_query = from(t in "tracks", select: t.title)
    union_query = from(a in "albums", select: a.title, union: ^tracks_query)
    IO.inspect(Repo.all(union_query))
    tracks_query = from(t in "tracks", select: t.title)
    all_query = from(a in "albums", select: a.title, union_all: ^tracks_query)
    IO.inspect(Repo.all(all_query))
    #
    tracks_query = from(t in "tracks", select: t.title)
    intersect_query = from(a in "albums", select: a.title, intersect: ^tracks_query)
    IO.inspect(Repo.all(intersect_query))
    tracks_query = from(t in "tracks", select: t.title)
    except_query = from(a in "albums", select: a.title, except: ^tracks_query)
    IO.inspect(Repo.all(except_query))

    ### Ordering and Grouping
    oq = from(a in "artists", select: [:name], order_by: a.name)
    IO.inspect(Repo.all(oq))
    doq = from(a in "artists", select: [:name], order_by: [desc: a.name])
    IO.inspect(Repo.all(doq))
    #
    album_track_query =
      from(t in "tracks", select: [t.album_id, t.index, t.title], order_by: [t.album_id, t.index])

    IO.inspect(Repo.all(album_track_query))

    #
    album_track_query2 =
      from(t in "tracks",
        select: [t.album_id, t.index, t.title],
        order_by: [desc: t.album_id, asc: t.index]
      )

    IO.inspect(Repo.all(album_track_query2))

    #
    track_album_query =
      from(t in "tracks", select: [t.album_id, t.index, t.title], order_by: [t.index, t.album_id])

    IO.inspect(Repo.all(track_album_query))

    #
    track_album_query2 =
      from(t in "tracks",
        select: [t.album_id, t.index, t.title],
        order_by: [desc: t.index, asc_nulls_first: t.album_id]
      )

    IO.inspect(Repo.all(track_album_query2))

    #
    duration_query =
      from(t in "tracks", select: [t.album_id, sum(t.duration)], group_by: t.album_id)

    IO.inspect(Repo.all(duration_query))

    #
    duration_query2 =
      from(t in "tracks",
        select: [t.album_id, sum(t.duration)],
        group_by: t.album_id,
        order_by: sum(t.duration)
      )

    IO.inspect(Repo.all(duration_query2))

    #
    duration_query3 =
      from(t in "tracks",
        select: [t.album_id, sum(t.duration)],
        group_by: t.album_id,
        having: sum(t.duration) > 3400
      )

    IO.inspect(Repo.all(duration_query3))

    ### joins
    #
    jq =
      from(t in "tracks",
        join: a in "albums",
        on: t.album_id == a.id,
        where: t.duration > 765,
        select: [a.title, t.title, t.duration]
      )

    IO.inspect(Repo.all(jq))

    #
    jq2 =
      from(t in "tracks",
        join: a in "albums",
        on: t.album_id == a.id,
        where: t.duration > 765,
        select: %{album: a.title, title: t.title, dur: t.duration}
      )

    IO.inspect(Repo.all(jq2))

    #
    jq3 =
      from(t in "tracks",
        join: a in "albums",
        on: t.album_id == a.id,
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: t.duration > 765,
        select: %{artist: ar.name, album: a.title, title: t.title, dur: t.duration}
      )

    IO.inspect(Repo.all(jq3))

    ### composing queries
    #
    cq =
      from(a in "albums",
        join: ar in "artists",
        on: a.artist_id == ar.id,
        where: ar.name == "Miles Davis",
        select: [ar.id, ar.name, a.title]
      )

    IO.inspect(Repo.all(cq))

    #
    cq2 =
      from(a in "albums",
        join: ar in "artists",
        on: a.artist_id == ar.id,
        join: t in "tracks",
        on: a.id == t.album_id,
        where: ar.name == "Miles Davis",
        select: [ar.name, a.title, t.index, t.title]
      )

    IO.inspect(Repo.all(cq2))

    #
    miles_albums_query =
      from(a in "albums",
        join: ar in "artists",
        on: a.artist_id == ar.id,
        where: ar.name == "Miles Davis"
      )

    ma = from(ma in miles_albums_query, select: ma.title)
    IO.inspect(Repo.all(ma))
    ma2 = from([ma, art] in miles_albums_query, select: [art.name, ma.title])
    IO.inspect(Repo.all(ma2))

    track_q =
      from(al in miles_albums_query,
        join: t in "tracks",
        on: t.album_id == al.id,
        select: [al.title, t.title]
      )

    IO.inspect(Repo.all(track_q))

    ## named binding(s)
    #
    miles_albums_query2 =
      from(a in "albums",
        as: :albums,
        join: ar in "artists",
        as: :artists,
        on: a.artist_id == ar.id,
        where: ar.name == "Miles Davis"
      )

    album_query =
      from([albums: a, artists: art] in miles_albums_query2, select: [art.name, a.title])

    IO.inspect(Repo.all(album_query))

    # order no longer matters, they're named
    album_query2 =
      from([artists: art, albums: a] in miles_albums_query2, select: [art.name, a.title])

    IO.inspect(Repo.all(album_query2))

    IO.inspect(has_named_binding?(miles_albums_query2, :albums))

    ## composing queries with functions
    #
    bq =
      album_by_artist("Bobby Hutcherson")
      |> title_only

    IO.inspect(Repo.all(bq))

    #
    bq2 =
      "albums"
      |> by_artist("Bobby Hutcherson")
      |> title_only

    IO.inspect(Repo.all(bq2))

    mq =
      "albums"
      |> by_artist("Miles Davis")
      |> with_tracks_longer_than(720)
      |> title_only

    IO.inspect(Repo.all(mq))

    ## fun with; or_where
    albums_by_miles =
      from(a in "albums",
        join: ar in "artists",
        on: a.artist_id == ar.id,
        where: ar.name == "Miles Davis"
      )

    mbq = from([a, ar] in albums_by_miles, where: ar.name == "Bobby Hutcherson", select: a.title)
    IO.inspect(Repo.all(mbq))

    mbq2 =
      from(a in "albums",
        join: ar in "artists",
        on: a.artist_id == ar.id,
        where: ar.name == "Miles Davis" or ar.name == "Bobby Hutcherson",
        select: %{artist: ar.name, album: a.title}
      )

    IO.inspect(Repo.all(mbq2))

    mbq3 =
      from([a, ar] in albums_by_miles,
        or_where: ar.name == "Bobby Hutcherson",
        select: %{artist: ar.name, album: a.title}
      )

    IO.inspect(Repo.all(mbq3))

    ## other ways
    #
    Repo.update_all("artists", set: [updated_at: DateTime.utc_now()])
    all_art = from("artists", select: [:id, :name, :updated_at])
    IO.inspect(Repo.all(all_art))

    # or (lq1 + 3) or 2
    lq1 = from(t in "tracks", where: t.title == "Autum Leaves")
    # 1
    Repo.update_all(lq1, set: [title: "Autumn Leave"])

    from(t in "tracks", where: t.title == "Autumn Leaves")
    # 2
    |> Repo.update_all(set: [title: "Autum Leaves"])

    from(t in "tracks", where: t.title == "Autumn Leave")
    # 3
    |> Repo.update_all(set: [title: "Autumn Leaves"])

    like_autum_query = from(t in "tracks", where: like(t.title, ^"Autum%"), select: [:id, :title])
    IO.inspect(Repo.all(like_autum_query))

    ## delete_all demo:
    # from(t in "tracks", where: t.title == "Autumn Leaves")
    #  |> Repo.delete_all

    ### last statement; "done"
    IO.puts("done")
  end
end

# add your test code to Playground.play above - this will execute it
# and write the result to the console
IO.inspect(Playground.play())
