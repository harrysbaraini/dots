# My chezmoi-managed dotfiles and environment configuration

1. Initialize chezmoi

```sh
chezmoi init `https://github.com/harrysbaraini/dots.git`
```

1. Ensure Proton's `pass-cli` is installed and logged in.

```sh
pass-cli login --interactive
```

1. Apply configuration

```sh
chezmoi apply
```
