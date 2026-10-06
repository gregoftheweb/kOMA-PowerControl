# KDE Store submission — kOMA Power Control 0.1.0

Name: kOMA Power Control
Category: Plasma 6 Applets
Version: 0.1.0
License: MIT
Tags: koma, plasma6, kde, battery, power, power-profiles, keep-awake, widget
Homepage: https://github.com/gregoftheweb/kOMA-PowerControl
Download file: com.columbiafoundry.komapowercontrol-0.1.0.plasmoid

## Short description
Battery information, power profiles, and a shared keep-awake switch for KDE Plasma 6.

## Description
kOMA Power Control puts battery information and power controls in a compact panel widget. Its popup follows your Plasma theme and color scheme.

Features:
- Battery percentage and charging state.
- Battery size in Wh, charge cycles, estimated time remaining or to full, and charge/discharge rate when reported by your hardware.
- Switch between available power-saver, balanced, and performance profiles.
- PLAID Power temporarily keeps the computer and screens awake without rewriting your saved KDE settings.
- PLAID state is shared between widget instances and survives a Plasma restart. Logging out releases it; it does not start automatically next login.
- Works on desktop PCs too: unavailable battery information and power profiles are clearly identified.

PLAID Power prevents automatic suspend, screen dimming/switch-off, and automatic session locking while enabled. Manual lock and shutdown remain available. Turn PLAID off to release its inhibitors; other applications' inhibitors remain intact.

Requirements: KDE Plasma 6, systemd user session, Python 3, dbus-python, PyGObject, and UPower. Optional power-profiles-daemon enables supported power profiles. On Arch/EndeavourOS, the Python dependencies are python-dbus and python-gobject. Availability of battery metrics and profiles depends on your hardware and services.

Install the plasmoid through KDE's widget installer and add kOMA Power Control to your panel. On first use of PLAID Power, the widget creates its user service automatically. No administrator access is required for that service.

## Changelog
Initial release: battery details, available power-profile switching, and shared session-scoped PLAID Power keep-awake control. Includes automatic user-service setup for KDE Store installations.
