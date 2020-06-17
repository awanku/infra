#!/usr/bin/env bash
export NOMAD_ADDR=http://nomad.service.consul:4646
nomad $@
