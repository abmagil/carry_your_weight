App.cable.subscriptions.create "HomeChannel",

  connected: ->
    console.log("Connected to Home Channel")
    @perform("ping")

  disconnected: ->
    console.log("Disconnected from Home Channel")

  rejected: ->
    console.log("Rejected from Home Channel")

  received: (data) ->
    if data == "end"
      console.log ("Data is end")
      @perform("unsubscribed")
    else
      console.log ("Data received is not end")
      console.log(data)
