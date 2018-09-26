port module WorkersPort exposing (..)

import Json.Decode
import Json.Encode


addWorker : { id : String, url : String } -> Cmd a


sendMessageToWorker : { id : String, message : Json.Encode.Value } -> Cmd a


onWorkerMessage : { id : String, message : Json.Decode.Value } -> Sub a
