# Command

## npm version

npm version major → 2.0.0 (creates git tag v2.0.0)
npm version minor → 1.1.0 (creates git tag v1.1.0)
npm version patch → 1.0.1 (creates git tag v1.0.1)

## gpg

### listar claves
```bash
$ gpg --list-secret-keys --keyid-format LONG
```

## git

### configurar keyID

```bash
$ git config --local user.signingkey <KEYID>
```

### firmar ultimo tag

```bash
$ git commit -S --amend --no-edit
```