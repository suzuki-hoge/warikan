module Client exposing (get, post, put)

import Http exposing (Expect, Error, request, header, emptyBody, jsonBody, expectJson, expectWhatever)
import Json.Decode as D
import Json.Encode as E

get : String -> (Result Error a -> msg) -> D.Decoder a -> Cmd msg
get resource toMsg decoder = request {
      method = "GET"
    , headers = []
    , url = "http://localhost:9000/" ++ resource
    , body = emptyBody
    , expect = expectJson toMsg decoder
    , timeout = Nothing
    , tracker = Nothing
    }

post : String -> (Result Error () -> msg) -> E.Value -> Cmd msg
post resource toMsg body = request {
      method = "POST"
    , headers = []
    , url = "http://localhost:9000/" ++ resource
    , body = jsonBody body
    , expect = expectWhatever toMsg
    , timeout = Nothing
    , tracker = Nothing
    }

put : String -> (Result Error () -> msg) -> E.Value -> Cmd msg
put resource toMsg body = request {
      method = "PUT"
    , headers = []
    , url = "http://localhost:9000/" ++ resource
    , body = jsonBody body
    , expect = expectWhatever toMsg
    , timeout = Nothing
    , tracker = Nothing
    }
