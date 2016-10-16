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
      i = d3.interpolate(@_current, a)
      @_current = i(0)
      (t) ->
        arc(i(t))

    # Note that we have no guarantee of order from API
    dataset = $.map(data.author_lines, (lines, person) -> {person, lines})
      .sort (a,b) ->
        if a.lines > b.lines
          return 1
        if b.lines > a.lines
          return -1
        return 0

    y.domain(dataset.map((d) -> d.person))
    y.rangeBands([0, dataset.length * 20])

    path = svg.datum(dataset).selectAll('path').data(pie)
    # Enter
    path.attr('d', arc)
      .enter()
        .append('path')
        .attr('d', arc)
        .attr('fill', (d, i) -> color(d.data.person))
        .each((d) -> @_current = d)
    # Update
    path
      .transition()
      .duration(500)
      .attr('fill', (d, i) -> color(d.data.person))
      .attrTween("d", arcTween)
    # Exit
    path.exit().remove()

    legendColor = legend.selectAll("rect").data(dataset, (d) -> d.person)
    # Enter
    legendColor
      .enter()
        .append("rect")
        .attr("width", "1em")
        .attr("height", "1em")
        .attr("y", (d) -> y(d.person))
        .style("fill", (d, i) -> color(d.person))
    # Update
    legendColor
      .transition()
      .duration(500)
      .attr("y", (d) -> y(d.person))
      .style("fill", (d, i) -> color(d.person))
    # Exit
    legendColor.exit().remove()

    legendText = legend.selectAll("text").data(dataset, (d) -> d.person)
    # Enter
    legendText
      .enter()
        .append("text")
        .attr("x", (d, i) -> "1.2em")
        .attr("y", (d) -> y(d.person))
        .attr("dy", "0.85em")
        .text((d) -> d.person)
    # Update
    legendText
      .transition()
      .duration(500)
      .attr("x", (d, i) -> "1.2em")
      .attr("y", (d) -> y(d.person))
    # Exit
    legendText.exit().remove()
