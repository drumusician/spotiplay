defmodule Spotiplay.CLI do
  @moduledoc """
  Command Line client for SPitplay
  """

  alias Spotiplay.Api.Spotify

  def main(argv \\ []) do
    artist = Enum.join(argv, " ")
    IO.puts("Let me find some music by #{artist}")
    HTTPoison.start()
    track = Spotify.get_random_track(artist)

    case track do
      nil ->
        IO.puts("searching...")
        :timer.sleep(2000)
        IO.puts("hmmm that artist doesn't have any preview tracks available.\n")
        :timer.sleep(1500)
        IO.puts("How about some music by Frans Duits... ?\n")
        :timer.sleep(1000)
        main(['Frans', 'Duits'])

      _ ->
        System.cmd("curl", ["-o", "file.mp3", track["preview_url"]], stderr_to_stdout: true)
        IO.puts("Ok, playing #{track["name"]} by #{artist}")
        System.cmd("mplayer", ["file.mp3"], stderr_to_stdout: true)
        File.rm("file.mp3")
    end
  end
end
