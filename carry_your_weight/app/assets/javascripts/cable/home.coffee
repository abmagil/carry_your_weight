App.cable.subscriptions.create "HomeChannel",

  connected: ->
    console.log("Connected to Home Channel")

  disconnected: ->
    console.log("Disconnected from Home Channel")

  rejected: ->
    console.log("Rejected from Home Channel")

  received: (data) ->
    console.log("I've received something!")
