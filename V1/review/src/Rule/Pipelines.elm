module Rule.Pipelines exposing (..)

import ReviewPipelineStyles exposing (..)
import ReviewPipelineStyles.Fixes exposing (..)
import ReviewPipelineStyles.Predicates exposing (..)


toRule =
    rule [forbid leftPizzaPipelines
            |> andTryToFixThemBy convertingToRightPizza
            |> andCallThem "no left pipes"
        , forbid leftCompositionPipelines
            |> andTryToFixThemBy convertingToRightComposition
            |> andCallThem "no right composition pipes"
        ,forbid rightPizzaPipelines
            |> that (doNot spanMultipleLines |> and (haveMoreStepsThan 1))
            |> andTryToFixThemBy makingMultiline
            |> andCallThem "single line |> pipeline"
       , forbid rightPizzaPipelines
        |> that haveASimpleInputStep
        |> andTryToFixThemBy eliminatingInputStep
        |> andCallThem "|> pipeline with simple input"
    , forbid parentheticalApplicationPipelines
        |> that
            (haveMoreStepsThan 1
                |> and
                    (doNot
                        (haveAParentNotSeparatedBy
                            [ aLetBlock
                            , aLambdaFunction
                            , aFlowControlStructure
                            , aDataStructure
                            ]
                        )
                    )
            )
        |> andTryToFixThemBy convertingToRightPizza
        |> andCallThem "parenthetical application with several steps"
    ]