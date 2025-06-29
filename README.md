<div align="center">
  <img alt="Risk of Rain 2 Banner" src="https://www.riskofrain.com/wp-content/uploads/2019/04/ror2_logo_512-1.png"/>
  </br>
  <a href="https://travis-ci.com/github/FragSoc/riskofrain2-docker"><img src="https://img.shields.io/travis/com/FragSoc/riskofrain2-docker?style=flat-square"/></a>
  <a href="https://github.com/FragSoc/riskofrain2-docker"><img src="https://img.shields.io/github/license/fragsoc/riskofrain2-docker?style=flat-square"/></a>
  </br>
  <img src="https://img.shields.io/badge/BepInEx-5.3.1-blueviolet?style=flat-square"/>
  <img src="https://img.shields.io/badge/R2API-2.5.14-blueviolet?style=flat-square"/>
  <img src="https://img.shields.io/badge/EnigmaticThunder-0.1.1-blueviolet?style=flat-square"/>
</div>

---

A [docker](https://www.docker.com/) image for running a dedicated server for the game [Risk of Rain 2](https://www.riskofrain.com/).
Several modding frameworks can be optionally baked in.
# Devs do not give us the server binary anymore / project dead
# Usage

### Quickstart

```bash
docker build -t fragsoc/riskofrain2 https://github.com/JoBazzy/riskofrain2-docker.git && \
  docker run -p 27015:27015/udp -p 27016:27016/udp fragsoc/riskofrain2
```

### Building

The image takes several build args, passed with `--build-arg` to the `docker build` command:

Argument Key | Default Value | Description
---|---|---
`APPID` | `1180760` | The steam appid to install, there's little reason to change this
`STEAM_BETAS` | (Blank) | A string to pass to `steamcmd` to download any beta versions of the game, eg. `-beta mybeta -betapassword letmein`
`STEAM_EPOCH` | (Blank) | Used to rebuild the image when a new game version is released, retaining the cached `apt` packages etc. Value itself is ignored. When you want to rebuild the image for the latest version of the game, use any unique value (the current timestamp is a good idea).
`UID` | `999` | The user ID to assign to the created user within the container
`GID` | `999` | The group ID to assign to the created user's primary group within the container
`GAME_PORT` | `27015` | The port to assign and expose for the game server
`STEAM_PORT` | `27016` | The port to assign and expose for the steam service

#### Subtargets

There are several [docker subtargets](https://docs.docker.com/develop/develop-images/multistage-build/) you can select to use different modifications to the game.
To select a target, add `--target=targetname` to your `docker build` command.

Target Name | Description
---|---
`vanilla` | A vanilla installation of the server.
`bepinex` | A server with only [BepInEx](https://github.com/BepInEx/BepInEx) installed. Takes an additional build argument, `BEPINEX_VERSION`.
`r2api` | A server with BepInEx and [R2API](https://github.com/risk-of-thunder/R2API) installed. Takes the argument from `bepinex` and an additional build argument `R2API_VERSION`.
`enigmaticthunder` | A server with BepInEx and [EnigmaticThunder](https://thunderstore.io/package/EnigmaDev/EnigmaticThunder/) installed. Takes the argument from `bepinex` and an additional argument `ENIGMATIC_THUNDER_VERSION`. **If you do not specify a target manually, this is the default version that will be built**.

If the `*_VERION` args are omitted, they will default to the versions shown in the badges above.

### Running

The container requires 2 ports, `27015` and `27016` over UDP (or whatever you overrode them to in the build args).

The container takes several environment variables:

Variable Key | Default Value | Description
---|---|---
`GAME_NAME` | `A dockerised Risk of Rain 2 Server` | The name of the server to be displayed in the steam server list
`GAME_PASSWORD` | `letmein` | The password to connect to the server, set to blank to disable
`MAX_PLAYERS` | `4` | The maximum allowed number of players in the server

If you need more fine-grained control over the server configuration, you can bind mount over the `/server.cfg` file in the container, overriding anything you set with the environment vars.

#### Modding

> **Note**: you must use one of the modloader-enabled build targets for mods.
> See above.

The container comes with two volumes for mods:

Path | Equivalent Client Path | Purpose
---|---|---
`/plugins` | `BepInEx/plugins/rootmods` | mod files, `.dll`s etc; this is a subfolder as to not override the modloader's files. The game should find files here recursively.
`/plugin_config` | `BepInEx/config` | mod config files

We suggest bind-mounting over these directories to manage your mods, but they are declared as volumes for convenience.

If you need even finer-grained control over your mod structure, you can mount over the `/ror2/BepInEx/plugins` or `/ror2/BepInEx` folders inside the container

> Note that this may **override the content automatically installed by the image** depending which you mount over.
> If you need these tools, we suggest using the provided targets, but if you use the above method then you'll need to install the tools manually.

See the [Risk of Rain 2 Modding Wiki](https://github.com/risk-of-thunder/R2Wiki/wiki) for more information.

# Licensing

The few files in this repo are licensed under the AGPL3 license.
However, Risk of Rain 2 and it's dedicated server are proprietary software licensed by [Hopoo Games](https://hopoogames.com/), no credit is taken for their software in this container.
See the [ROR2 EULA](https://store.steampowered.com/eula/632360_eula_0) for more information.
