module Pipelines exposing (..)

import ReviewPipelineStyles exposing (..)
import ReviewPipelineStyles.Fixes exposing (..)

toRule =
    rule [forbid leftPizzaPipelines
        |> andTryToFixThemBy convertingToRightPizza
        |> andCallThem "no left pipes"]