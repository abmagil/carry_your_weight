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

    arcTween = (a) ->
      i = d3.interpolate(this._current, a)
      this._current = i(0)
      (t) ->
        arc(i(t))

    dataset = $.map(data.author_lines, (lines, person) ->
      {person, lines})

    path = svg.datum(dataset).selectAll('path')
      .data(pie)
    path
      .transition()
      .duration(250)
      .attrTween("d", arcTween)
    path
      .attr('d', arc)
      .enter()
        .append('path')
        .attr('d', arc)
        .attr('fill', (d, i) -> color(d.data.person))
        .each((d) -> this._current = d)

    path.exit().remove()

    legendColor = legend.selectAll("rect")
      .data(dataset, (d) -> d.person)
    legendColor
      .enter()
        .append("rect")
        .attr("width", 18)
        .attr("height", 18)
        .attr("y", (d, i) -> i*20)
        .style("fill", (d, i) -> color(d.person))
    legendColor.exit().remove()

    legendText = legend.selectAll("text")
      .data(dataset, (d) -> d.person)
    legendText
      .enter()
        .append("text")
        .attr("x", 24)
        .attr("y", (d, i) -> 9 + i*20 )
        .attr("dy", ".35em")
        .text((d) -> d.person)
    legendText.exit().remove()
