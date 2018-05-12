const w = 200
const h = 200


function getAdjacent(nodeId) {
  const x = Math.floor(nodeId % w)
  const y = Math.floor(nodeId / w)

  let ad = []
  function push(xx, yy) {
    if (xx >= 0 && xx < w && yy >= 0 && yy < h)
      ad.push(xx + yy * w)
  }

  push( (x - 1),  y )
  push( (x + 1), y )
  push( x, (y - 1) )
  push( x, (y + 1) )

  return ad
}



/*
var cache = {}
for (let x = 0; x < w; x++)
  for (let y = 0; y < w; y++)
    cache[x + y * w] = getAdjacent(x + y * w)
*/



function dijkstra(getAdjacent, startId) {

  let openNodes =
    [startId]

  let distances = {
    [startId]: 0,
  }

  function findBest() {
    let bestNodeId = null
    let bestDistance = Infinity
    for (let nodeId of openNodes) {
      const distance = distances[nodeId]
      if (distance < bestDistance) {
        bestDistance = distance
        bestNodeId = nodeId
      }
    }

    return bestNodeId !== null
      ? [ bestNodeId, bestDistance ]
      : null
  }


  var best
  while (best = findBest()) {
    const [bestNodeId, bestDistance] = best
    openNodes = openNodes.filter(nodeId => nodeId !== bestNodeId)

    //const adjacentNodes = cache[bestNodeId]
    const adjacentNodes = getAdjacent(bestNodeId)

    for (let nodeId of adjacentNodes) {
      const newDistance = bestDistance + 1

      const oldDistance = distances[nodeId]

      if (!oldDistance) {
        distances[nodeId] = newDistance
        openNodes.push(nodeId)
      } else if (oldDistance > newDistance) {
        distances[nodeId] = newDistance
      }
    }
  }

  return distances
}





function main() {

  const start = Date.now()
  const distances = dijkstra(getAdjacent, 200)
  const end = Date.now()

  console.log((end - start) / 1000)
  console.log(Object.keys(distances).length)
//  console.log(getAdjacent('-3615184'))
}




