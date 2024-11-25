const css = `

/* Common style for both buttons */
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

/* Specific customizations for each button */
#butsf-file span, #butsf-reshape span {
    text-decoration: underline;
}

/* Styles for custom tooltip */
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

/* Style for LOGGING ACTIVE message */
.logging-active {
    font-size: 1em;
    font-weight: bold;
    color: white;
    background-color: green;
    padding: 5px 10px;
    border-radius: 5px;
    margin-left: 20px; /* Spazio tra il titolo e il messaggio */
    display: inline-block;
    text-transform: uppercase;
    box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.3);
}

/* Style to hide the message */
.hidden {
    display: none !important;
}

/* Style to make the message visible */
.visible {
    display: inline-block !important;
}

/* Style for the arrow button */
.silky-sp-back-button {
    float: right;
    margin-right: 10px;
}

`;

let node = document.createElement('style');
node.innerHTML = css;
document.body.appendChild(node);

module.exports = undefined;
