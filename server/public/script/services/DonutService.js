angular.module('CloneDetection').service('DonutService', function ($state) {
  var packages = {
    // Lazily construct the package hierarchy from class names.
    root: function (classes) {
      var map = {};

      function find(name, data) {
        var node = map[name],
          i;
        if (!node) {
          node = map[name] = data || {
              name: name,
              children: []
            };
          if (name.length) {
            node.parent = find(name.substring(0, i = name.lastIndexOf("/")));
            node.parent.children.push(node);
            node.key = name.substring(i + 1);
            node.id = node.name.replace(/\./, "\\.").replace(/\//g, "\\/");
          }
        }
        return node;
      }

      classes.forEach(function (d) {
        find(d.name, d);
      });

      return map[""];
    },

    // Return a list of imports for the given array of nodes.
    imports: function (nodes) {
      var map = {},
        imports = [];

      // Compute a map from name to node.
      nodes.forEach(function (d) {
        map[d.name] = d;
      });

      // For each import, construct a link from the source to target node.
      nodes.forEach(function (d) {
        if (d.imports) d.imports.forEach(function (i) {
          imports.push({
            source: map[d.name],
            target: map[i]
          });
        });
      });
      return imports;
    }
  };
  var donutData = undefined;

  return {
    render: render
  };


  function render(cloneData, onClickCb) {
    if (donutData === undefined) {
      donutData = createDonutData(cloneData);
    }

    var w = 1500,
      h = 1000,
      rx = w / 2,
      ry = h / 2,
      m0,
      rotate = 0;

    var cluster = d3.layout.cluster()
      .size([360, ry - 120])
      .sort(function (a, b) {
        return d3.ascending(a.key, b.key);
      });

    var bundle = d3.layout.bundle();

    var line = d3.svg.line.radial()
      .interpolate("bundle")
      .tension(.85)
      .radius(function (d) {
        return d.y;
      })
      .angle(function (d) {
        return d.x / 180 * Math.PI;
      });

    // Chrome 15 bug: <http://code.google.com/p/chromium/issues/detail?id=98951>
    var div = d3.select("#donut-graph").insert("div", "h2")
      .style("width", w + "px")
      .style("height", w + "px")
      .style("position", "absolute")
      .style("-webkit-backface-visibility", "hidden");

    var svg = div.append("svg:svg")
      .attr("width", w)
      .attr("height", w)
      .append("svg:g")
      .attr("transform", "translate(" + rx + "," + ry + ")");

    svg.append("svg:path")
      .attr("class", "arc")
      .attr("d", d3.svg.arc().outerRadius(ry - 120).innerRadius(0).startAngle(0).endAngle(2 * Math.PI))
      .on("mousedown", mousedown);


    var nodes = cluster.nodes(packages.root(donutData)),
      links = packages.imports(nodes),
      splines = bundle(links);

    var path = svg.selectAll("path.link")
      .data(links)
      .enter().append("svg:path")
      .attr("class", function (d) {
        return "link source-" + d.source.name + " target-" + d.target.name;
      })
      .attr("d", function (d, i) {
        return line(splines[i]);
      });

    svg.selectAll("g.node")
      .data(nodes.filter(function (n) {
        return !n.children;
      }))
      .enter().append("svg:g")
      .attr("class", "node")
      .attr("id", function (d) {
        return "node-" + d.name;
      })
      .attr("transform", function (d) {
        return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")";
      })
      .append("svg:text")
      .attr("dx", function (d) {
        return d.x < 180 ? 8 : -8;
      })
      .attr("dy", ".31em")
      .attr("transform", function (d) {
        return d.x < 180 ? null : "rotate(180)";
      })
      .attr("text-anchor", function (d) {
        return d.x < 180 ? "start" : "end";
      })
      .on("click", select)
      .on("mouseout", mouseout)
      .on("mouseover", mouseover)
      .on("dblclick", openFile)
      .each(createNodeName);

    function createNodeName(d) {
      parent = d3.select(this);
      parent.append("svg:tspan")
        .text(function (d) {
          return d.key;
        })
        .classed("reflexive", function (d) {
          return d.reflexive;
        });

      if (d.reflexive) {
        parent.append("svg:tspan")
          .attr("class", "reflexiveSymbol")
          .attr("x", function (d) {
            return d.x < 180 ? 2 : -2;
          })
          .attr("dy", ".31em")
          .html(function (d) {
            return "*"/*"&#9899;"*/;
          });
      }

    }

    d3.select(window)
      .on("mousemove", mousemove)
      .on("mouseup", mouseup)
      .on("keydown", keyPressed);

    function openFile(d) {
      $state.go("app.files", {path: d.name});
    }

    function mouse(e) {
      return [e.pageX - rx, e.pageY - ry];
    }

    function mousedown() {
      m0 = mouse(d3.event);
      d3.event.preventDefault();
    }

    function mousemove() {
      if (m0) {
        var m1 = mouse(d3.event),
          dm = Math.atan2(cross(m0, m1), dot(m0, m1)) * 180 / Math.PI;
        div.style("-webkit-transform", "translateY(" + (ry - rx) + "px)rotateZ(" + dm + "deg)translateY(" + (rx - ry) + "px)");
      }
    }

    function mouseup() {
      if (m0) {
        var m1 = mouse(d3.event),
          dm = Math.atan2(cross(m0, m1), dot(m0, m1)) * 180 / Math.PI;

        rotate += dm;
        if (rotate > 360) rotate -= 360;
        else if (rotate < 0) rotate += 360;
        m0 = null;

        div.style("-webkit-transform", null);

        svg
          .attr("transform", "translate(" + rx + "," + ry + ")rotate(" + rotate + ")")
          .selectAll("g.node text")
          .attr("dx", function (d) {
            return (d.x + rotate) % 360 < 180 ? 8 : -8;
          })
          .attr("text-anchor", function (d) {
            return (d.x + rotate) % 360 < 180 ? "start" : "end";
          })
          .attr("transform", function (d) {
            return (d.x + rotate) % 360 < 180 ? null : "rotate(180)";
          })
          .select(".reflexiveSymbol")
          .attr("x", function (d) {
            return (d.x + rotate) % 360 < 180 ? 2 : -2;
          });
      }
    }


    var lastClicked = undefined;

    function select(d) {
      if (lastClicked) {
        unclick(lastClicked);
      }

      svg.select("#node-" + d.id)
        .classed("selected", true);

      lastClicked = d;

      svg.selectAll("path.link.source-" + d.id)
        .classed("source", true)
        .each(updateNodes("target", true));

      onClickCb(d.name);
    }

    function keyPressed(d) {
      if (d3.event.keyCode == 27) {
        unclick(lastClicked);
      }
    }

    function unclick(d) {
      svg.select("#node-" + d.id)
        .classed("selected", false);
      svg.selectAll("path.link.source-" + d.id)
        .classed("source", false)
        .each(updateNodes("target", false));
    }

    function mouseover(d) {
      svg.selectAll("path.link.target-" + d.id)
        .classed("target", true)
        .each(updateNodes("source", true));
    }

    function mouseout(d) {
      svg.selectAll("path.link.target-" + d.id)
        .classed("target", false)
        .each(updateNodes("source", false));
    }

    function updateNodes(name, value) {
      return function (d) {
        if (value) this.parentNode.appendChild(this);
        svg.select("#node-" + d[name].id).classed(name, value);
      };
    }

    function cross(a, b) {
      return a[0] * b[1] - a[1] * b[0];
    }

    function dot(a, b) {
      return a[0] * b[0] + a[1] * b[1];
    }
  }

  function createDonutData(cloneData) {
    var result = {};

    cloneData.allFileRefs.forEach(function (fileRef) {
      if (!fileRef.isDir && fileRef.path.indexOf("src/") >= 0 && !_.isEmpty(fileRef.fragments)) {
        result[fileRef.path] = {
          name: fileRef.path,
          imports: new Set(),
          reflexive: false
        }
      }
    });

    cloneData.clones.forEach(function (clone) {
      files = clone.fragments.map(function (fragment) {
        return fragment.file;
      });

      for (i = 0; i < files.length; i++) {
        for (j = i + 1; j < files.length; j++) {
          if (files[i] !== files[j]) {
            result[files[i]].imports.add(files[j]);
            result[files[j]].imports.add(files[i]);
          } else {
            result[files[i]].reflexive = true;
          }
        }
      }
    });

    return _.values(result);
  }
});