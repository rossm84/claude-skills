---
name: d3-visualization
description: Use when creating interactive data visualizations, charts, dashboards, or infographics. Generates standalone HTML files with D3.js for bar charts, line charts, scatter plots, treemaps, force graphs, Gantt charts, and custom visualizations.
---

# D3.js Data Visualization

Generate standalone HTML files with embedded D3.js visualizations. No build step, no server needed. Open directly in a browser or host on Firebase.

## Quick start

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <script src="https://d3js.org/d3.v7.min.js"></script>
  <style>
    body { font-family: Arial, sans-serif; background: #121212; color: #fff; margin: 0; padding: 20px; }
    .chart { background: #1a1a1a; border-radius: 8px; padding: 20px; }
    .bar { fill: #1DB954; }
    .bar:hover { fill: #1ED760; }
    .axis text { fill: #b3b3b3; font-size: 12px; }
    .axis line, .axis path { stroke: #333; }
    .tooltip { position: absolute; background: #282828; color: #fff; padding: 8px 12px; border-radius: 4px; font-size: 13px; pointer-events: none; }
  </style>
</head>
<body>
  <div class="chart" id="chart"></div>
  <script>
    const data = [
      { label: "Q1", value: 4500 },
      { label: "Q2", value: 5500 },
      { label: "Q3", value: 6200 },
      { label: "Q4", value: 7100 }
    ];
    const margin = { top: 40, right: 30, bottom: 50, left: 60 };
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    const svg = d3.select("#chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g").attr("transform", `translate(${margin.left},${margin.top})`);

    const x = d3.scaleBand().domain(data.map(d => d.label)).range([0, width]).padding(0.3);
    const y = d3.scaleLinear().domain([0, d3.max(data, d => d.value)]).range([height, 0]);

    svg.append("g").attr("class", "axis").attr("transform", `translate(0,${height})`).call(d3.axisBottom(x));
    svg.append("g").attr("class", "axis").call(d3.axisLeft(y).tickFormat(d3.format(",d")));

    svg.selectAll(".bar").data(data).join("rect")
      .attr("class", "bar").attr("x", d => x(d.label)).attr("y", d => y(d.value))
      .attr("width", x.bandwidth()).attr("height", d => height - y(d.value));
  </script>
</body>
</html>
```

## Chart types

### Line chart
```javascript
const line = d3.line().x(d => x(d.date)).y(d => y(d.value)).curve(d3.curveMonotoneX);
svg.append("path").datum(data).attr("d", line).attr("fill", "none").attr("stroke", "#1DB954").attr("stroke-width", 2);
```

### Scatter plot
```javascript
svg.selectAll("circle").data(data).join("circle")
  .attr("cx", d => x(d.x)).attr("cy", d => y(d.y)).attr("r", 5).attr("fill", "#1DB954");
```

### Treemap
```javascript
const root = d3.hierarchy({ children: data }).sum(d => d.value);
d3.treemap().size([width, height]).padding(2)(root);
```

### Force-directed graph
```javascript
const sim = d3.forceSimulation(nodes)
  .force("link", d3.forceLink(links).id(d => d.id))
  .force("charge", d3.forceManyBody().strength(-200))
  .force("center", d3.forceCenter(width/2, height/2));
```

### Gantt chart (useful for migration/sprint timelines)
```javascript
svg.selectAll(".task").data(tasks).join("rect")
  .attr("x", d => x(d.start)).attr("y", d => y(d.name))
  .attr("width", d => x(d.end) - x(d.start)).attr("height", y.bandwidth())
  .attr("fill", d => color(d.status)).attr("rx", 4);
```

## Tooltips
```javascript
const tooltip = d3.select("body").append("div").attr("class", "tooltip").style("opacity", 0);
bars.on("mouseover", (e, d) => {
  tooltip.transition().duration(200).style("opacity", 1);
  tooltip.html(`${d.label}: ${d3.format(",d")(d.value)}`).style("left", e.pageX+10+"px").style("top", e.pageY-28+"px");
}).on("mouseout", () => tooltip.transition().duration(500).style("opacity", 0));
```

## Responsive
```javascript
const container = d3.select("#chart");
const width = parseInt(container.style("width")) - margin.left - margin.right;
window.addEventListener("resize", () => { /* redraw */ });
```

## Spotify theme
```css
:root {
  --spotify-green: #1DB954;
  --spotify-green-light: #1ED760;
  --spotify-black: #121212;
  --spotify-dark: #181818;
  --spotify-card: #282828;
  --spotify-text: #FFFFFF;
  --spotify-subtext: #B3B3B3;
}
```

## Output
Save to `public/` for Firebase hosting or `/mnt/c/Users/RossMiller/Desktop/` for local viewing.
