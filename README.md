# Omarchy Plugins

Custom plugins for [Omarchy](https://omarchy.org/).

## Plugins

### Audio

The audio interface now lists all available ports and lets you select and switch between them. <img width="417" height="518" alt="screenshot-2026-08-17_11-46-55" src="https://github.com/user-attachments/assets/d19a43c2-c22f-47d5-859e-6fd1fa7424e8" />

### Calendar and Weather

Displays the entire year on a single screen, while the weather plugin shows the temperature directly in the bar.

<img width="497" height="597" alt="screenshot-2026-08-17_11-47-07" src="https://github.com/user-attachments/assets/50636836-f2ae-44a6-8fa9-3180e73d4d31" />

### Resources

A simple resource monitor so you can keep an eye on your beloved RAM.

<img width="162" height="35" alt="screenshot-2026-08-17_11-47-20" src="https://github.com/user-attachments/assets/fe3eae5d-1f69-4737-8783-8d9b3694b5e5" />

## Requirements

* Omarchy installed and running.
* `omarchy` and `omarchy-shell` available in your `PATH`.

## Local Installation

From the root of this repository, run:

```bash
mkdir -p ~/.config/omarchy/plugins
for plugin in plugins/*; do
  ln -sfn "$PWD/$plugin" "$HOME/.config/omarchy/plugins/$(basename "$plugin")"
done

omarchy-shell shell rescanPlugins
```

Enable the plugins you want:

```bash
omarchy plugin list
omarchy plugin enable notliad.audio
omarchy plugin enable notliad.bar
omarchy plugin enable notliad.clock
omarchy plugin enable notliad.lock
omarchy plugin enable notliad.media
omarchy plugin enable notliad.resources
omarchy plugin enable notliad.weather
```

After modifying the files, run again:

```bash
omarchy-shell shell rescanPlugins
```

The symlink makes local changes reflect directly in Omarchy.
