# Version 0.722
	- SSH session support. You can now start full ssh sessions inside the shell, or send remote ssh commands to a host.

# Version 0.716
	- Improved focus to follow the Terminals.
	- Pasting key from clipboard problems fixed.
	- ssh-copy-id problems fixed.
	- Mosh session support for ssh port and identity added (-I and -P)
	- Scroll during a Mosh Session disabled.

# Version 0.713
	- Releasing Blink as Open Source

	- Copy and Paste support.
	- SmartKeys: On-Screen keyboard display, with support for keyboard combos.
	- Modifier keys support on SmartKeys: continuous presses.
	- Closing a Terminal with Two Fingers down gesture.
	- Space swiping notifications.
	- Font size control with keyboard
	- Fixed CAPS as Ctrl problem with normal characters.
	- Smooth swiping spaces gestures.
	- Scroll.

	- New libssh2 based backend for ssh command.
	- ssh command with exec, pty and shell support.
	- DNS and Bonjour name resolution. Back to My Mac support.
	- Known Hosts verification.
	- Support for interactive authentication methods.
	- Public Key authorization support.
	- Settings dialog for Blink configuration.
	- PK creation from settings.
	- Support to run an external command from Mosh or SSH.

	- ssh-copy-id command.
	- stderr support for Sessions.
	- Duplicated streams for each Session, attached or detached.
	- Terminals freeing resources and correctly killing Sessions after termination.
	- Mosh prediction modes support.

# Version 0.511
This version has seen major improvements on Mosh, terminal display and keyboard support. Please read previous notes:
	- The terminal is faster and most of the identified glitches have been fixed.
	- We have added a Powerline font so you can have fun and test tools like zsh, tmux or spacemacs!
	- Mosh is now cleaner when restoring.
	- CAPS as Ctrl now preserves the state. Mapped Cmd and Alt special events to the right commands.

# Version 0.504
This version continues the previous goal to stabilise Mosh by exposing it to real life scenarios. Many problems have been fixed since last version:
	- Terminal problems have been fixed (misalignments, problems when switching to other apps, etc..)
	- Mosh issues fixed: Restore the session after device suspension; Mosh crashing right after start; Threading problems restarting a session.

## New from this version:
	- We now support Mosh < 1.2.5
	- Added SplitView to continue the terminal work.

## What to test:
	- Problems establishing a connection, multiple concurrent sessions open, closing connections correctly, reconnecting after long periods
	- Keyboard support:  For this version we have configured Ctrl, Cmd and Caps as Ctrl, Alt as meta.
	- Terminal rendering glitches: Complex terminal layouts, split view positioning, Unicode, color rendering.

# Version 0.429
The purpose of this build is to test our Mosh version in real life scenarios that could help us identify errors and misbehaviours. Sorry if there are no bells and whistles yet, we want everyone to focus on stabilising our Mosh changes.
##What to test:
	- Problems establishing a connection, multiple concurrent sessions open, closing connections correctly, reconnecting after long periods...
	- Keyboard support:  For this version we have configured Ctrl, Cmd and Caps as Ctrl, Alt as meta.
	- Terminal rendering glitches: Unicode, color rendering, garbled rendering...
