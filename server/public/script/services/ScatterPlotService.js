angular.module('CloneDetection').service('ScatterPlotService', function ($http, $q) {
  function render(selector, data, clickCb) {
    var margin = {top: 20, right: 20, bottom: 30, left: 40},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;


    var xValue = function (d) {
        return d.weight;
      },
      xScale = d3.scale.linear().range([0, width]),
      xMap = function (d) {
        return xScale(xValue(d));
      }, // data -> display
      xAxis = d3.svg.axis().scale(xScale).orient("bottom");

    var yValue = function (d) {
        return d.fragments;
      }, // data -> value
      yScale = d3.scale.linear().range([height, 0]), // value -> display
      yMap = function (d) {
        return yScale(yValue(d));
      }, // data -> display
      yAxis = d3.svg.axis().scale(yScale).orient("left");

    var cValue = function (d) {
      return d.size;
    };
    var color = d3.scale.category10();

    var svg = d3.select(selector).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var tooltip = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);

    // don't want dots overlapping axis, so add in buffer to data domain
    xScale.domain([d3.min(data, xValue) - 1, d3.max(data, xValue) + 1]);
    yScale.domain([d3.min(data, yValue) - 1, d3.max(data, yValue) + 1]);

    // x-axis
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
      .append("text")
      .attr("class", "label")
      .attr("x", width)
      .attr("y", -6)
      .style("text-anchor", "end")
      .text("Weight");

    // y-axis
    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("class", "label")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Fragments");

    // draw dots
    svg.selectAll(".dot")
      .data(data)
      .enter().append("circle")
      .attr("class", "dot")
      .attr("r", 3.5)
      .attr("cx", xMap)
      .attr("cy", yMap)
      .on("click", function (item) {
        d3.selectAll(".dot").attr("stroke-width", "0");
        d3.select(this).attr("stroke", "black").attr("stroke-width", "2");
        clickCb(item);
      })
      .style("fill", function (d) {
        return color(cValue(d));
      })
      .style("cursor", "pointer")

    var legend = svg.selectAll(".legend")
      .data(color.domain())
      .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function (d, i) {
        return "translate(0," + i * 20 + ")";
      });

    legend.append("rect")
      .attr("x", width - 18)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

    legend.append("text")
      .attr("x", width - 24)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function (d) {
        return d;
      })
  }


  return {
    render: render
  };
});