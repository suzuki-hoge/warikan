from bottle import get, post, put, request, response, hook, run
import json

import db, party


def handle(f):
    def wrapper(*args, **kwargs):
        try:
            result = f(*args, **kwargs)
            return {'status': 'ok', 'result': result} if result is not None else {'status': 'ok'}

        except BaseException as e:
            return {'status': 'ng', 'error': e.message}

    return wrapper


@hook('after_request')
def allow_cors():
    response.headers['Access-Control-Allow-Origin'] = '*'


@get('/party/<partyName>')
@handle
def find(partyName):
    def party_dict(p):
        return {'partyName': p.partyName, 'partyHoldAt': p.partyHoldAt, 'participants': map(participant_dict, p.participants), 'billingAmount': p.billingAmount, 'adjustingUnitAmount': p.adjustingUnitAmount}

    def participant_dict(p):
        return {'participantName': p.participantName, 'participantType': p.participantType, 'paymentSection': p.paymentSection}

    return party_dict(db.read(partyName))


@post('/party/plan')
@handle
def plan():
    p = request.params

    new = party.Party.plan(p.partyName, p.partyHoldAt, p.secretaryName, p.paymentSection, int(p.billingAmount), int(p.adjustingUnitAmount))
    db.write(new)

 
@put('/party/<partyName>/add')
@handle
def add(partyName):
    p = request.params

    found = db.read(partyName)
    updated = found.add(party.Participant(p.participantName, 'NotSec', p.paymentSection))
    db.write(updated)


@put('/party/<partyName>/remove')
@handle
def remove(partyName):
    p = request.params

    found = db.read(partyName)
    updated = found.remove(p.participantName)
    db.write(updated)


@put('/party/<partyName>/change')
@handle
def change(partyName):
    p = request.params

    found = db.read(partyName)
    updated = found.change(int(p.adjustingUnitAmount))
    db.write(updated)


@get('/party/<partyName>/demand')
@handle
def demand(partyName):
    found = db.read(partyName)

    return map(lambda (participantName, paymentAmount): {'participantName': participantName, 'paymentAmount': paymentAmount}, found.demand())


# plan('new-year', '2019-01-01', 'p1', 'M', 60000, 1000)
# print find('new-year')
# print demand('new-year')

run(host = 'localhost', port = 9000)
