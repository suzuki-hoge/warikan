module Main exposing (main)

import Browser
import Html exposing (Html, button, dd, div, dl, dt, input, p, pre, span, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http

import Party exposing (Party, PartyName, PartyHoldAt, Participant, ParticipantName, PaymentSection, BillingAmount, AdjustingUnitAmount, Payment)
import Client


-- MAIN


main = Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


-- MODEL


type Model = Opened
           | PartyNameInputted PartyName
           | PartyInputted PartyName PartyHoldAt ParticipantName PaymentSection BillingAmount AdjustingUnitAmount
           | PartyViewing Party ParticipantName PaymentSection AdjustingUnitAmount
           | Demanded (List Payment)
           | Loading
           | Failure String


init : () -> (Model, Cmd Message)
init _ = ( Opened, Cmd.none )


-- UPDATE


type Message = InputPartyName PartyName
             | InputParty PartyName PartyHoldAt ParticipantName PaymentSection BillingAmount AdjustingUnitAmount
             | Find PartyName
             | Found (Result Http.Error Party)
             | Plan PartyName PartyHoldAt ParticipantName PaymentSection BillingAmount AdjustingUnitAmount
             | Called (Result Http.Error ())
             | Add Party ParticipantName PaymentSection
             | AddParticipant Party ParticipantName PaymentSection AdjustingUnitAmount
             | Remove PartyName ParticipantName
             | Change PartyName AdjustingUnitAmount
             | ChangeReturn (Result Http.Error ())
             | Demand PartyName
             | DemandReturn (Result Http.Error (List Payment))

update : Message -> Model -> (Model, Cmd Message)
update message model = case message of
    InputPartyName pn              -> (PartyNameInputted pn,              Cmd.none)
    InputParty pn pha sn ss ba aua -> (PartyInputted pn pha sn ss ba aua, Cmd.none)
    Find pn                        -> (Loading,                           Client.get ("party/" ++ pn) Found Party.decoder)
    Found result                   -> case result of
        Ok party                   -> (PartyViewing party "" "" "",       Cmd.none)
        Err e                      -> (Failure <| Debug.toString e,       Cmd.none)
    Plan pn pha sn ss ba aua       -> (Loading,                           Client.post "party/plan" Called <| Party.encoder pn pha sn ss ba aua)
    Called result                  -> case result of
        Ok _                       -> (Opened,                            Cmd.none)
        Err e                      -> (Failure <| Debug.toString e,       Cmd.none)
    AddParticipant party pn ps aua -> (PartyViewing party pn ps aua,      Cmd.none)
    Add party pn ps                -> (PartyViewing party "" "" "",       Client.put ("party/" ++ party.partyName ++ "/add") Called <| Party.addEncoder pn ps)
    Change pn aua                  -> (Loading,                           Client.put ("party/" ++ pn ++ "/change") ChangeReturn <| Party.changeEncoder aua)
    ChangeReturn result            -> case result of
        Ok _                       -> (Opened,                            Cmd.none)
        Err e                      -> (Failure <| Debug.toString e,       Cmd.none)
    Demand pn                      -> (Loading,                           Client.get ("party/" ++ pn ++ "/demand") DemandReturn <| Party.demandDecoder)
    DemandReturn result            -> case result of
        Ok payments                -> (Demanded payments,                 Cmd.none)
        Err e                      -> (Failure <| Debug.toString e,       Cmd.none)
    _                              -> (Opened, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model = Sub.none


-- VIEW


view : Model -> Html Message
view model = div [] [ case model of
      Opened -> div [] [
            p [] [ button [ onClick <| InputPartyName "" ] [ text "find party" ] ]
          , p [] [ button [ onClick <| InputParty "" "" "" "Normal" "" "" ] [ text "plan new party" ] ]
          ]
      PartyNameInputted pn -> div [] [
            p [] [ input [ type_ "text", onInput InputPartyName, placeholder "party name" ] [ ] ]
          , button [ onClick <| Find pn ] [ text "find" ]
          ]
      PartyInputted pn pha sn ss ba aua -> div [] [
            p [] [ input [ type_ "text", onInput <| \x -> InputParty  x pha sn ss ba aua, placeholder "party name" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> InputParty pn   x sn ss ba aua, placeholder "yyyy-mm-dd" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> InputParty pn pha  x ss ba aua, placeholder "secretary name" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> InputParty pn pha sn  x ba aua, placeholder "M | N | L" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> InputParty pn pha sn ss  x aua, placeholder "billing amount" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> InputParty pn pha sn ss ba   x, placeholder "adjusting unit amount" ] [ ] ]
          , button [ onClick <| Plan pn pha sn ss ba aua ] [ text "plan" ]
          ]
      Loading -> div [] [
            p [] [ text "loading..." ]
          ]
      PartyViewing party pn ps aua -> div [] <| [
            dl [] [ dt [] [ text "飲み会名: "], dd [] [ text party.partyName ] ]
          , dl [] [ dt [] [ text "開催日時: "], dd [] [ text party.partyHoldAt ] ]
          , dl [] [ dt [] [ text "総額: "], dd [] [ text party.billingAmount ] ]
          , dl [] [ dt [] [ text "調整額: "], dd [] [ text party.adjustingUnitAmount ] ]
          ] ++ List.map (\p -> dl [] [ dt [] [ text "参加者: "], dd [] [ text <| p.participantName ++ " ( " ++ p.paymentSection ++ " )" ] ]) party.participants ++ [
            p [] [ input [ type_ "text", onInput <| \x -> AddParticipant party x ps aua, placeholder "adding name" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> AddParticipant party pn x aua, placeholder "M | N | L" ] [ ] ]
          , p [] [ input [ type_ "text", onInput <| \x -> AddParticipant party pn ps  x, placeholder "調整額変更" ] [ ] ]
          , button [ onClick <| Add party pn ps ] [ text "追加" ]
          , button [ onClick <| Change party.partyName aua ] [ text "調整" ]
          , button [ onClick <| Demand party.partyName ] [ text "計算" ]
          ]
      Demanded payments -> div [] <| List.map (\payment -> p [] [ text <| payment.participantName ++ " ( " ++ payment.paymentAmount ++ " )"]) payments
      Failure e -> div [] [
          ]
    , pre [] [ model |> Debug.toString |> String.replace "\\\\n" "\n" |> String.replace "\\\\\\" "" |> text ]
    ]
