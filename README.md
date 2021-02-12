# idgit - /ˈɪdʒɪt/ 📇

`idgit` (pronounced how a cowboy might say 'idiot') is a rolodex for your git config. 

## Aims

`idgit` provides a simple, bash only mechanism for setting up alternative git identities for different accounts, and easily
swapping between them.

It aims to replace the convenient, but sometimes messy `--global` `user.name/user.email` settings, while saving you the effort
of typing your __entire__ email (Maybe us millenials are as lazy as they say).

`idgit` also provides some gentle guard-rails for protecting your privacy.

## Usage

- Place a plain-text file with the `.alias` extension in `$XDG_CONFIG/idgit/` (`~/.config/idgit` by default).
- Place your details in the file as follows:
  ```bash
  # ~/.config/idgit/matthew_github.alias
  # Lines beginning with # are ignored
  # user.name first
  Matthew Strasiotto
  # user.email next
  39424834+matthewstrasiotto@users.noreply.github.com
  # credential.username last (optional)
  matthewstrasiotto 
  ```
- When you clone a new repo, before you commit:
  ```bash
  idgit <profile_name>
  ```
  Eg
  ```bash
  idgit matthew_github
  ```

## Installation

`idgit` can be installed in a `curl` oneliner like so:

```bash
# todo - implement install script. For now you need to download the script directly, and source it manually.
# /bin/bash -c "$(export INSTALL_IDGIT=true; curl -fsSL https://raw.githubusercontent.com/matthewstrasiotto/idgit/HEAD/idgit.bash)"
```

If you prefer to read scripts you run, feel free to download and inspect the linked script.

I will probably make a `brew`/`linuxbrew` formula if anyone else uses this.

(TODO: Implement) 

- `idgit` installs to `~/.idgit.bash`. 
- It asks your permission if it can patch your `.bashrc` with a `source` to the script. 
- It patches in `[[ -f ~/.idgit.bash ]] && source ~/.idgit.bash` only if that hasn't already been added.
- It asks if you want it to warn you about insecure settings.

## Stuff it helps with

`idgit` provides some gentle privacy safeguards:
- 🚨 `idgit` warns you if you have `--global` or `--system` level `user.name`/`user.email` set.
- 🚨 `idgit` warns you if `user.useConfigOnly` is not `true` - Meaning `git` will try to "guess" at
your user.name / use.email based on the environment.
- 🚨 `idgit` warns you if your push remote is `github.com`, and your email isn't `@users.noreply.github.com`.
  See [GitHub's Blocking Command Line Pushes that Expose Your Personal Email Address](https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/blocking-command-line-pushes-that-expose-your-personal-email-address) 

🚀 `idgit` tries to be convenient, and comes with tab completion.

## Roadmap:

- Probably print applied settings so people can see the correct id is being used
- Implement install script properly
  - Let this be unattended, use env vars for some options.

## Similar Works

https://github.com/unixtools/git-identity-helper
https://stackoverflow.com/questions/13750953/is-it-possible-to-configure-user-name-and-user-email-per-wildcard-domains-in-gi

