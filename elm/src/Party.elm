module Party exposing (
      Party
    , PartyName
    , PartyHoldAt
    , BillingAmount
    , AdjustingUnitAmount
    , Participant
    , ParticipantName
    , ParticipantType
    , PaymentSection
    , decoder
    , encoder
    , addEncoder
    , Payment
    , demandDecoder
    , changeEncoder
    )

import Json.Decode as D
import Json.Encode as E

type alias Party = {
      partyName: PartyName
    , partyHoldAt: PartyHoldAt
    , participants: List(Participant)
    , billingAmount: BillingAmount
    , adjustingUnitAmount: AdjustingUnitAmount
    }

type alias PartyName = String
type alias PartyHoldAt = String
type alias BillingAmount = String
type alias AdjustingUnitAmount = String

type alias Participant = {
      participantName: ParticipantName
    , participantType: ParticipantType
    , paymentSection : PaymentSection
    }

type alias ParticipantName = String
type alias ParticipantType = String
type alias PaymentSection = String

type alias Payment = {
      paymentAmount: String
    , participantName : String
    }

decoder : D.Decoder Party
decoder = D.field "result" <| D.map5 Party
    (D.field "partyName" D.string)
    (D.field "partyHoldAt" D.string)
    (D.field "participants" <| D.list <| D.map3 Participant
        (D.field "participantName" D.string)
        (D.field "participantType" D.string)
        (D.field "paymentSection" D.string))
    (D.field "billingAmount" D.string)
    (D.field "adjustingUnitAmount" D.string)

encoder : PartyName -> PartyHoldAt -> ParticipantName -> PaymentSection -> BillingAmount -> AdjustingUnitAmount -> E.Value
encoder partyName partyHoldAt secretaryName paymentSection billingAmount adjustingUnitAmount = E.object [
      ("partyName", E.string partyName)
    , ("partyHoldAt", E.string partyHoldAt)
    , ("secretaryName", E.string secretaryName)
    , ("paymentSection", E.string paymentSection)
    , ("billingAmount", E.string billingAmount)
    , ("adjustingUnitAmount", E.string adjustingUnitAmount)
    ]

addEncoder : ParticipantName -> PaymentSection -> E.Value
addEncoder participantName paymentSection = E.object [
      ("participantName", E.string participantName)
    , ("paymentSection", E.string paymentSection)
    ]

demandDecoder : D.Decoder (List Payment)
demandDecoder = D.field "result" <| D.list <| D.map2 Payment
    (D.field "paymentAmount" D.string)
    (D.field "participantName" D.string)

changeEncoder : AdjustingUnitAmount -> E.Value
changeEncoder adjustingUnitAmount = E.object [
      ("adjustingUnitAmount", E.string adjustingUnitAmount)
    ]
