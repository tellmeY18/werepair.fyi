default:
    @just --list

setup:
    mix local.hex --force
    mix local.rebar --force
    mix setup

serve:
    mix phx.server

seed:
    mix run priv/repo/seeds.exs

check:
    mix precommit

test:
    mix test

wiki-export:
    mix wiki.export

smoke:
    node scripts/smoke.mjs
