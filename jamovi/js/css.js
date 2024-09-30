const css = `

/* Stile comune per entrambi i bottoni */
.button-style {
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

.button-style:hover {
    background-color: #3cb0fd;
    background-image: linear-gradient(to bottom, #3cb0fd, #3498db);
}

.button-style:active {
    background-color: #3498db;
    background-image: linear-gradient(to bottom, #3498db, #2980b9);
    box-shadow: 0 3px #DADADA;
    transform: translateY(4px);
}

/* Personalizzazioni specifiche per ciascun bottone */
#butsf-file span, #butsf-reshape span {
    text-decoration: underline;
}

/* Stili per il tooltip personalizzato */
.custom-tooltip {
    display: none;
    position: absolute;
    background-color: yellow;
    color: black;
    padding: 5px;
    border-radius: 4px;
    z-index: 1000;
    white-space: nowrap;
    box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);
    border: 1px solid black;
}
`;

let node = document.createElement('style');
node.innerHTML = css;
document.body.appendChild(node);

module.exports = undefined;
