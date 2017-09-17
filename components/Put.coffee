noflo = require 'noflo'

# @platform noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'store',
    datatype: 'object'
  c.inPorts.add 'value',
    datatype: 'all'
  c.outPorts.add 'store',
    datatype: 'object'
  c.outPorts.add 'key',
    datatype: 'string'
  c.outPorts.add 'value',
    datatype: 'all'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'store', 'value'
    [store, value] = input.getData 'store', 'value'
    req = store.put value
    output.send
      store: store
    req.onerror = (err) ->
      output.done err
    req.onsuccess = (e) ->
      output.send
        key: e.target.result
      output.sendDone
        value: value
