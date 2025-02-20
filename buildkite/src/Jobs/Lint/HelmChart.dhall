let S = ../../Lib/SelectFiles.dhall

let Cmd = ../../Lib/Cmds.dhall

let Pipeline = ../../Pipeline/Dsl.dhall

let PipelineTag = ../../Pipeline/Tag.dhall

let JobSpec = ../../Pipeline/JobSpec.dhall

let Command = ../../Command/Base.dhall

let Docker = ../../Command/Docker/Type.dhall

let Size = ../../Command/Size.dhall

in  Pipeline.build
      Pipeline.Config::{
      , spec = JobSpec::{
        , dirtyWhen =
          [ S.contains "helm/"
          , S.strictlyStart (S.contains "buildkite/src/Jobs/Lint/HelmChart")
          , S.strictlyStart
              (S.contains "buildkite/src/Jobs/Release/HelmRelease")
          , S.exactly "buildkite/scripts/helm-ci" "sh"
          ]
        , path = "Lint"
        , name = "HelmChart"
        , tags = [ PipelineTag.Type.Fast, PipelineTag.Type.Lint ]
        }
      , steps =
        [ Command.build
            Command.Config::{
            , commands =
              [ Cmd.run "HELM_LINT=true buildkite/scripts/helm-ci.sh" ]
            , label = "Helm chart lint steps"
            , key = "lint-helm-chart"
            , target = Size.Small
            , docker = None Docker.Type
            }
        ]
      }
