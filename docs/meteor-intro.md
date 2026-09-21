# Home screen

The meteor opening image is the static home-screen background. Video is deferred at the user’s request. Start opens three browser-local save slots. Empty slots create a character; existing slots resume their checkpoint. Current playable content ends at the character creator, so current saves reopen there. Future world scenes must call SaveSlots.save_checkpoint with the scene, location label and state, and restore SaveSlots.checkpoint.state on entry. Settings persist master volume and mute. The existing single-character save is copied into slot one without deleting the original.
