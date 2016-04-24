if application "Spotify" is running then
	tell application "Spotify"
		set trackName to the name of the current track
		set trackArtist to the artist of the current track
		try
			return trackName & " :: " & trackArtist
		on error err
		end try
	end tell
end if

