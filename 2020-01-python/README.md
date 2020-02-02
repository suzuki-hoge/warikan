# python
db and api package, for elm.

## api specs
```
@post('/party/plan')

$ curl -sS -X POST localhost:9000/party/plan -d 'partyName=new-year' -d 'partyHoldAt=2020-01-01' -d 'secretaryName=p1' -d 'paymentSection=M' -d 'billingAmount=60000' -d 'adjustingUnitAmount=1000' | jq . -c
{"status":"ok"}
```

```
@get('/party/<partyName>')

$ curl -sS -X GET localhost:9000/party/new-year | jq . -c
{"status":"ok","result":{"billingAmount":"60000","participants":[{"participantType":"Sec","participantName":"p1","paymentSection":"M"}],"partyName":"new-year","adjustingUnitAmount":"1000","partyHoldAt":"2020-01-01"}}
```

```
@put('/party/<partyName>/add')

$ curl -sS -X PUT localhost:9000/party/new-year/add -d 'participantName=p2' -d 'paymentSection=N' | jq . -c
{"status":"ok"}
```

```
@put('/party/<partyName>/remove')

$ curl -sS -X PUT localhost:9000/party/new-year/remove -d 'participantName=p2' | jq . -c
{"status":"ok"}
```

```
@put('/party/<partyName>/change')

$ curl -sS -X PUT localhost:9000/party/new-year/change -d 'adjustingUnitAmount=500' | jq . -c
{"status":"ok"}
```

```
@get('/party/<partyName>/demand')

$ curl -sS -X GET localhost:9000/party/new-year/demand | jq . -c
{"status":"ok","result":[{"paymentAmount":31000,"participantName":"p1"},{"paymentAmount":29000,"participantName":"p2"}]}
```
