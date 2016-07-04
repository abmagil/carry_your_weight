App.cable.subscriptions.create "HomeChannel",
  # ActionCable Callbacks
  connected: ->
    console.log("Connected to Home Channel")

  disconnected: ->
    console.log("Disconnected from Home Channel")

  rejected: ->
    console.log("Rejected from Home Channel")

  # BizLogic
  received: (data) ->
    $('#raw').text(JSON.stringify(data, null, 2))

    dataset = $.map(data.author_lines, (lines, person) ->
      {person, lines})

    path = svg.datum(dataset).selectAll('path')
      .data(pie)
      .attr('d', arc)
      .enter()
        .append('path')
        .attr('d', arc)
        .attr('fill', (d, i) -> color(d.data.person))

    legend
      .data(dataset)
      .enter().append("g")
      .attr("transform", (d, i) -> "translate(0, #{i * 20})")

    legend
      .data(dataset)
      .enter()
        .append("rect")
        .attr("width", 18)
        .attr("height", 18)
        .attr("y", (d, i) -> i*20)
        .style("fill", (d, i) -> color(d.person))

    legend
      .data(dataset)
      .enter()
        .append("text")
        .attr("x", 24)
        .attr("y", (d, i) -> 9 + i*20 )
        .attr("dy", ".35em")
        .text((d) -> d.person)
