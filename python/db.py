from party import Party, Participant

def read_all():
    def party(line):
        return Party(line.split(',')[0], line.split(',')[1], map(participant, line.split(',')[2].split('/')), int(line.split(',')[3]), int(line.split(',')[4]))

    def participant(line):
        return Participant(line.split(':')[0], line.split(':')[1], line.split(':')[2])

    with open('./db.txt', 'r') as f:
        lines = f.read().splitlines()

    return map(party, lines)


def read(partyName):
    found = filter(lambda p: p.partyName == partyName, read_all())
    if found == []:
        raise BaseException('no such party')
    else:
        return found[0]


def write(party):
    def party_line(party):
        return '%s,%s,%s,%d,%d' % (party.partyName, party.partyHoldAt, ('/'.join(map(participant_line, party.participants))), party.billingAmount, party.adjustingUnitAmount)

    def participant_line(participant):
        return '%s:%s:%s' % (participant.participantName, participant.participantType, participant.paymentSection)

    found_parties = read_all()

    if party.partyName in [found_party.partyName for found_party in found_parties]:
        new_parties = [found_party for found_party in found_parties if party.partyName != found_party.partyName] + [party]
    else:
        new_parties = found_parties + [party]

    new_lines = map(party_line, new_parties)

    with open('./db.txt', 'w') as f:
        f.write('\n'.join(map(party_line, new_parties)))


# party = Party.plan('new-year', '2019-01-01', 'p1', 'M', 60000, 1000)
# added = added = party.add(Participant('p2', 'NotSec', 'N'))

# write(party)

# [p.debug() for p in read_all()]

# read('new-year').debug()
