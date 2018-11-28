defmodule Spotiplay.CLI do
  @moduledoc """
  Command Line client for SPitplay
  """

  alias Spotiplay.Api.Spotify

  def main(argv \\ []) do
    artist = Enum.join(argv, " ")
    IO.puts("Let me find some music by #{artist}")
    HTTPoison.start()

    artist
    |> Spotify.get_random_track()
    |> play_track
  end

  defp play_track(nil) do
    IO.puts("searching...")
    :timer.sleep(2000)
    IO.puts("hmmm that artist doesn't have any preview tracks available.\n")
    :timer.sleep(1500)
    IO.puts("How about some music by Frans Duits... ?\n")
    :timer.sleep(1000)
    main(['Frans', 'Duits'])
  end

  defp play_track(track) do
    case track["preview_url"] do
      nil ->
        play_track(nil)

      _ ->
        System.cmd("curl", ["-o", "file.mp3", track["preview_url"]], stderr_to_stdout: true)
        IO.puts("Ok, playing #{track["name"]} by #{artist(track)}")
        System.cmd("mplayer", ["file.mp3"], stderr_to_stdout: true)
        File.rm("file.mp3")
    end
  end

  defp artist(track) do
    track["artists"]
    |> List.first()
    |> Map.get("name")
  end
end
