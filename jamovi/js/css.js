
const css = `

#butsf {
    display: inline-block;
    padding: 3px 5px;
    font-size: 14px;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    outline: none;
    color: white;
    background-color: #3498db;
    background-image: linear-gradient(to bottom, #3498db, #2980b9);
    border: none;
    border-radius: 5px;
    box-shadow: 0 3px #969696;
    cursor: pointer;
}

#butsf:hover {
    background-color: #3cb0fd;
    background-image: linear-gradient(to bottom, #3cb0fd, #3498db);
}

#butsf:active {
  background-color: #3498db;
  background-image: linear-gradient(to bottom, #3498db, #2980b9);
  box-shadow: 0 3px #DADADA;
  transform: translateY(4px);
}

`;
let node = document.createElement('style');
node.innerHTML = css;
document.body.appendChild(node);

module.exports = undefined;
