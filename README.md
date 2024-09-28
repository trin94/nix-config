# nixOS config WIP

* Copied and adjusted from https://codeberg.org/justgivemeaname/.dotfiles

```shell
nix-shell -p git just home-manager

git clone https://github.com/trin94/nix-config.git ~/.dotfiles
cd ~/.dotfiles

cp /etc/nixos/hardware-configuration.nix system/nixos

export NIX_CONFIG="experimental-features = nix-command flakes"

just apply-system apply-user
```

## ***GUIDE***

The files in this repo are what manage my NixOs system. 
The main philosophy I have is that they are split into two components. The `system` directory holds my `configuration.nix`
that I originally copied from `/etc/nixos/configuration.nix` after my first install was complete. 
The `configuration.nix` is what manages everything at a system level.
I also copied the `hardware-configuration.nix` from `/etc/nixos/hardware-configuration.nix` after the initial install.
The `hardware-configuration.nix` will need to be copied over and replace the current file whenever you install nix on a new machine.

The `home-manager` directory is what runs `home-manager` via `home.nix` and all the configuration files for the packages that I install. 
Many people have `configuration.nix` download and install `home-manager`. I do not. 
Instead I have `home-manager` manage itself. 
In order to get it working we have to bootstrap it the first time (instructions down below).
The benefit of doing it this way is that since `home-manager` manages itself, it makes it very easy to copy those files and use `home-manager` on a non NixOs system.
It also allows you to only update the `home-manager` packages and leave the main system alone when changes are made to just `home-manager`.

During my install of NixOs (23.11) I ran into a bug where this directory was missing and Nix would not build. Manually creating it solved the problem.
You will get the error during your first build of `home-manager` if it happens to you. 

0.5) `mkdir -p ~/.local/state/nix/profiles`

If you want to have `home-manager` manage itself, you run into a chicken and the egg problem. 
You don't have `home-manager` installed so it can't start managing itself, but we want it to. 
The way around this is boot straping `home-manager` by downloading it temporarily just once and running it one time so it can take care of itself afterwards.

These are the following commands to get your machine up and running for the first time.
They need to be run in the same directory as your `flake.nix`.
On my system I keep them located in `~/.dotfiles`.
Numbers `3)` and `4)` will be used after the first time to update your machine whenever you make changes:

1) `export NIX_CONFIG="experimental-features = nix-command flakes"`

Run this command to enable your current shell with the `nix-command` feature. This gives you the updated Nix commands are that used to manage flakes.
It also enables `flakes` to be used in the current shell so you can use the `nix-command` with your `flake.nix` that is in this current directory 
(flakes are the modern and the correct way of using NixOs and will be mandatory in the future).

2) `nix shell nixpkgs#home-manager`

This command installs `home-manager` just within your current shell. If you close this shell (that you ran step `1)` in) or open a new shell it will not be availible.
You will have to run step `1)` again, then this command again, in whatever shell you want to use, in order to get the preceding command to work and build your NixOs system for the first time.

`nix shell nixpkgs#<package>` is the command that is used to download Nix packages for temporary one off uses.
They will no longer be availible once you leave the shell you ran the command in and they will be removed from your system when you collect your garbage (step 5).

3) `sudo nixos-rebuild switch --flake .`

This command is what builds the NixOs **system** from the options set within `/system/configuration.nix`. 
This is also the command that is run to update NixOs on a system level when changes are made (if you follow my layout philosophy).

3a) `sudo nixos-rebuild switch --flake .#hostname`

If you have a `configuration.nix` that contains multiple `hostname`'s, then you need to tell the `flake.nix` which one to run.
You can do this by running the preceding command. If you only have one `hostname` then it is not needed.
Just running it with a `.` is fine, but you can still do it if you want to be thorough.

4) `home-manager switch --flake .`

This is the command that you run to update your `home-manager`.
If this is your first time running `home-manager` then you need to make sure to do steps `1)`, `2)` and `3)` in that order before running this command.
If you have already done those steps in that order at least once, then you can just run this preceding command everytime you want to update `home-manager`.
You will want to update `home-manager` after every change you make in the file `./home-manager/home.nix`

4a) `home-manager switch --flake .#username@hostname`

Just like with step `3a)` this is the command you run if you have multiple users and you want to update a specific one.
If you only have one user then you can run the command with just a `.`

Something to notice. Only step `3)` requires the use of `sudo`. 
With my philosophy of seperating the files for system and users, the use of `sudo` should be a hint.
If the changes you make won't require the use of `sudo`, then they go in `./home-via/home.nix` because they only effect a user. 
If the changes you make will require the use of `sudo`, then they go in `./system/configuration.nix`.

5) `nix-collect-garbage`

Everytime you rebuild your system and/or home-manager, NixOs will constantly be downloading files.
With the philosophy of NixOs, those file will stick around to be part of your previous generations that you can fall back to if you run into problem or you just want to.
If you find that you are enjoying your current setup, and it is stable, you can regain harddrive space by cleaning up those now unused files that are being kept around in case you want to roll back.
Run the preceding command to clear out the old packages.


At this point if you want to see exactly how my setup looks, feel free to start poking around and building a mental model.

A VERY IMPORTANT NOTE! Using flakes within Nix revolves around them being tracked with version control (git).
If you make changes to your `home.nix` file and try to rebuild you may get a warning error that a file or directory was not found.
That is because you forgot to add the new file/directory to git.
You can add it with `git add -A`.

If you want to update a package, you need to update the channel your `flake.nix` is looking at, so it is aware of the updated packages that have been pushed to the nix channel.
You can do this by running `sudo nix flake update`. 
Nix will update the `flake.lock` to look at the newest updated channel and you can install the newest programs by running steps 3) or 4) above.


# Links

* https://www.zknotes.com/page/alternate-nixpkgs-in-flakes-nixos
