# kOMA Power Control

A native Plasma 6 widget for battery charge, charge rate, battery capacity and cycles, power profiles, and PLAID Power.

PLAID Power keeps KDE from automatically suspending, dimming or switching off displays, and locking the session. It holds temporary PowerDevil and ScreenSaver inhibitors in a shared user service: your saved settings remain untouched. Turning it off releases those inhibitors and restores normal behavior. All panel instances share its state, and it survives a Plasma restart. Logging out releases it; it is not enabled automatically on the next login. Other applications' inhibitors remain intact. Manual lock and shutdown remain available.

Profiles use the installed power-profiles-daemon service (current or legacy DBus name). If the machine has no battery or profile provider, the widget explains that and disables unsupported controls.

Install and add to existing panels: `bash bin/install`. Use `--no-place` to install only.

CLI: `komapowercontrol status`, `komapowercontrol plaid on`, `komapowercontrol plaid off`, `komapowercontrol profile balanced`.

Dependencies: Plasma 6, systemd user session, Python 3 with dbus-python and PyGObject, UPower. Optional power-profiles-daemon for profiles.

Run tests: `python3 -m unittest discover -s tests`.

KDE Store installations work without running the repository installer: the first
PLAID Power activation creates its systemd user service automatically. The CLI
shortcut is supplied by `bin/install`; the widget itself uses its bundled helper.

Release package: `dist/com.columbiafoundry.komapowercontrol-0.1.0.plasmoid`.
Store submission copy is in `dev/kde-store-listing.md`.
