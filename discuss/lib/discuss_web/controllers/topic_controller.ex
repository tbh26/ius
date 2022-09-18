defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Topic

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    topicStruct = %Topic{}
    changeSet = Topic.changeset(topicStruct, %{})
    example = "hello world"

    render conn, "new.html", changeset: changeSet, example: example
  end

  def create(conn, %{"topic" => topic_param} = changeset) do
    # IO.inspect topic_param
    %{"title" => form_title} = topic_param
    case Topic.create_topic(%{title: form_title}) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "#{topic.title} created!")
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end


  end

end
