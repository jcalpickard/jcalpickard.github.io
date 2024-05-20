To handle performance and focus on the current page, implement egocentric mapping. This involves centering the visualization on the current node and displaying nodes within a few degrees of separation.

function getEgocentricData(data, currentNodeId, degrees) {
  const nodes = new Set();
  const edges = new Set();
  const queue = [currentNodeId];
  const visited = new Set();

  for (let i = 0; i < degrees; i++) {
    const nextQueue = [];
    while (queue.length > 0) {
      const nodeId = queue.shift();
      if (!visited.has(nodeId)) {
        visited.add(nodeId);
        nodes.add(nodeId);
        data.links.forEach(link => {
          if (link.source === nodeId || link.target === nodeId) {
            edges.add(link);
            nextQueue.push(link.source === nodeId ? link.target : link.source);
          }
        });
      }
    }
    queue.push(...nextQueue);
  }

  return {
    nodes: data.nodes.filter(node => nodes.has(node.id)),
    edges: Array.from(edges)
  };
}

fetch('{{ "/assets/graph-data.json" | relative_url }}')
  .then(response => response.json())
  .then(data => {
    const currentNodeId = 'About'; // Replace with the current page's node ID
    const egocentricData = getEgocentricData(data, currentNodeId, 2); // 2 degrees of separation

    const container = document.getElementById('network');
    const stages = {
      bruck: { color: '#8B4513', size: 10, borderWidth: 1 },
      tinkering: { color: '#A0522D', size: 15, borderWidth: 2 },
      roughingOut: { color: '#CD853F', size: 20, borderWidth: 3 },
      moulding: { color: '#DEB887', size: 25, borderWidth: 4 },
      detailing: { color: '#F5DEB3', size: 30, borderWidth: 5 }
    };

    egocentricData.nodes.forEach(node => {
      const stage = stages[node.stage];
      if (stage) {
        node.color = stage.color;
        node.size = stage.size;
        node.borderWidth = stage.borderWidth;
        node.title = `<div>
                        <strong>${node.label}</strong>
                        <p>Stage: ${node.stage}</p>
                        <p>Tags: ${node.tags.join(', ')}</p>
                      </div>`;
      }
    });

    const edges = egocentricData.edges.map(link => ({
      from: link.source,
      to: link.target
    }));

    const networkData = {
      nodes: egocentricData.nodes,
      edges: edges
    };

    const options = {
      nodes: {
        shape: 'dot',
        font: {
          size: 15,
          color: '#000000'
        }
      },
      edges: {
        width: 2,
        color: '#cccccc' // Neutral color for edges
      },
      interaction: {
        hover: true,
        navigationButtons: true,
        keyboard: true,
        tooltipDelay: 300
      },
      physics: {
        enabled: true,
        stabilization: {
          iterations: 200
        }
      }
    };

    const network = new vis.Network(container, networkData, options);

    var tooltip = document.createElement("div");
    tooltip.className = "graph-tooltip";
    document.body.appendChild(tooltip);

    network.on("hoverNode", function (params) {
      const nodeId = params.node;
      const nodeData = egocentricData.nodes.find(node => node.id === nodeId);
      tooltip.innerHTML = nodeData.title;
      tooltip.style.display = "block";
      tooltip.style.left = params.event.pageX + "px";
      tooltip.style.top = params.event.pageY + "px";
    });

    network.on("blurNode", function () {
      tooltip.style.display = "none";
    });

    network.on('click', (params) => {
      if (params.nodes.length === 1) {
        const nodeId = params.nodes[0];
        const node = egocentricData.nodes.find(node => node.id === nodeId);
        if (node && node.url) {
          setTimeout(() => {
            window.location.href = node.url;
          }, 300);
        }
      }
    });
  })
  .catch(error => {
    console.error('There has been a problem with your fetch operation:', error);
    const container = document.getElementById('network');
    container.innerHTML = 'Error loading the network graph. Please try again later.';
  });
