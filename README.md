# Noah's NixOS Config

nix-darwin

## Bootstrap

Install determinate nix.
Install homebrew

ssh-copy-id
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub HOST
```

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
```

