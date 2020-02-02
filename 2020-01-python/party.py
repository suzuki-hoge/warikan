import payment

class Party:
    @staticmethod
    def plan(partyName, partyHoldAt, participantName, paymentSection, billingAmount, adjustingUnitAmount):
        return Party(partyName, partyHoldAt, [Participant(participantName, 'Sec', paymentSection)], billingAmount, adjustingUnitAmount)


    def __init__(self, partyName, partyHoldAt, participants, billingAmount, adjustingUnitAmount):
        self.partyName = partyName
        self.partyHoldAt = partyHoldAt
        self.participants = participants
        self.billingAmount = billingAmount
        self.adjustingUnitAmount = adjustingUnitAmount

    def add(self, participant):
        self.participants = self.participants + [participant]
        return self

    def remove(self, participantName):
        self.participants = filter(lambda p: p.participantName != participantName, self.participants)
        return self

    def debug(self):
        print self.partyName
        print self.partyHoldAt
        [p.debug('  ') for p in self.participants]
        print self.billingAmount
        print self.adjustingUnitAmount

    def change(self, adjustingUnitAmount):
        self.adjustingUnitAmount = adjustingUnitAmount
        return self

    def demand(self):
        def bind(units, fractionAmount, p):
            paymentAmount = filter(lambda (paymentSection, paymentAmount): paymentSection == p.paymentSection, units)[0][1]
            if p.participantType == 'Sec':
                return (p.participantName, paymentAmount + fractionAmount)
            else:
                return (p.participantName, paymentAmount)

        (units, fractionAmount) = payment.calculate(int(self.billingAmount), (map(lambda p: p.paymentSection, self.participants)), int(self.adjustingUnitAmount))
        return map(lambda p: bind(units, fractionAmount, p), self.participants)


class Participant:
    def __init__(self, participantName, participantType, paymentSection):
        self.participantName = participantName
        self.participantType = participantType
        self.paymentSection = paymentSection

    def debug(self, indent):
        print indent + self.participantName
        print indent + self.participantType
        print indent + self.paymentSection


def add(party, participant):
    return party.add(participant)


# party = Party.plan('new-year', '2019-01-01', 'p1', 'M', 60000, 1000)
# party.debug()

# added = party.add(Participant('p2', 'NotSec', 'N'))
# added.debug()

# removed = added.remove('p2')
# removed.debug()

# changed = removed.change(500)
# changed.debug()


# party = Party(
#     'new-year',
#     '2019/01/01',
#     [
#         Participant('p1', 'Sec',    'M'),
#         Participant('p2', 'NotSec', 'M'),
#         Participant('p3', 'NotSec', 'M'),
#         Participant('p4', 'NotSec', 'N'),
#         Participant('p5', 'NotSec', 'L'),
#         Participant('p6', 'NotSec', 'L')
#     ],
#     65000,
#     500
# )
# print party.demand()
