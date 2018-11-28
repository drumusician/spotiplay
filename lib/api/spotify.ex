defmodule Spotiplay.Api.Spotify do
  @moduledoc false

  use HTTPoison.Base

  def get_random_track(artist) do
    query_string = URI.encode_query(%{q: artist, type: "artist"})
    result = __MODULE__.get!("search?#{query_string}").body["artists"]["items"]

    top_tracks =
      case result do
        [] ->
          nil

        _ ->
          result
          |> List.first()
          |> Map.get("id")
          |> get_top_tracks
      end

    case top_tracks do
      [] ->
        nil

      _ ->
        top_tracks
        |> Enum.random()
    end
  end

  def get_top_tracks(artist_id) do
    __MODULE__.get!("artists/#{artist_id}/top-tracks?country=NL").body["tracks"]
  end

  def process_url(url) do
    "https://api.spotify.com/v1/" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
  end

  def process_request_headers(headers) do
    headers ++ [{"Authorization", "Bearer #{access_token()}"}]
  end

  def access_token do
    client_id = Application.get_env(:spotiplay, :spotify_client_id)
    client_secret = Application.get_env(:spotiplay, :spotify_client_secret)

    headers = [
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    body = {:form, [grant_type: "client_credentials"]}

    HTTPoison.post!("https://accounts.spotify.com/api/token", body, headers).body
    |> Poison.decode!()
    |> Map.get("access_token")
  end
end
