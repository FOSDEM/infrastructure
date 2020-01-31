function create_add (tag, parent) {
  var el = document.createElement(tag);
  parent.appendChild(el);
  return el;
}
function fetch_images() {
  return Array.from(document.getElementsByTagName('img'));
}
function refresh() {
  fetch_images().forEach(function(img) {
    var src = img.src + '?';
    src = src.split('?')[0];
    img.src = src + '?' + Date.now()
  })
}
function add_room (room_code, parent) {
  var room = create_add("td", parent);
  room.innerHTML = `
    <h3>${room_code}</h3>
    <a href='tcp://${room_code}-cam.local:8899'>
      <img src="https://control.video.fosdem.org/${room_code}/cam.jpg"/>
    </a>
    <a href='tcp://${room_code}-slides.local:8899'>
      <img src="https://control.video.fosdem.org/${room_code}/grab.jpg"/>
    </a>
      <a href='tcp://${room_code}-voctop.local:8899'>
      <img src="https://control.video.fosdem.org/${room_code}/room.jpg"/>
    </a>
  `;
}
function init (cols) {
  var listTable = document.querySelector('#list tbody');
  listTable.innerHTML = '';
  cols = cols || 10;
  fetch('./config.json')
    .then(res => res.json())
    .then(conf => Object.keys(conf))
    .then(rooms => {
      rows = Math.ceil(rooms.length / cols)
      new Array(rows).fill({})
        .map(() => create_add('tr', listTable))
        .map((row, y) => new Array(cols).fill({})
          .map((n1, x) => rooms[y * cols + x] && add_room(
            rooms[y * cols + x],
            row
          ))
          .forEach(col => {
            col && col.setAttribute('width', (100 / cols).toFixed(2) + '%');
          })
        )
      setInterval(refresh, 10000);
    })
}
