# Pronto runner for Fasterer

Pronto runner for [fasterer](https://github.com/DamirSvrtan/fasterer). More about [Pronto](https://github.com/prontolabs/pronto).

## Configuration

Config options in fasterer config(`.fasterer.yml`) also supported.

## Installation

RubyGems already has similar [gem](https://rubygems.org/gems/pronto-fasterer/versions/0.11.1) and if you need runner choose it.<br>
This gem wasn't published in RubyGems but still can be build and test locally.

## Usage

The best way to use it with some Git hooks manager for example [Lefthook](https://github.com/evilmartians/lefthook) or in CI pipeline step.<br>
If you want to check runner separately on modified files just run:

```sh
pronto run -r fasterer --unstaged
```

This command will produce next output:

![output](doc/output.png "Output")
