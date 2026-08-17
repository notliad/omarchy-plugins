# Omarchy Plugins

Plugins personalizados para o [Omarchy](https://omarchy.org/).

## Requisitos

- Omarchy instalado e em execução.
- `omarchy` e `omarchy-shell` disponíveis no `PATH`.

## Instalação local

Na raiz deste repositório, execute:

```bash
mkdir -p ~/.config/omarchy/plugins
for plugin in plugins/*; do
  ln -sfn "$PWD/$plugin" "$HOME/.config/omarchy/plugins/$(basename "$plugin")"
done

omarchy-shell shell rescanPlugins
```

Ative os plugins desejados:

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

Depois de alterar os arquivos, execute novamente:

```bash
omarchy-shell shell rescanPlugins
```

O symlink faz as alterações locais refletirem diretamente no Omarchy.
