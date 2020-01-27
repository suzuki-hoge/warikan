from bottle import route, get, post, put, request, response, hook, run
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
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, OPTIONS'


@route('<any:path>', method = 'OPTIONS')
def options(**kwargs):
    return {}


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
    p = request.json

    new = party.Party.plan(p.get('partyName'), p.get('partyHoldAt'), p.get('secretaryName'), p.get('paymentSection'), p.get('billingAmount'), p.get('adjustingUnitAmount'))
    db.write(new)

 
@put('/party/<partyName>/add')
@handle
def add(partyName):
    p = request.json

    found = db.read(partyName)
    updated = found.add(party.Participant(p.get('participantName'), 'NotSec', p.get('paymentSection')))
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
    p = request.json

    found = db.read(partyName)
    updated = found.change(p.get('adjustingUnitAmount'))
    db.write(updated)


@get('/party/<partyName>/demand')
@handle
def demand(partyName):
    found = db.read(partyName)

    return map(lambda (participantName, paymentAmount): {'participantName': participantName, 'paymentAmount': str(paymentAmount)}, found.demand())


run(host = 'localhost', port = 9000)
