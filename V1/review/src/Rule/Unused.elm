module Rule.Unused exposing (..)

import NoUnused.Variables
import NoUnused.Modules

rules =
    [NoUnused.Variables.rule
    ,NoUnused.Modules.rule
    ]